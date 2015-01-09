//
//  MainMenuViewController.swift
//  GymJim
//
//  Created by Rodrigo Villatoro on 1/7/15.
//  Copyright (c) 2015 RVD. All rights reserved.
//

import UIKit

class MainMenuViewController: UIViewController {

    @IBAction func playButtonPressed(sender: AnyObject) {
        
        let gameViewController = self.storyboard!.instantiateViewControllerWithIdentifier("GameViewController") as GameViewController
        
        navigationController!.pushViewController(gameViewController, animated: true)
        
    }
    
}
