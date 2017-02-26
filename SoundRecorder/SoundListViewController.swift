//
//  SoundListViewController.swift
//  SoundRecorder
//
//  Created by 雷达 on 2017/2/26.
//  Copyright © 2017年 雷达. All rights reserved.
//

import UIKit

let CELL_HEIGHT: CGFloat = 60

class SoundListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let SOUND_CELL_IDENTIFIER: String = "soundCellIdentifier"
    
    var soundListView: UITableView!
    var soundList: [SoundModel]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "录音列表"
        view.backgroundColor = UIColor.white
        
        let backBtn = UIBarButtonItem(barButtonSystemItem: .reply, target: self, action: #selector(didClickBackBtn))
        navigationItem.leftBarButtonItem = backBtn
        
        doInitUI()
        doInitData()
    }
    
    func didClickBackBtn() {
        if navigationController != nil {
            navigationController!.popViewController(animated: true)
        }
    }
    
    func doInitUI() {
        soundListView = UITableView(frame: view.frame, style: .plain)
        soundListView.dataSource = self
        soundListView.delegate = self
        soundListView.bounces = true
        
        view.addSubview(soundListView)
    }
    
    func doInitData() {
        let dataMgr = DataMgr()
        soundList = dataMgr.getSound()
        
        soundListView.register(SoundCell.self, forCellReuseIdentifier: SOUND_CELL_IDENTIFIER)
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleBeginPlayingNotification(notification:)), name: BeginPlayingNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleStopPlayingNotification(notification:)), name: StopPlayingNotification, object: nil)
    }
    
    // MARK: tableView delegate
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return soundList.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CELL_HEIGHT
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: SOUND_CELL_IDENTIFIER, for: indexPath)
        
        let item: SoundModel? = soundList[indexPath.row]
        // undone
//        if item != nil && cell.responds(to: Selector("setModel:")) {
//            cell.perform(Selector("setModel()"), with: item)
//        }        
        if item != nil && cell.isKind(of: SoundCell.self) {
            (cell as! SoundCell).setModel(model: item!)
            
            let player = AudioController.sharedInstance().audioPlayer
            if player != nil && player!.isPlaying && player!.url?.absoluteString == item?.path {
                (cell as! SoundCell).setPlayState(state: .playing)
            } else {
                (cell as! SoundCell).setPlayState(state: .stop)
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let item: SoundModel? = soundList[indexPath.row]
        let url = URL(string: item!.path)
        AudioController.sharedInstance().beginPlaying(url: url)
    }
    
    // MARK: notification
    
    func handleBeginPlayingNotification(notification: Notification) {
        let userInfo = notification.userInfo
        if userInfo == nil {
            print("userInfo is empty.")
        }
        
        let createTime = userInfo!["createTime"] as? Date
        if createTime == nil {
            print("createTime is empty.")
        }
        
        for cell in soundListView.visibleCells {
            if cell.isKind(of: SoundCell.self) && (cell as! SoundCell).soundModel.createTime == createTime! {
                (cell as! SoundCell).setPlayState(state: .playing)
            }
        }
    }
    
    func handleStopPlayingNotification(notification: Notification) {
        for cell in soundListView.visibleCells {
            if cell.isKind(of: SoundCell.self) {
                (cell as! SoundCell).setPlayState(state: .stop)
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: BeginPlayingNotification, object: nil);
        NotificationCenter.default.removeObserver(self, name: StopPlayingNotification, object: nil);
    }
}

