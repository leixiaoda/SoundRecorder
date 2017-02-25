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
        
        // core data
        let dataMgr = DataMgr()
        let model1 = SoundModel(name: "clips1", path: "../../clips1.mp4", duration: 4.688)
        let model2 = SoundModel(name: "clips2", path: "../../clips2.mp4", duration: 1.23)
        
//        dataMgr.storeSound(model: model1)
//        dataMgr.storeSound(model: model2)
        let array = dataMgr.getSound()
        if array != nil {
            print("count: \(array!.count)")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

