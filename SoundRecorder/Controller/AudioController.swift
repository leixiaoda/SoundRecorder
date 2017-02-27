//
//  AudioController.swift
//  SoundRecorder
//
//  Created by 雷达 on 2017/2/25.
//  Copyright © 2017年 雷达. All rights reserved.
//

import UIKit
import Foundation
import AVFoundation

let BeginPlayingNotification = Notification.Name("beginPlayingNotificationIdentifier")
let StopPlayingNotification = Notification.Name("stopPlayingNotificationIdentifier")

enum AudioControllerState {
    case recording
    case playing
    case unused
}


final class AudioController: NSObject, AVAudioRecorderDelegate, AVAudioPlayerDelegate {
    static let instance = AudioController()
    
    // 录音器
    private var audioRecorder: AVAudioRecorder!
    // 播放器
    private var audioPlayer: AVAudioPlayer!
    // 音频会话
    private let audioSession = AVAudioSession.sharedInstance()
    
    // 是否有麦克风权限
    var hasAuthority: Bool = false
    //定义音频的编码参数[声音采样率, 编码格式, 采集音轨, 音频质量]
    let recorderSettings = [AVSampleRateKey: NSNumber(value: Float(44100.0)),
                          AVFormatIDKey: NSNumber(value: Int32(kAudioFormatMPEG4AAC)),
                          AVNumberOfChannelsKey: NSNumber(value: 1),
                          AVEncoderAudioQualityKey: NSNumber(value: Int32(AVAudioQuality.medium.rawValue))]
    
    // 录音器音频创建时间
    var recorderAudioCreateTime: Date!
    // 录音器音频名称
    var recorderAudioName: String!
    // 录音器音频地址
    var recorderAudioURL: URL!
    // 录音器音频时长
    var recorderAudioDuration: Double!
    
    // 播放器音频地址
    var playerAudioURL: URL!
    
    // 当前录音/播放状态
    var currentState: AudioControllerState!
    
    private override init() {
        do {
            try audioSession.setCategory(AVAudioSessionCategoryPlayAndRecord)
        } catch let error as NSError {
            print(error)
        }
        
        currentState = AudioControllerState.unused
    }
    
    static func sharedInstance() -> AudioController {
        return instance
    }
    
    
    // 开始录音的一系列步骤
    func beginRecording() -> (succeed: Bool, errorTitle: String?, errorMsg: String?) {
        // 判断是否有麦克风权限
        var hasAuthority: Bool = false
        audioSession.requestRecordPermission { (isAllowed) in
            hasAuthority = isAllowed
        }
        
        if !hasAuthority {
            let title: String = "麦克风权限尚未开启"
            let message: String = "请移步系统设置->隐私->麦克风，打开本App的访问权限"
            return (false, title, message)
        } else {
            self.prepareRecording()
            self.startRecording()
            return (true, nil, nil)
        }
    }
    
    // 录音前的准备工作
    private func prepareRecording() {
        do {
            refreshAudioURL()
            try audioRecorder = AVAudioRecorder(url: recorderAudioURL, settings: recorderSettings)
            audioRecorder.delegate = self
            audioRecorder.prepareToRecord()
        } catch let error as NSError {
            print(error)
        }
    }
    
    // 真正开始录音
    private func startRecording() {
        if audioPlayer != nil && audioPlayer.isPlaying {
            audioPlayer.stop()
            didStopPlaying()
            
            currentState = .unused
        }
        
        if audioRecorder != nil && !audioRecorder.isRecording {
            do {
                try audioSession.setActive(true)
                audioRecorder.record()
                
                currentState = .recording
            } catch let error as NSError {
                print(error)
            }
        }
    }
    
    // 停止录音
    func stopRecording() {
        if audioRecorder != nil && audioRecorder.isRecording {
            do {
                audioRecorder.stop()
                try audioSession.setActive(false)
                refreshAudioDuration()
                
                currentState = .unused
            } catch let error as NSError {
                print(error)
            }
        }
    }
    
    // 开始播放
    func beginPlaying(url: URL?) {
        if audioRecorder == nil || !audioRecorder.isRecording {
            do {
                if url != nil {
                    try audioPlayer = AVAudioPlayer(contentsOf: url!)
                    audioPlayer.delegate = self
                    audioPlayer.play()
                    
                    playerAudioURL = url!
                    currentState = .playing
                    
                    // 发送开始播放通知
                    NotificationCenter.default.post(name: BeginPlayingNotification, object: nil, userInfo: ["url": url!])
                } else {
                    print("url is nil.")
                }
            } catch let error as NSError {
                print(error)
            }
        }
    }
    
    // 播放刚录好的音频
    func beginPlayingTheLatest() {
        if audioRecorder != nil {
            beginPlaying(url: audioRecorder.url)
        }
    }
    
    // 停止播放
    func stopPlaying() {
        if audioPlayer != nil && audioPlayer.isPlaying {
            audioPlayer.stop()
            didStopPlaying()
        }
    }
    
    func didStopPlaying() {
        currentState = .unused
        
        // 发送停止播放通知
        NotificationCenter.default.post(name: StopPlayingNotification, object: nil)
    }
    
    // 获取新录音文件的地址
    func refreshAudioURL() {
        recorderAudioCreateTime = Date()
        let formatter = DateFormatter()
        // 文件命名规范为：../年月日-时分秒.m4a
        formatter.dateFormat = "yyyyMMdd-HH:mm:ss"
        recorderAudioName = formatter.string(from: recorderAudioCreateTime) + ".m4a"
        
        let fileManager = FileManager.default
        let urls = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
        let documentDirectory = urls[0] as URL
        recorderAudioURL = documentDirectory.appendingPathComponent(recorderAudioName)
    }
    
    func refreshAudioDuration() {
        let asset = AVURLAsset(url: recorderAudioURL)
        let time = asset.duration;
        recorderAudioDuration = Double(CMTimeGetSeconds(time))
    }
    
    // MARK: audioPlayer delegate
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        didStopPlaying()
    }
    
    
}
