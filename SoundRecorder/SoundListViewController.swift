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
    
    func didClickBackBtn() {
        if navigationController != nil {
            navigationController!.popViewController(animated: true)
        }
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
            if AudioController.sharedInstance().currentState == .playing && AudioController.sharedInstance().playerAudioURL.absoluteString == item?.path {
                (cell as! SoundCell).setPlayState(state: .playing)
            } else {
                (cell as! SoundCell).setPlayState(state: .stop)
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item: SoundModel? = soundList[indexPath.row]
        let url = URL(string: item!.path)
        
        if AudioController.sharedInstance().currentState == .playing && url == AudioController.sharedInstance().playerAudioURL {
            AudioController.sharedInstance().stopPlaying()
        } else {
            AudioController.sharedInstance().beginPlaying(url: url)
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return .delete
    }
    
    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "删除"
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        let item: SoundModel? = soundList[indexPath.row]
        
        // 数据删除
        let dataMgr = DataMgr()
        dataMgr.deleteSound(pathDemand: item!.path)
        soundList = dataMgr.getSound()
        
        // 文件删除
        let fileManager = FileManager.default
        do {
            try fileManager.removeItem(atPath: item!.path)
        } catch let error as NSError {
            print(error)
        }
        
        // UI删除
        tableView.deleteRows(at: [indexPath], with: .fade)
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
        
        for cell in soundListView.visibleCells {
            if cell.isKind(of: SoundCell.self) && (cell as! SoundCell).soundModel.path == url!.absoluteString {
                (cell as! SoundCell).setPlayState(state: .playing)
            } else {
                (cell as! SoundCell).setPlayState(state: .stop)
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

