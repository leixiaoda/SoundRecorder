//
//  SoundListViewController.swift
//  SoundRecorder
//
//  Created by 雷达 on 2017/2/26.
//  Copyright © 2017年 雷达. All rights reserved.
//

import UIKit

class SoundListViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "录音列表"
        view.backgroundColor = UIColor.white
        
        let backBtn = UIBarButtonItem(barButtonSystemItem: .reply, target: self, action: #selector(didClickBackBtn))
        navigationItem.leftBarButtonItem = backBtn
        
        doInitUI()
        
        
        // core data
        let dataMgr = DataMgr()
        //        let model1 = SoundModel(name: "clips1", path: "../../clips1.mp4", duration: 4.688, createTime: Date())
        //        let model2 = SoundModel(name: "clips2", path: "../../clips2.mp4", duration: 1.23, createTime: Date())
        
        //        dataMgr.storeSound(model: model1)
        //        dataMgr.storeSound(model: model2)
        
        //        dataMgr.deleteAllSound()
        //
        //        let array = dataMgr.getSound()
        //        if array != nil {
        //            print("count: \(array!.count)")
        //        }
    }
    
    func didClickBackBtn() {
        navigationController?.popViewController(animated: true)
    }
    
    func doInitUI() {
        
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

