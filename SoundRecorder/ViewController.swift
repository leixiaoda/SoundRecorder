//
//  ViewController.swift
//  SoundRecorder
//
//  Created by 雷达 on 2017/2/25.
//  Copyright © 2017年 雷达. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    var recordBtn: UIButton!
    var playOrStopBtn: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "录音器"
        view.backgroundColor = UIColor.init(red: 210/255.0, green: 210/255.0, blue: 210/255.0, alpha: 1)
        
        let showListBtn = UIBarButtonItem(barButtonSystemItem: .organize, target: self, action: #selector(didClickListBtn))
        navigationItem.rightBarButtonItem = showListBtn
        
        doInitUI()
        doInitData()
        
        // core data
//        let dataMgr = DataMgr()
//        
//        dataMgr.deleteAllSound()
//
//        let array = dataMgr.getSound()
//        if array != nil {
//            print("count: \(array!.count)")
//        }        
    }
    
    func doInitUI() {
        // 录音按钮
        recordBtn = UIButton()
        let recordBtnSize: CGSize = CGSize(width: 200, height: 200)
        recordBtn.frame = CGRect.init(
            x: (self.view.bounds.size.width - recordBtnSize.width) / 2.0,
            y: (self.view.bounds.size.height - recordBtnSize.height) / 2.0,
            width: recordBtnSize.width,
            height: recordBtnSize.height)
        recordBtn.setImage(UIImage(named:"recordBtn.png"), for: .normal)
        recordBtn.alpha = 1
        recordBtn.adjustsImageWhenHighlighted = false
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(longPressOnRecordBtn(gesture:)))
        longPressGesture.minimumPressDuration = 0.1
        recordBtn.addGestureRecognizer(longPressGesture)
        
        view.addSubview(recordBtn)
        
        // 播放按钮
        playOrStopBtn = UIButton()
        let playOrStopBtnSize: CGSize = CGSize(width: 50, height: 50)
        playOrStopBtn.frame = CGRect.init(
            x: (self.view.frame.size.width - playOrStopBtnSize.width) / 2,
            y: self.view.frame.size.height - 120,
            width: playOrStopBtnSize.width,
            height: playOrStopBtnSize.height)
        playOrStopBtn.setImage(UIImage(named:"playBtn.png"), for: .normal)
        playOrStopBtn.addTarget(self, action: #selector(didClickplayOrStopBtn), for: .touchUpInside)
        playOrStopBtn.isHidden = true
        
        view.addSubview(playOrStopBtn)
    }
    
    func doInitData() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleBeginPlayingNotification(notification:)), name: BeginPlayingNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleStopPlayingNotification(notification:)), name: StopPlayingNotification, object: nil)
    }
    
    func didClickListBtn() {
        if navigationController != nil {
            let soundListVC = SoundListViewController()
            navigationController?.pushViewController(soundListVC, animated: true)
        }
    }
    
    func longPressOnRecordBtn(gesture: UILongPressGestureRecognizer) {
        if (gesture.state == .began) {
            beginRecording()
        } else if (gesture.state == .ended) {
            stopRecording()
        }
        else {
            
        }
    }
    
    func beginRecording() {
        AudioController.sharedInstance().beginRecording()
        setRecordingUI()
    }
    
    func stopRecording() {
        AudioController.sharedInstance().stopRecording()
        saveAudioData()
        playOrStopBtn.isHidden = false
        setStopRecordingUI()
    }
    
    func setRecordingUI() {
        recordBtn.alpha = 0.8
        
        let animation = CABasicAnimation(keyPath: "transform.scale")
        animation.duration = 0.1
        animation.fromValue = 1.0
        animation.toValue = 1.25
        animation.autoreverses = true
        recordBtn.layer.add(animation, forKey: "scale-layer")
    }
    
    func setStopRecordingUI() {
        recordBtn.alpha = 1
    }
    
    // 保存录音数据
    func saveAudioData() {
        let dataMgr = DataMgr()
        
        let createTime = AudioController.sharedInstance().recorderAudioCreateTime!
        let name = AudioController.sharedInstance().recorderAudioName!
        let path = AudioController.sharedInstance().recorderAudioURL!.absoluteString
        let duration = AudioController.sharedInstance().recorderAudioDuration!
        
        let model = SoundModel(name: name, path: path, duration: duration, createTime: createTime)
        dataMgr.storeSound(model: model)
    }
    
    func didClickplayOrStopBtn() {
        if AudioController.sharedInstance().currentState == .playing {
            AudioController.sharedInstance().stopPlaying()
        } else {
            AudioController.sharedInstance().beginPlayingTheLatest()
        }
    }
    
    // MARK: notification
    
    func handleBeginPlayingNotification(notification: Notification) {
        let userInfo = notification.userInfo
        if userInfo == nil {
            print("userInfo is empty.")
        }
        
        let url = userInfo!["url"] as? URL
        if url == nil {
            print("url is empty.")
        }
        
        if AudioController.sharedInstance().playerAudioURL == url! {
            setPlayingUI()
        } else {
            setStopPlayingUI()
        }
    }
    
    func handleStopPlayingNotification(notification: Notification) {
        setStopPlayingUI()
    }
    
    func setPlayingUI() {
        playOrStopBtn.setImage(UIImage(named:"stopBtn.png"), for: .normal)
    }
    
    func setStopPlayingUI() {
        playOrStopBtn.setImage(UIImage(named:"playBtn.png"), for: .normal)
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

