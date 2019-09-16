//
//  GameScene.swift
//  Flappy Felipe
//
//  Created by 杜毅 on 2018/2/27.
//  Copyright © 2018年 杜毅. All rights reserved.
//

import SpriteKit
import GameplayKit
//图层枚举
enum tuceng: CGFloat {
    case pathline
    case beijing
    case block
    case qianjing
    case gameplayer
    case UI
}
//游戏状态枚举
enum status{
    case menu
    case course
    case game
    case fall
    case score
    case end
}
//物理层掩码
struct physics {
    static let none: UInt32 = 0
    static let player: UInt32 =     0b1 // 1
    static let block: UInt32 =  0b10 // 2
    static let ground: UInt32 =   0b100 // 4
    static let coin: UInt32 = 0b1000//8
}


class GameScene: SKScene,SKPhysicsContactDelegate {
    
    //常量声明
    let world = SKNode()
    let g=CGFloat(-800.0)//重力加速度
    let Vup=CGFloat(300.0)//小鸟向上飞的速度
    let K=2//前景地面数
    let Vground=CGFloat(-100.0)//地面移动速度
    let bird = SKSpriteNode(imageNamed: "Bird0")//导入小鸟
    let cap = SKSpriteNode(imageNamed: "Sombrero")//导入帽子
    let quekouchangshu=CGFloat(3.5)//开口为小鸟大小的3.5倍
    let pi=CGFloat(3.1415926)//定义π
    let firstcreatblocktimeinterval=TimeInterval(1.75)//第一次生成障碍延迟
    let everycreatblocktimeinterval=TimeInterval(1.5)//每次生成障碍延迟
    let topblank = CGFloat(30.0)
    let typeface = "AmericanTypewriter-Bold"
    let movieinterval = 0.3
    //变量声明
    var gamebeginpoint: CGFloat = 0
    var gameareahight: CGFloat = 0
    var lasttimeupdate:TimeInterval=0
    var dt:TimeInterval=0
    var y:CGFloat=0
    var v:CGFloat=0
    var hitground = false//bool
    var hitblock = false//bool
    var getcoin = false//bool
    var nowstatus:status = .game
    var scorelabel = SKLabelNode()//得分栏
    var nowscore = 0//当前分数
    //  创建音效
    let ding = SKAction.playSoundFileNamed("ding.wav", waitForCompletion: false)
    let flapping = SKAction.playSoundFileNamed("flapping.wav", waitForCompletion: false)
    let whack = SKAction.playSoundFileNamed("whack.wav", waitForCompletion: false)
    let falling = SKAction.playSoundFileNamed("falling.wav", waitForCompletion: false)
    let hitGround = SKAction.playSoundFileNamed("hitGround.wav", waitForCompletion: false)
    let pop = SKAction.playSoundFileNamed("pop.wav", waitForCompletion: false)
    let coin = SKAction.playSoundFileNamed("coin.wav", waitForCompletion: false)
    //游戏设置
    //设置背景
    func setbackground() {
        
        let beijing = SKSpriteNode(imageNamed: "Background")
        beijing.anchorPoint = CGPoint(x: 0.5, y: 1.0)
        beijing.position = CGPoint(x: size.width/2, y: size.height)
        beijing.zPosition = tuceng.beijing.rawValue
        world.addChild(beijing)
        gamebeginpoint = size.height - beijing.size.height
        gameareahight = beijing.size.height
        
        let leftdown = CGPoint(x:0,y:gamebeginpoint)
        let rightdown = CGPoint(x:size.width,y:gamebeginpoint)
        self.physicsBody = SKPhysicsBody(edgeFrom:leftdown,to:rightdown)
        self.physicsBody?.categoryBitMask = physics.ground
        self.physicsBody?.collisionBitMask = 0
        self.physicsBody?.contactTestBitMask = physics.player
        
        
    }
    //设置前景
    func setqianjing(){
        for  i in 0..<K{
            let qianjing = SKSpriteNode(imageNamed: "Ground")
            qianjing.anchorPoint = CGPoint(x: 0, y: 1.0)
            qianjing.position = CGPoint(x: CGFloat(i)*qianjing.size.width, y: gamebeginpoint)
            qianjing.zPosition = tuceng.qianjing.rawValue
            qianjing.name="qianjing"
            world.addChild(qianjing)
            
            //iphoneX适配
            let qianjing2 = SKSpriteNode(imageNamed: "Ground2")
            qianjing2.anchorPoint = CGPoint(x: 0, y: 1.0)
            qianjing2.position = CGPoint(x:CGFloat(i)*qianjing2.size.width,y:gamebeginpoint-qianjing2.size.height)
            qianjing2.zPosition = tuceng.qianjing.rawValue
            qianjing2.name="qianjing2"
            world.addChild(qianjing2)
            //iphoneX适配
        }
    }
    //设置小鸟
    func setbird(){
        
        bird.position = CGPoint(x:size.width*0.2,y:gameareahight*0.5+gamebeginpoint)
        bird.zPosition = tuceng.gameplayer.rawValue
        
        //设置碰撞体积
        let offsetX = bird.size.width * bird.anchorPoint.x
        let offsetY = bird.size.height * bird.anchorPoint.y
        let path = CGMutablePath()
        path.move(to: CGPoint(x:  7 - offsetX, y: 18 - offsetY))
        path.addLine(to: CGPoint(x: 13 - offsetX, y: 23 - offsetY))
        path.addLine(to: CGPoint(x: 21 - offsetX, y: 27 - offsetY))
        path.addLine(to: CGPoint(x: 37 - offsetX, y: 26 - offsetY))
        path.addLine(to: CGPoint(x: 39 - offsetX, y: 13 - offsetY))
        path.addLine(to: CGPoint(x: 33 - offsetX, y: 3 - offsetY))
        path.addLine(to: CGPoint(x: 22 - offsetX, y: 1 - offsetY))
        path.addLine(to: CGPoint(x: 6 - offsetX, y: 1 - offsetY))
        path.addLine(to: CGPoint(x: 3 - offsetX, y: 7 - offsetY))
        path.closeSubpath()
        bird.physicsBody = SKPhysicsBody(polygonFrom: path)
        bird.physicsBody?.categoryBitMask = physics.player
        bird.physicsBody?.collisionBitMask = 0
        bird.physicsBody?.contactTestBitMask = physics.block|physics.ground
        world.addChild(bird)
    }
    
    //设置帽子
    //  func setcap(){
    //      cap.position = CGPoint(x: 31-cap.size.width/2, y: 29-cap.size.height/2)
    //   bird.addChild(cap)
    //      }
    //设置得分标签
    func setscorelabel(){
        scorelabel = SKLabelNode(fontNamed: typeface)
        scorelabel.fontColor = SKColor.init(red: 101.0/255.0, green: 71.0/255.0, blue: 73.0/255.0, alpha: 1.0)
        scorelabel.position = CGPoint(x:size.width/2,y:size.height-topblank)
        scorelabel.verticalAlignmentMode = .top
        scorelabel.text = "0"
        scorelabel.zPosition = tuceng.UI.rawValue
        world.addChild(scorelabel)
    }
    //设置教程
    func setcourse(){
        let course = SKSpriteNode(imageNamed: "Tutorial")
        course.position = CGPoint(x:size.width*0.5,y:gameareahight*0.4+gamebeginpoint)
        course.name = "course"
        course.zPosition = tuceng.UI.rawValue
        world.addChild(course)
        
        let ready = SKSpriteNode(imageNamed: "Ready")
        ready.position = CGPoint(x:size.width*0.5,y:gameareahight*0.7+gamebeginpoint)
        ready.name = "course"
        ready.zPosition = tuceng.UI.rawValue
        world.addChild(ready)
        
        
        
    }
    
    //设置主菜单
    func setmenu(){
        //设置logo
        let logo = SKSpriteNode(imageNamed: "Logo")
        logo.position = CGPoint(x:size.width/2,y:gamebeginpoint+gameareahight*0.75)
        logo.name = "menu"
        logo.zPosition = tuceng.UI.rawValue
        world.addChild(logo)
        //设置play按钮
        let playbutton = SKSpriteNode(imageNamed: "Button")
        playbutton.position = CGPoint(x:size.width/4,y:size.height/4)
        playbutton.name = "menu"
        playbutton.zPosition = tuceng.UI.rawValue
        world.addChild(playbutton)
        
        let play = SKSpriteNode(imageNamed: "Play")
        play.position = CGPoint.zero
        play.zPosition = tuceng.UI.rawValue
        playbutton.addChild(play)
        //设置rate按钮
        let ratebutton = SKSpriteNode(imageNamed: "Button")
        ratebutton.position = CGPoint(x:size.width*0.75,y:size.height/4)
        ratebutton.name = "menu"
        ratebutton.zPosition = tuceng.UI.rawValue
        world.addChild(ratebutton)
        let rate = SKSpriteNode(imageNamed: "Rate")
        rate.position = CGPoint.zero
        rate.zPosition = tuceng.UI.rawValue
        ratebutton.addChild(rate)
        
        let learn = SKSpriteNode(imageNamed: "button_learn")
        learn.position = CGPoint(x:size.width/2,y:size.height*0.1)
        learn.name = "menu"
        learn.zPosition = tuceng.UI.rawValue
        world.addChild(learn)
        
        //放大缩小动画
        let magnify = SKAction.scale(by: 1.02, duration: 0.75)
        magnify.timingMode = .easeInEaseOut
        let shrink = SKAction.scale(by: 0.98, duration: 0.75)
        shrink.timingMode = .easeInEaseOut
        learn.run(SKAction.repeatForever(SKAction.sequence([magnify,shrink])))
    }
    
    //设置计分板
    func setscoreboard(){
        if nowscore>best(){
            setbest(best: nowscore)
        }
        let scoreboard = SKSpriteNode(imageNamed: "Scorecard")
        scoreboard.position = CGPoint(x:size.width/2,y:size.height/2)
        scoreboard.zPosition = tuceng.UI.rawValue
        world.addChild(scoreboard)
        
        //设置当前分计分板
        let nowscorelabel = SKLabelNode(fontNamed: typeface)
        nowscorelabel.fontColor = SKColor.init(red: 101.0/255.0, green: 71.0/255.0, blue: 73.0/255.0, alpha: 1.0)
        nowscorelabel.position = CGPoint(x:-scoreboard.size.width/4,y:-scoreboard.size.height/3 )
        nowscorelabel.text = "\(nowscore)"
        nowscorelabel.zPosition = tuceng.UI.rawValue
        scoreboard.addChild(nowscorelabel)
        //设置最高分计分板
        let bestscorelabel = SKLabelNode(fontNamed: typeface)
        bestscorelabel.fontColor = SKColor.init(red: 101.0/255.0, green: 71.0/255.0, blue: 73.0/255.0, alpha: 1.0)
        bestscorelabel.position = CGPoint(x:scoreboard.size.width/4,y:-scoreboard.size.height/3 )
        bestscorelabel.text = "\(best())"
        bestscorelabel.zPosition = tuceng.UI.rawValue
        scoreboard.addChild(bestscorelabel)
        //设置"GameOver"图标
        let gameover = SKSpriteNode(imageNamed: "GameOver")
        gameover.position = CGPoint(x:size.width/2,y:size.height/2+scoreboard.size.height/2+topblank*2+gameover.size.height/2 )
        gameover.zPosition = tuceng.UI.rawValue
        world.addChild(gameover)
        
        //设置ok按钮
        let okbutton = SKSpriteNode(imageNamed: "Button")
        okbutton.position = CGPoint(x:size.width/4,y:size.height/2-scoreboard.size.height/2-topblank-okbutton.size.height/2)
        okbutton.zPosition = tuceng.UI.rawValue
        world.addChild(okbutton)
        
        let ok = SKSpriteNode(imageNamed: "OK")
        ok.position = CGPoint.zero
        ok.zPosition = tuceng.UI.rawValue
        okbutton.addChild(ok)
        //设置share按钮
        let sharebutton = SKSpriteNode(imageNamed: "ButtonRight")
        sharebutton.position = CGPoint(x:size.width*0.75,y:size.height/2-scoreboard.size.height/2-topblank-okbutton.size.height/2)
        sharebutton.zPosition = tuceng.UI.rawValue
        world.addChild(sharebutton)
        
        let share = SKSpriteNode(imageNamed: "Share")
        share.position = CGPoint.zero
        share.zPosition = tuceng.UI.rawValue
        sharebutton.addChild(share)
        
        gameover.setScale(0)
        gameover.alpha = 0
        let movie = SKAction.group([
            SKAction.fadeIn(withDuration: movieinterval),
            SKAction.scale(to: 1.0, duration: movieinterval)
            ])
        movie.timingMode = .easeInEaseOut
        gameover.run(SKAction.sequence([SKAction.wait(forDuration: movieinterval),movie]))
        scoreboard.position = CGPoint(x:size.width/2,y:-scoreboard.size.height/2)
        
        let moveup = SKAction.move(to: CGPoint(x:size.width/2,y:size.height/2), duration: movieinterval)
        
        moveup.timingMode = .easeInEaseOut
        scoreboard.run(SKAction.sequence([SKAction.wait(forDuration: movieinterval*2),moveup]))
        
        okbutton.alpha = 0
        sharebutton.alpha = 0
        let jianbian = SKAction.sequence([SKAction.wait(forDuration: movieinterval*3),SKAction.fadeIn(withDuration: movieinterval)
            ])
        okbutton.run(jianbian)
        sharebutton.run(jianbian)
        
        let shengyin = SKAction.sequence([
            SKAction.wait(forDuration: movieinterval),
            pop,
            SKAction.wait(forDuration: movieinterval),
            pop,
            SKAction.wait(forDuration: movieinterval),
            pop,
            SKAction.run(skiptoend)
            ])
        run(shengyin)
    }
    
    
    
    //游戏流程
    //创建障碍物
    func buildblock(image:String)->SKSpriteNode{
        let block=SKSpriteNode(imageNamed:image)
        block.zPosition=tuceng.block.rawValue
        block.userData = NSMutableDictionary()
        //设置障碍物碰撞体积
        let offsetX = block.size.width * block.anchorPoint.x
        let offsetY = block.size.height * block.anchorPoint.y
        let path = CGMutablePath()
        path.move(to: CGPoint(x:  3 - offsetX, y: 4 - offsetY))
        path.addLine(to: CGPoint(x: 6 - offsetX, y: 110 - offsetY))
        path.addLine(to: CGPoint(x: 8 - offsetX, y: 266 - offsetY))
        path.addLine(to: CGPoint(x: 8 - offsetX, y: 307 - offsetY))
        path.addLine(to: CGPoint(x: 42 - offsetX, y: 306 - offsetY))
        path.addLine(to: CGPoint(x: 46 - offsetX, y: 164 - offsetY))
        path.addLine(to: CGPoint(x: 44 - offsetX, y: 4 - offsetY))
        path.closeSubpath()
    
        block.physicsBody = SKPhysicsBody(polygonFrom: path)
        block.physicsBody?.categoryBitMask = physics.block
        block.physicsBody?.collisionBitMask = 0
        block.physicsBody?.contactTestBitMask = physics.player
        return block
    }
    //生成障碍物
    func creatblock(){
        //底部障碍物
        let bottomblock=buildblock(image: "CactusBottom")
        let startx=size.width+bottomblock.size.width/2
        let max: UInt32 = 60//底部障碍物Y轴位置系数最大值
        let min: UInt32 = 10//底部障碍物Y轴位置系数最小值
        let h1=CGFloat(arc4random_uniform(max - min) + min)//生成10~60之间的随机数
        let h2=CGFloat(h1/100)
        let bottomblocky=(gamebeginpoint-bottomblock.size.height/2)+gameareahight*h2
        bottomblock.position=CGPoint(x:startx, y:bottomblocky)
        bottomblock.name = "bottomblock"
        world.addChild(bottomblock)
        //顶部障碍物
        let topblock=buildblock(image:"CactusTop")
        topblock.zRotation=pi//翻转180度
        topblock.position=CGPoint(x:startx, y:bottomblock.position.y+bottomblock.size.height/2+topblock.size.height/2+bird.size.height*quekouchangshu)
        topblock.name = "topblock"
        world.addChild(topblock)
        let dx = -(size.width+bottomblock.size.width)
        let movetime = dx/Vground
        let actionarray=SKAction.sequence([
            SKAction.moveBy(x: dx, y: 0, duration: TimeInterval(movetime)),
            SKAction.removeFromParent()
            ])
        topblock.run(actionarray)
        bottomblock.run(actionarray)
    }
    //设置金币(帽子代替)
    func buildcoin(){
        let coin = SKSpriteNode(imageNamed: "Sombrero")
        
        
        let max: UInt32 = 80//金币高度系数最大值
        let min: UInt32 = 40//金币高度系数最小值
        let h1=CGFloat(arc4random_uniform(max - min) + min)//生成40~70之间的随机数
        let h2=CGFloat(h1/100)
        let coiny=size.height*h2
        coin.position = CGPoint(x:size.width,y:coiny)
        coin.zPosition = tuceng.gameplayer.rawValue
        //设置coin物理体积
        let offsetX = coin.size.width * coin.anchorPoint.x
        let offsetY = coin.size.height * coin.anchorPoint.y
        let path = CGMutablePath()
        path.move(to: CGPoint(x:  2 - offsetX, y: 12 - offsetY))
        path.addLine(to: CGPoint(x: 17 - offsetX, y: 22 - offsetY))
        path.addLine(to: CGPoint(x: 34 - offsetX, y: 21 - offsetY))
        path.addLine(to: CGPoint(x: 42 - offsetX, y: 10 - offsetY))
        path.addLine(to: CGPoint(x: 34 - offsetX, y: 0 - offsetY))
        path.addLine(to: CGPoint(x: 2 - offsetX, y: 1 - offsetY))
        path.closeSubpath()
        coin.physicsBody = SKPhysicsBody(polygonFrom: path)
        coin.physicsBody?.categoryBitMask = physics.coin
        coin.physicsBody?.collisionBitMask = 0
        coin.physicsBody?.contactTestBitMask = physics.player
        coin.name = "jinbi"
        world.addChild(coin)
        let dx = -(size.width+coin.size.width)
        let movetime = dx/Vground
        let actionarray=SKAction.sequence([
            SKAction.moveBy(x: dx, y: 0, duration: TimeInterval(movetime)),
            SKAction.removeFromParent()
            ])
        coin.run(actionarray,withKey:"reborncoin")
    }
    
    //重生障碍
    func rebornblock(){
        let firstinterval = SKAction.wait(forDuration: firstcreatblocktimeinterval)
        let reborn = SKAction.run(creatblock)
        let everyreborninterval = SKAction.wait(forDuration: everycreatblocktimeinterval)
        let rebornactionarray = SKAction.sequence([reborn,everyreborninterval])
        let infinitereborn = SKAction.repeatForever(rebornactionarray)
        let allaction = SKAction.sequence([firstinterval,infinitereborn])
        run(allaction,withKey:"reborn")
    }
    //重生金币
    func reborncoin(){
        let firstinterval = SKAction.wait(forDuration:firstcreatblocktimeinterval*5)
        let reborncoin = SKAction.run(buildcoin)
        let everyreborninterval = SKAction.wait(forDuration: everycreatblocktimeinterval*4)
        let rebornactionarray = SKAction.sequence([reborncoin,everyreborninterval])
        let infinitereborn = SKAction.repeatForever(rebornactionarray)
        let allaction = SKAction.sequence([firstinterval,infinitereborn])
        run(allaction,withKey:"reborncoin")
    }
    //停止重生
    func stopreborn(){
        removeAction(forKey: "reborn" )
        removeAction(forKey: "reborncoin")
        world.enumerateChildNodes(withName: "bottomblock") { node, stop in
            node.removeAllActions()
        }
        world.enumerateChildNodes(withName: "topblock") { node, stop in
            node.removeAllActions()
        }
        world.enumerateChildNodes(withName: "jinbi") { node, stop in
            node.removeAllActions()
        }
    }
    //小鸟向上飞
    func birdfly()
    {
        v=Vup
        run(flapping)//飞翔音效
       
        //    capmove()
        
    }
    //帽子跳动
    //   func capmove(){
    
    //      let capmoveup = SKAction.moveBy(x: 0, y: 12, duration: 0.15)
    //       capmoveup.timingMode = .easeInEaseOut
    //       let capmovedown = capmoveup.reversed()
    //      cap.run(SKAction.sequence([capmoveup,capmovedown]))
    //
    //    }
    //煽动翅膀
    func setbirdanimation() {
        
        var textures: Array<SKTexture> = []
        // 我们有4张图片
        for i in 0..<4 {
            textures.append(SKTexture(imageNamed: "Bird\(i)"))
        }
        for i in stride(from:3,through:0,by:-1)
        {
            textures.append(SKTexture(imageNamed: "Bird\(i)"))
        }
        let birdanimation = SKAction.animate(with: textures, timePerFrame: 0.07)
        bird.run(SKAction.repeatForever(birdanimation))
    }
    //点击屏幕触发
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else{
            return
        }
        let touchplace = touch.location(in: self)
        switch nowstatus{
        case.menu:
            
            if touchplace.y<size.height*0.15{
                gotolearn()
            }
            else if touchplace.x<size.width/2{
                skiptocourse()
            }
            else{
                gotorate()
            }
            break
        case.course:
            skiptogame()
            break
        case.game:
            birdfly()//飞一下
            break
        case.fall:
            
            break
        case.score:
            break
        case.end:
            skiptonewgame()
            break
        }
        
    }
    
    //时间更新
    override func update(_ nowtime: TimeInterval) {
        if lasttimeupdate>0{
            dt=nowtime-lasttimeupdate
            
        }
        else{
            dt=0
        }
        lasttimeupdate=nowtime
        
        switch nowstatus{
        case.menu:
            break
        case.course:
            break
        case.game:
            updateqianjing()
            updateposition()
            checkcollision()
            checkground()
            checkcoin()
            updatescore()
            break
        case.fall:
            updateposition()
            checkground()
            break
        case.score:
            break
        case.end:
            break
        }
    }
    //位置更新
    func updateposition(){
        let DT=CGFloat(dt)
        v=v+g*DT
        y=y+v*DT
        bird.position=CGPoint(x: size.width*0.2, y: gameareahight*0.4+gamebeginpoint+y)
        //检测是否撞击地面
        if bird.position.y-bird.size.height/2<gamebeginpoint
        {
            bird.position=CGPoint(x:bird.position.x,y:bird.size.height/2+gamebeginpoint)
        }
    }
    //使地面滚动
    func updateqianjing() {
        world.enumerateChildNodes(withName: "qianjing") { (node, stop) -> Void in
            //2
            if let qianjing = node as? SKSpriteNode{
                //3
                let moveAmt = CGPoint(x:self.Vground * CGFloat(self.dt),y: 0)
                qianjing.position.x+=moveAmt.x
                qianjing.position.y+=moveAmt.y
                //4
                if qianjing.position.x < -qianjing.size.width{
                    qianjing.position.x+=qianjing.size.width * CGFloat(2)
                    qianjing.position.y+=CGFloat(0)
                }
            }
        }
        
        //iphoneX适配
        world.enumerateChildNodes(withName: "qianjing2") { (node, stop) -> Void in
            //2
            if let qianjing2 = node as? SKSpriteNode{
                //3
                let moveAmt2 = CGPoint(x:self.Vground * CGFloat(self.dt),y: 0)
                qianjing2.position.x+=moveAmt2.x
                qianjing2.position.y+=moveAmt2.y
                //4
                if qianjing2.position.x < -qianjing2.size.width{
                    qianjing2.position.x+=qianjing2.size.width * CGFloat(2)
                    qianjing2.position.y+=CGFloat(0)
                }
            }
        }
        //iphoneX适配
        
    }
    
    
    //游戏状态切换
    
    //撞击障碍物检测
    func checkcollision(){
        if hitblock{
            skiptofall()
            hitblock = false
            
        }
    }
    //撞击地面检查
    func checkground(){
        if hitground{
            hitground = false
            v = CGFloat(0)
            bird.position = CGPoint(x:bird.position.x,y:gamebeginpoint+bird.size.width/2)
            run(hitGround)
            skiptoscore()
        }
    }
    //金币检测
    func checkcoin(){
        if getcoin{
            getcoin = false
            nowscore=nowscore+5
            scorelabel.text="\(nowscore)"
            run(coin)
            world.enumerateChildNodes(withName: "jinbi") { (node, stop) -> Void in
                node.run(SKAction.sequence([
                    SKAction.fadeOut(withDuration: 0.05),
                    SKAction.removeFromParent()
                    ]))
                
            }
        }
        
    }
    //检查得分>100?
    func checkscore(){
        if nowscore>100{
            
        }
    }
    
    
    //当前得分
    func updatescore(){
        world.enumerateChildNodes(withName: "topblock") { (node, stop) -> Void in
            if let block = node as? SKSpriteNode{
                if let havepassed = block.userData!["havepassed"] as? NSNumber{
                    if havepassed.boolValue{
                        return //已经计算过得分
                    }
                }
                if self.bird.position.x>block.position.x+block.size.width/2{
                    self.nowscore=self.nowscore+1
                    self.scorelabel.text="\(self.nowscore)"
                    self.run(self.coin)
                    block.userData?["havepassed"] = NSNumber(value:true)
                    
                }
            }
            
        }
    }
    
    //切换到跌落状态
    func skiptofall(){
        nowstatus = .fall
        bird.zRotation = CGFloat(-pi/2)
        stopreborn()
        bird.removeAllActions()
        run(SKAction.sequence([whack,SKAction.wait(forDuration: 0.1),falling]))
    }
    //切换到新游戏
    func skiptonewgame(){
        run(pop)
        let newgame = GameScene.init(size: size)
        let qiehuan = SKTransition.fade(with: SKColor.black, duration: 0.05)
        view?.presentScene(newgame, transition:qiehuan)
    }
    
    
    //切换到得分状态
    func skiptoscore(){
        nowstatus = .score
        bird.removeAllActions()
        stopreborn()
        setscoreboard()
        
    }
    //切换到结束
    func skiptoend(){
        nowstatus = .end
    }
    //切换到教程
    func skiptocourse(){
        nowstatus = .course
        
        world.enumerateChildNodes(withName: "menu") { (node, stop) -> Void in
            node.run(SKAction.sequence([
                SKAction.fadeOut(withDuration: 0.05),
                SKAction.removeFromParent()
                ]))
        }
        setscorelabel()
        setcourse()
        setbirdanimation()
    }
    //切换到游戏界面
    func skiptogame(){
        nowstatus = .game
        world.enumerateChildNodes(withName: "course") { (node, stop) -> Void in
            node.run(SKAction.sequence([
                SKAction.fadeOut(withDuration: 0.05),
                SKAction.removeFromParent()
                ]))
        }
        rebornblock()
        reborncoin()
        birdfly()
    }
    
    //切换到主菜单
    func skiptomenu(){
        nowstatus = .menu
        setbackground()
        setqianjing()
        setbird()
        //    setcap()
        setmenu()
        setbirdanimation()
        
    }
    
    
    //物理引擎
    func didBegin(_ contact: SKPhysicsContact) {
        let other = contact.bodyA.categoryBitMask == physics.player ? contact.bodyB : contact.bodyA
        
        if other.categoryBitMask == physics.ground{
            hitground = true
        }
        if other.categoryBitMask == physics.block{
            hitblock = true
        }
        if other.categoryBitMask == physics.coin{
            getcoin = true
        }
    }
    
    
    
    //读取最高分
    func best()->Int{
        return UserDefaults.standard.integer(forKey: "best")
    }
    //设置最高分
    func setbest(best:Int){
        UserDefaults.standard.set(best,forKey:"best")
        UserDefaults.standard.synchronize()
    }
    //学习网站
    func gotolearn(){
        let learnweb = URL(string: "https://github.com/buaaduyi/Flappy-Bird")
        UIApplication.shared.open(learnweb!, options: [:],
                                  completionHandler: {
                                    (success) in
        })
        
    }
    //评价网站
    func gotorate(){
        
    }
    
    override func didMove(to view: SKView) {
        
        //关掉系统系统重力
        physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        //使用系统碰撞代理
        physicsWorld.contactDelegate = self
        addChild(world)
        skiptomenu()
        
    }
    
    
}
