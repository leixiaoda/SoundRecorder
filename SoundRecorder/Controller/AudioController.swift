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


final class AudioController: NSObject, AVAudioRecorderDelegate, AVAudioPlayerDelegate {
    static let instance = AudioController()
    
    // 录音器
    var audioRecorder: AVAudioRecorder!
    // 播放器
    var audioPlayer: AVAudioPlayer!
    // 音频会话
    let audioSession = AVAudioSession.sharedInstance()
    
    // 是否有麦克风权限
    var hasAuthority: Bool = false
    //定义音频的编码参数[声音采样率, 编码格式, 采集音轨, 音频质量]
    let recorderSettings = [AVSampleRateKey: NSNumber(value: Float(44100.0)),
                          AVFormatIDKey: NSNumber(value: Int32(kAudioFormatMPEG4AAC)),
                          AVNumberOfChannelsKey: NSNumber(value: 1),
                          AVEncoderAudioQualityKey: NSNumber(value: Int32(AVAudioQuality.medium.rawValue))]
    
    // 音频创建时间
    var audioCreateTime: Date!
    // 音频名称
    var audioName: String!
    // 音频地址
    var audioURL: URL!
    // 音频时长
    var audioDuration: Double!
    
    private override init() {
        do {
            try audioSession.setCategory(AVAudioSessionCategoryPlayAndRecord)
        } catch let error as NSError {
            print(error)
        }

    }
    
    static func sharedInstance() -> AudioController {
        return instance
    }
    
    
    // 开始录音的一系列步骤
    func beginRecording() {
        // 判断是否有麦克风权限
        audioSession.requestRecordPermission { (hasAuthority) in
            if !hasAuthority {
                // undone
//                let alertController = UIAlertController(title: "麦克风权限尚未开启", message: "请移步系统设置->隐私->麦克风，打开本APP的访问权限", preferredStyle: .actionSheet)
            } else {
                self.prepareRecording()
                self.startRecording()
            }
        }
    }
    
    // 录音前的准备工作
    private func prepareRecording() {
        do {
            refreshAudioURL()
            try audioRecorder = AVAudioRecorder(url: audioURL, settings: recorderSettings)
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
        }
        
        if !audioRecorder.isRecording {
            do {
                try audioSession.setActive(true)
                audioRecorder.record()
            } catch let error as NSError {
                print(error)
            }
        }
    }
    
    // 停止录音
    func stopRecording() {
        if audioRecorder.isRecording {
            audioRecorder.stop()
            do {
                try audioSession.setActive(false)
                refreshAudioDuration()
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
    
    // 获取新录音文件的地址
    func refreshAudioURL() {
        audioCreateTime = Date()
        let formatter = DateFormatter()
        // 文件命名规范为：../年月日-时分秒.m4a
        formatter.dateFormat = "yyyyMMdd-HHmmss"
        audioName = formatter.string(from: audioCreateTime) + ".m4a"
        
        let fileManager = FileManager.default
        let urls = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
        let documentDirectory = urls[0] as URL
        audioURL = documentDirectory.appendingPathComponent(audioName)
    }
    
    func refreshAudioDuration() {
        let asset = AVURLAsset(url: audioURL)
        let time = asset.duration;
        audioDuration = Double(CMTimeGetSeconds(time))
    }
    
    // MARK: audioPlayer delegate
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        // 发送停止播放通知
        NotificationCenter.default.post(name: StopPlayingNotification, object: nil)
    }
    
}
