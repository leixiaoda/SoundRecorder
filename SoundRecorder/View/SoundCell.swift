//
//  SoundCell.swift
//  SoundRecorder
//
//  Created by 雷达 on 2017/2/26.
//  Copyright © 2017年 雷达. All rights reserved.
//

import Foundation
import UIKit

enum PlayState {
    case playing
    case stop
}

class SoundCell: UITableViewCell {
    
    // 数据源
    var soundModel: SoundModel!
    // 音频名称
    var titleLabel: UILabel!
    // 播放状态按钮
    var playOrStopBtn: UIButton!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        doInitUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func doInitUI() {
        titleLabel = UILabel()
        titleLabel.text = "无标题"
        titleLabel.textColor = UIColor.black
        titleLabel.font = UIFont.systemFont(ofSize: 16)
        titleLabel.sizeToFit()
        titleLabel.frame = CGRect.init(x: 30, y: (CELL_HEIGHT - titleLabel.frame.size.height) / 2, width: UIScreen.main.bounds.width - 80, height: titleLabel.frame.size.height)
        self.addSubview(titleLabel)
        
        let buttonSize = CGSize(width: 30, height: 30)
        playOrStopBtn = UIButton(frame: CGRect.init(x: UIScreen.main.bounds.width - buttonSize.width - 30, y: (CELL_HEIGHT - buttonSize.height) / 2, width: buttonSize.width, height: buttonSize.height))
        playOrStopBtn.backgroundColor = UIColor.green
        self.addSubview(playOrStopBtn)
    }
    
    func setModel(model: SoundModel) {
        soundModel = model
        refreshUI()
    }
    
    func refreshUI() {
        titleLabel.text = soundModel.name
    }
    
    func setPlayState(state: PlayState) {
        if state == .playing {
            setPlayingUI()
        } else if state == .stop {
            setStopUI()
        }
    }
    
    private func setPlayingUI() {
        playOrStopBtn.backgroundColor = UIColor.black
    }
    
    private func setStopUI() {
        playOrStopBtn.backgroundColor = UIColor.green
    }
}
