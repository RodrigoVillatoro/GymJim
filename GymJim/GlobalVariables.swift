//
//  GlobalVariables.swift
//  GymJim
//
//  Created by Rodrigo Villatoro on 1/4/15.
//  Copyright (c) 2015 RVD. All rights reserved.
//

import Foundation
import SpriteKit

// AudioController
var audioController = AudioController()

let screenWidth: CGFloat = 1536
let screenHeight: CGFloat = 2048
let startingY: CGFloat = screenHeight * 0.75

enum CurrentPosition: Int {
    
    case Left = 0, Center, Right
    
    var getPositionX: CGFloat {
        let positionsX: [CGFloat] = [
            (screenWidth * 0.25),
            (screenWidth * 0.50),
            (screenWidth * 0.75)
        ]
        return positionsX[rawValue]
    }
    
}

enum GameState {
    case Instructions
    case Playing
    case GameOver
    case Upgrading
}

enum PhysicsCategory {
    static let Platform =           1 << 0 as UInt32
    static let Treasure =           1 << 1 as UInt32
    static let Axe =                1 << 2 as UInt32
    static let Character =          1 << 3 as UInt32
    static let None =               1 << 4 as UInt32
}

enum Positions: CGFloat {
    case Platform = 1
    case Item
    case Character
    case WaterBack
    case WaterMiddle
    case WaterFront
    case Board
    case Buttons
    case Labels
}

















