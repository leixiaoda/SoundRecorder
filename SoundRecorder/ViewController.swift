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
    var tipsLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "录音器"
        view.backgroundColor = UIColor.init(red: 210/255.0, green: 210/255.0, blue: 210/255.0, alpha: 1)
        
        let showListBtn = UIBarButtonItem(barButtonSystemItem: .organize, target: self, action: #selector(didClickListBtn))
        navigationItem.rightBarButtonItem = showListBtn
        
        doInitUI()
        doInitData()
    }
    
    func doInitUI() {
        // 录音按钮
        recordBtn = UIButton()
        let recorderImage = UIImage(named:"recordBtn.png")
        let recordBtnSize: CGSize = recorderImage!.size
        recordBtn.frame = CGRect.init(
            x: (self.view.bounds.size.width - recordBtnSize.width) / 2.0,
            y: (self.view.bounds.size.height - recordBtnSize.height) / 2.0,
            width: recordBtnSize.width,
            height: recordBtnSize.height)
        recordBtn.setImage(recorderImage, for: .normal)
        recordBtn.alpha = 1
        recordBtn.adjustsImageWhenHighlighted = false
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(longPressOnRecordBtn(gesture:)))
        longPressGesture.minimumPressDuration = 0.1
        recordBtn.addGestureRecognizer(longPressGesture)
        recordBtn.isExclusiveTouch = true
        
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
        
        // 提示label
        tipsLabel = UILabel()
        tipsLabel.text = "录音中"
        tipsLabel.textColor = UIColor.black
        tipsLabel.font = UIFont.systemFont(ofSize: 16)
        tipsLabel.sizeToFit()
        tipsLabel.frame = CGRect.init(
            x: (self.view.frame.size.width - tipsLabel.frame.size.width) / 2,
            y: recordBtn.frame.origin.y - 40,
            width: tipsLabel.frame.size.width,
            height: tipsLabel.frame.size.height)
        tipsLabel.isHidden = true
        
        view.addSubview(tipsLabel)
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
        let result = AudioController.sharedInstance().beginRecording()
        if !result.succeed {
            let alertController = UIAlertController(title: result.errorTitle!, message: result.errorMsg!, preferredStyle: .actionSheet)
            let okAction =  UIAlertAction(title: "好的", style: .default) { (UIAlertAction) in}
            alertController.addAction(okAction)
            alertController.show(self, sender: nil)
            self.present(alertController, animated: true) {}
        } else {
            showRecordingUI()
        }
    }
    
    func stopRecording() {
        AudioController.sharedInstance().stopRecording()
        saveAudioData()
        playOrStopBtn.isHidden = false
        showStopRecordingUI()
    }
    
    func showRecordingUI() {
        recordBtn.alpha = 0.7
        
        let animation = CABasicAnimation(keyPath: "transform.scale")
        animation.duration = 0.1
        animation.fromValue = 1.0
        animation.toValue = 1.25
        animation.autoreverses = true
        recordBtn.layer.add(animation, forKey: "scale-layer")
        
        tipsLabel.isHidden = false
    }
    
    func showStopRecordingUI() {
        recordBtn.alpha = 1
        
        tipsLabel.isHidden = true
    }
    
    // 保存录音数据
    func saveAudioData() {
        let createTime = AudioController.sharedInstance().recorderAudioCreateTime!
        let name = AudioController.sharedInstance().recorderAudioName!
        let path = AudioController.sharedInstance().recorderAudioURL!.absoluteString
        let duration = AudioController.sharedInstance().recorderAudioDuration!
        
        let model = SoundModel(name: name, path: path, duration: duration, createTime: createTime)
        DataMgr.sharedInstance().storeSound(model: model)
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
            showPlayingUI()
        } else {
            showStopPlayingUI()
        }
    }
    
    func handleStopPlayingNotification(notification: Notification) {
        showStopPlayingUI()
    }
    
    func showPlayingUI() {
        playOrStopBtn.setImage(UIImage(named:"stopBtn.png"), for: .normal)
    }
    
    func showStopPlayingUI() {
        playOrStopBtn.setImage(UIImage(named:"playBtn.png"), for: .normal)
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

