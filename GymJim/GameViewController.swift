//
//  GameViewController.swift
//  GymJim
//
//  Created by Rodrigo Villatoro on 1/4/15.
//  Copyright (c) 2015 RVD. All rights reserved.
//

import UIKit
import SpriteKit
import iAd

class GameViewController: UIViewController, MySceneDelegate {
    
    // iAd
    var bannerView = ADBannerView()
    
    override func viewDidLoad() {
        
        super.viewDidLoad()

        // Configure the view.
        let skView = self.view as SKView
        skView.showsFPS = false
        skView.showsNodeCount = false
        skView.showsPhysics = false
        
        /* Sprite Kit applies additional optimizations to improve rendering performance */
        skView.ignoresSiblingOrder = true
        
        /* Set the scale mode to scale to fit the window */
        let scene = GameScene(size: CGSize(width: screenWidth, height: screenHeight), delegate: self)
        scene.scaleMode = .AspectFill
        
        skView.presentScene(scene)
        
        // iAds
        self.canDisplayBannerAds = true
        

    }
    
    override func shouldAutorotate() -> Bool {
        return true
    }
    
    override func supportedInterfaceOrientations() -> Int {
        if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
            return Int(UIInterfaceOrientationMask.AllButUpsideDown.rawValue)
        } else {
            return Int(UIInterfaceOrientationMask.All.rawValue)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    // MARK: - ADS
    

    
    
}
