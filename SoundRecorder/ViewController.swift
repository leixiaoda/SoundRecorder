//
//  ViewController.swift
//  SoundRecorder
//
//  Created by 雷达 on 2017/2/25.
//  Copyright © 2017年 雷达. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

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
    
    func didClickListBtn() {
        if navigationController != nil {
            let soundListVC = SoundListViewController()
            navigationController?.pushViewController(soundListVC, animated: true)
        }
    }
    
    func doInitUI() {
        // 录音按钮
        let recordBtn: UIButton = UIButton()
        let recordBtnSize: CGSize = CGSize(width: 80, height: 30)
        recordBtn.frame = CGRect.init(x: (self.view.bounds.size.width - recordBtnSize.width) / 2.0, y: self.view.bounds.size.height - 200, width: recordBtnSize.width, height: recordBtnSize.height)
        recordBtn.setTitle("录音", for: .normal)
        recordBtn.backgroundColor = UIColor.red
        recordBtn.layer.borderWidth = 2
        recordBtn.layer.cornerRadius = 16.0
        recordBtn.setTitleColor(UIColor.black, for: .normal)
        recordBtn.addTarget(self, action: #selector(didClickRecordBtn), for: .touchUpInside)
        
        view.addSubview(recordBtn)
        
        // 结束录音按钮
        let stopBtn: UIButton = UIButton()
        let stopBtnSize: CGSize = CGSize(width: 80, height: 30)
        stopBtn.frame = CGRect.init(x: (self.view.bounds.size.width - stopBtnSize.width) / 2.0, y: self.view.bounds.size.height - 120, width: stopBtnSize.width, height: stopBtnSize.height)
        stopBtn.setTitle("结束", for: .normal)
        stopBtn.backgroundColor = UIColor.blue
        stopBtn.layer.borderWidth = 2
        stopBtn.layer.cornerRadius = 16.0
        stopBtn.setTitleColor(UIColor.black, for: .normal)
        stopBtn.addTarget(self, action: #selector(didClickStopBtn), for: .touchUpInside)
        
        view.addSubview(stopBtn)
        
        // 播放按钮
        let playBtn: UIButton = UIButton()
        let playBtnSize: CGSize = CGSize(width: 80, height: 30)
        playBtn.frame = CGRect.init(x: self.view.bounds.size.width - 100, y: self.view.bounds.size.height - 120, width: playBtnSize.width, height: playBtnSize.height)
        playBtn.setTitle("播放", for: .normal)
        playBtn.backgroundColor = UIColor.green
        playBtn.layer.borderWidth = 2
        playBtn.layer.cornerRadius = 16.0
        playBtn.setTitleColor(UIColor.green, for: .normal)
        playBtn.addTarget(self, action: #selector(didClickPlayBtn), for: .touchUpInside)
        
        view.addSubview(playBtn)
    }
    
    func didClickRecordBtn() {
        AudioController.sharedInstance().beginRecording()
    }
    
    func didClickStopBtn() {
        AudioController.sharedInstance().stopRecording()
        saveAudioData()
    }
    func didClickPlayBtn() {
        AudioController.sharedInstance().beginPlayingTheLatest()
    }
    
    // 保存录音数据
    func saveAudioData() {
        let dataMgr = DataMgr()
        
        let createTime = AudioController.sharedInstance().audioCreateTime!
        let name = AudioController.sharedInstance().audioName!
        let path = AudioController.sharedInstance().audioURL!.absoluteString
        let duration = AudioController.sharedInstance().audioDuration!
        
        let model = SoundModel(name: name, path: path, duration: duration, createTime: createTime)
        dataMgr.storeSound(model: model)
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

