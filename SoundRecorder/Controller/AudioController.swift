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

final class AudioController: NSObject, AVAudioRecorderDelegate, AVAudioPlayerDelegate {
    static let instance = AudioController()
    private override init() {}
    static func sharedInstance() -> AudioController {
        return instance
    }
    
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
    
    // 开始录音的一系列步骤
    func beginRecording() {
        // 判断是否有麦克风权限
        audioSession.requestRecordPermission { (isAllowed) in
            if !isAllowed {
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
            try audioSession.setCategory(AVAudioSessionCategoryPlayAndRecord)
            try audioRecorder = AVAudioRecorder(url: newSoundURL(), settings: recorderSettings)
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
            } catch let error as NSError {
                print(error)
            }
        }
    }
    
    // 开始播放
    func beginPlaying(url: URL?) {
        if !audioRecorder.isRecording {
            do {
                if url != nil {
                    try audioPlayer = AVAudioPlayer(contentsOf: url!)
                    audioPlayer.delegate = self
                    audioPlayer.play()
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
        beginPlaying(url: audioRecorder.url)
    }
    
    // 获取新录音文件的地址
    func newSoundURL() -> URL {
        let currentDate = Date()
        let formatter = DateFormatter()
        // 文件命名规范为：../年月日-时分秒.m4a
        formatter.dateFormat = "yyyyMMdd-HHmmss"
        let recordingName = formatter.string(from: currentDate) + ".m4a"
        
        let fileManager = FileManager.default
        let urls = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
        let documentDirectory = urls[0] as URL
        let soundURL = documentDirectory.appendingPathComponent(recordingName)
        return soundURL
    }
    
}
