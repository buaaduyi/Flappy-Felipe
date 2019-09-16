//
//  GameViewController.swift
//  Flappy Felipe
//
//  Created by 杜毅 on 2018/2/27.
//  Copyright © 2018年 杜毅. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let skview = self.view as? SKView {
            if skview.scene == nil {
                //  创建场景
                let changkuanbi = skview.bounds.size.height / skview.bounds.size.width
                let changjing = GameScene(size:CGSize(width: 320, height: 320 * changkuanbi))
                skview.showsFPS = true
                skview.showsNodeCount = true
                skview.showsPhysics = true
                skview.ignoresSiblingOrder = true
                changjing.scaleMode = .aspectFill
                skview.presentScene(changjing)
            }
        }
    }
    //隐藏状态栏
    override var prefersStatusBarHidden: Bool {
        return true
    }
}

