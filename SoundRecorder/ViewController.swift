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
    var playBtn: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "录音器"
        view.backgroundColor = UIColor.lightGray
        
        let showListBtn = UIBarButtonItem(barButtonSystemItem: .organize, target: self, action: #selector(didClickListBtn))
        navigationItem.rightBarButtonItem = showListBtn
        
        doInitUI()
        
        // core data
        let dataMgr = DataMgr()
        
        dataMgr.deleteAllSound()
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
        recordBtn.backgroundColor = UIColor.blue
        recordBtn.layer.cornerRadius = recordBtnSize.width / 2
        recordBtn.setTitle("录音", for: .normal)
        recordBtn.titleLabel?.font = UIFont.systemFont(ofSize: 60)
        recordBtn.setTitleColor(UIColor.black, for: .normal)
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(longPressOnRecordBtn(gesture:)))
        longPressGesture.minimumPressDuration = 0.2
        recordBtn.addGestureRecognizer(longPressGesture)
        
        view.addSubview(recordBtn)
        
        // 播放按钮
        playBtn = UIButton()
        let playBtnSize: CGSize = CGSize(width: 80, height: 30)
        playBtn.frame = CGRect.init(
            x: self.view.bounds.size.width - 100,
            y: self.view.bounds.size.height - 120,
            width: playBtnSize.width,
            height: playBtnSize.height)
        playBtn.setTitle("播放", for: .normal)
        playBtn.backgroundColor = UIColor.green
        playBtn.layer.borderWidth = 2
        playBtn.layer.cornerRadius = 16.0
        playBtn.setTitleColor(UIColor.green, for: .normal)
        playBtn.addTarget(self, action: #selector(didClickPlayBtn), for: .touchUpInside)
        playBtn.isHidden = true
        
        view.addSubview(playBtn)
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
    
    func didClickPlayBtn() {
        AudioController.sharedInstance().beginPlayingTheLatest()
    }
    
    func beginRecording() {
        AudioController.sharedInstance().beginRecording()
        setRecordingUI()
    }
    
    func stopRecording() {
        AudioController.sharedInstance().stopRecording()
        saveAudioData()
        playBtn.isHidden = false
        setDefaultUI()
    }
    
    func setRecordingUI() {
        recordBtn.backgroundColor = UIColor.black
    }
    
    func setDefaultUI() {
        recordBtn.backgroundColor = UIColor.blue
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


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

