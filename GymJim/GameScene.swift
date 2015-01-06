//
//  GameScene.swift
//  GymJim
//
//  Created by Rodrigo Villatoro on 1/4/15.
//  Copyright (c) 2015 RVD. All rights reserved.
//

import SpriteKit

protocol MySceneDelegate {

}


class GameScene: SKScene, SKPhysicsContactDelegate {
    
    // Delegate
    var sceneDelegate: MySceneDelegate!
    
    // Game Over
    var gameOver = false
    
    // Score
    var score: Int = 0
    let scoreLabel = SKLabelNode(text: "x 0")
    
    // Platform
    var currentPlatform: SKSpriteNode?
    var platformsAdded: CGFloat = 0.0
    let gapHeight: CGFloat = 500
    var canBreakPlatform = false
    
    // Level difficulty
    var levelSpeed = CGFloat()
    
    // Character
    let character = SKSpriteNode(imageNamed: "character")
    var characterPosition = CurrentPosition.Center
    
    // Character Animations
    let pointLeft = SKAction.animateWithTextures([SKTexture(imageNamed: "characterLeft"), SKTexture(imageNamed: "character")], timePerFrame: 0.1)
    let pointRight = SKAction.animateWithTextures([SKTexture(imageNamed: "characterRight"), SKTexture(imageNamed: "character")], timePerFrame: 0.1)
    let breathe = SKAction.animateWithTextures([SKTexture(imageNamed: "characterLeftFoot"), SKTexture(imageNamed: "character"), SKTexture(imageNamed: "characterRightFoot"), SKTexture(imageNamed: "character")], timePerFrame: 0.1)
    
    // Nodes
    let worldNode = SKNode()
    let characterNode = SKNode()
    let platformsNode = SKNode()
    let buttonsNode = SKNode()

    // Sounds
    let playBreakPlatformSound = SKAction.playSoundFileNamed("crawler_die.wav", waitForCompletion: false)
    let playCharacterMoveSound = SKAction.playSoundFileNamed("whoosh.mp3", waitForCompletion: false)
    let playCoinSound = SKAction.playSoundFileNamed("coin.wav", waitForCompletion: false)
    let playGameOverSound = SKAction.playSoundFileNamed("Game Over.wav", waitForCompletion: false)
    
    
    init(size: CGSize, delegate: MySceneDelegate) {
        
        super.init(size: size)
        sceneDelegate = delegate
        
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func didMoveToView(view: SKView) {
        
        // Nodes
        self.addChild(worldNode)
        worldNode.addChild(characterNode)
        worldNode.addChild(platformsNode)
        worldNode.addChild(buttonsNode)
        
        // Physics
        physicsWorld.contactDelegate = self
        
        // Spawn platform
        spawnPlatforms()
        spawnItems()
        
        // Add character
        character.position = CGPointMake(characterPosition.getPositionX, startingY)
        character.zPosition = Positions.Character.rawValue
        character.physicsBody = SKPhysicsBody(rectangleOfSize: CGSizeMake(150, 420))
        character.physicsBody?.categoryBitMask = PhysicsCategory.Character
        character.physicsBody?.collisionBitMask = PhysicsCategory.Platform
        character.physicsBody?.contactTestBitMask = PhysicsCategory.Platform | PhysicsCategory.Treasure | PhysicsCategory.Axe
        character.physicsBody?.friction = 1.0
        character.physicsBody?.restitution = 0.0
        character.physicsBody?.allowsRotation = false
        addChild(character)
        character.runAction(SKAction.repeatActionForever(breathe))
        
//        // Add water
//        for var i = 0; i <= 1; ++i {
//            
//            // Water back
//            let waterBack = SKSpriteNode(imageNamed: "water1")
//            waterBack.anchorPoint = CGPointMake(0.0, 0.0)
//            waterBack.position = CGPointMake(self.size.width * CGFloat(i), 0)
//            waterBack.zPosition = Positions.WaterBack.rawValue
//            waterBack.name = "waterBack"
//            worldNode.addChild(waterBack)
//            
//            // Action
//            let moveLeft = SKAction.moveByX(-screenWidth, y: 0, duration: 20)
//            let resetBack = SKAction.moveByX(screenWidth, y: 0, duration: 0)
//            waterBack.runAction(SKAction.repeatActionForever(SKAction.sequence([moveLeft, resetBack])))
//            
//            // Water Middle
//            let waterMiddle = SKSpriteNode(imageNamed: "water2")
//            waterMiddle.anchorPoint = CGPointMake(0.0, 0.0)
//            waterMiddle.position = CGPointMake(self.size.width * -CGFloat(i), 0)
//            waterMiddle.zPosition = Positions.WaterMiddle.rawValue
//            waterMiddle.name = "waterMiddle"
//            worldNode.addChild(waterMiddle)
//            
//            // Action
//            let moveRight = SKAction.moveByX(screenWidth, y: 0, duration: 17)
//            let resetMiddle = SKAction.moveByX(-screenWidth, y: 0, duration: 0)
//            waterMiddle.runAction(SKAction.repeatActionForever(SKAction.sequence([moveRight, resetMiddle])))
//            
//            // Water front
//            let waterFront = SKSpriteNode(imageNamed: "water3")
//            waterFront.anchorPoint = CGPointMake(0.0, 0.0)
//            waterFront.position = CGPointMake(self.size.width * CGFloat(i), 0)
//            waterFront.zPosition = Positions.WaterFront.rawValue
//            waterFront.name = "waterFront"
//            worldNode.addChild(waterFront)
//            
//            // Action
//            let moveLeft1 = SKAction.moveByX(-screenWidth, y: 0, duration: 15)
//            let resetFront = SKAction.moveByX(screenWidth, y: 0, duration: 0)
//            waterFront.runAction(SKAction.repeatActionForever(SKAction.sequence([moveLeft1, resetFront])))
//            
//        }
        
        // Add HUD
        let coin = SKSpriteNode(imageNamed: "coin1")
        coin.setScale(0.90)
        coin.position = CGPointMake(self.size.width * 0.40, self.size.height * 0.95)
        coin.zPosition = Positions.Buttons.rawValue
        worldNode.addChild(coin)
        
        scoreLabel.fontSize = 125
        scoreLabel.fontName = "Superclarendon-Black"
        scoreLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Left
        scoreLabel.verticalAlignmentMode = SKLabelVerticalAlignmentMode.Center
        scoreLabel.position = CGPointMake(coin.position.x + coin.size.width * 0.65, coin.position.y)
        scoreLabel.zPosition = Positions.Buttons.rawValue
        worldNode.addChild(scoreLabel)
        
        // Gesture Recognizers
        addGestureRecognizers()
        
    }
    
    func addGestureRecognizers() {
        
        // Right
        var swipeRight = UISwipeGestureRecognizer(target: self, action: "swiped:")
        swipeRight.direction = UISwipeGestureRecognizerDirection.Right
        self.view?.addGestureRecognizer(swipeRight)
        
        // Left
        var swipeLeft = UISwipeGestureRecognizer(target: self, action: "swiped:")
        swipeLeft.direction = UISwipeGestureRecognizerDirection.Left
        self.view?.addGestureRecognizer(swipeLeft)
        
        // Down
        var swipeDown = UISwipeGestureRecognizer(target: self, action: "swiped:")
        swipeDown.direction = UISwipeGestureRecognizerDirection.Down
        self.view?.addGestureRecognizer(swipeDown)
        
    }
    
    func swiped(gesture: UIGestureRecognizer) {
        
        // Can only swipe if user has touched a platform
        if currentPlatform != nil {
        
            if let swipeGesture = gesture as? UISwipeGestureRecognizer {
                
                switch swipeGesture.direction {
                    
                case UISwipeGestureRecognizerDirection.Right:
                    runAction(playCharacterMoveSound)
                    character.runAction(pointRight)
                    updateCharacterPosition(tappedRight: true)
                    
                case UISwipeGestureRecognizerDirection.Left:
                    runAction(playCharacterMoveSound)
                    character.runAction(pointLeft)
                    updateCharacterPosition(tappedRight: false)
                    
                    // Break Platform
                case UISwipeGestureRecognizerDirection.Down:
                    self.runAction(playBreakPlatformSound)
                    currentPlatform?.removeFromParent()
                    currentPlatform = nil
                    character.physicsBody?.applyImpulse(CGVectorMake(0, -10000))
                    
                default:
                    break
                    
                }
                
            }
        
        }
 
    }

    
    func didBeginContact(contact: SKPhysicsContact) {
        
        let collision = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
        
        if (collision == PhysicsCategory.Platform | PhysicsCategory.Character) {
            
            var firstBody: SKPhysicsBody
            var secondBody: SKPhysicsBody
            
            if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
                firstBody = contact.bodyA
                secondBody = contact.bodyB
            } else {
                firstBody = contact.bodyB
                secondBody = contact.bodyA
            }
            
            if firstBody.categoryBitMask == PhysicsCategory.Platform && secondBody.categoryBitMask == PhysicsCategory.Character {
                currentPlatform = firstBody.node as? SKSpriteNode
            }
            
        }
        
        if (collision == PhysicsCategory.Treasure | PhysicsCategory.Character) {
            
            var firstBody: SKPhysicsBody
            var secondBody: SKPhysicsBody
            
            if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
                firstBody = contact.bodyA
                secondBody = contact.bodyB
            } else {
                firstBody = contact.bodyB
                secondBody = contact.bodyA
            }
            
            if firstBody.categoryBitMask == PhysicsCategory.Treasure && secondBody.categoryBitMask == PhysicsCategory.Character {
                runAction(playCoinSound)
                let treasureNode = firstBody.node as? SKSpriteNode
                treasureNode!.removeFromParent()
                ++score
                scoreLabel.text = "x \(score)"
            }
            
        }
        
        if (collision == PhysicsCategory.Axe | PhysicsCategory.Character) {
            
            endGame()
            
        }
        
        
    }
    
    func updateCharacterPosition(#tappedRight: Bool) {
        
        // Only executed if user does not select center. Will determine character position.
        switch characterPosition {
        case .Left:
            tappedRight ? (characterPosition = .Center) : (characterPosition = .Right)
        case .Center:
            tappedRight ? (characterPosition = .Right) : (characterPosition = .Left)
        case .Right:
            tappedRight ? (characterPosition = .Left) : (characterPosition = .Center)
        }
        
        // Move character
        character.position.x = characterPosition.getPositionX
        
    }
    
    
    func spawnPlatforms() {
        
        let spawn = SKAction.runBlock({
            
            // Add three platforms
            self.addPlatform(positionOnSceen: CGPointMake(self.size.width * 0.50, self.platformsAdded * -self.gapHeight))
            self.addPlatform(positionOnSceen: CGPointMake(self.size.width * 0.25, self.platformsAdded * -self.gapHeight))
            self.addPlatform(positionOnSceen: CGPointMake(self.size.width * 0.75, self.platformsAdded * -self.gapHeight))
            ++self.platformsAdded
        })
        
        let wait = SKAction.waitForDuration(0.5)
        self.runAction(SKAction.repeatActionForever(SKAction.sequence([spawn, wait])), withKey: "spawnPlatforms")
        
    }
    
    func spawnItems() {
        
        let spawn = SKAction.runBlock({
            
            let random = arc4random()%3
            
            if random == 0 {
                
                self.addTreasure(positionOnSceen: CGPointMake(self.size.width * 0.50, self.platformsAdded * -self.gapHeight))
                self.addTreasure(positionOnSceen: CGPointMake(self.size.width * 0.25, self.platformsAdded * -self.gapHeight))
                self.addAxe(positionOnSceen: CGPointMake(self.size.width * 0.75, self.platformsAdded * -self.gapHeight))
                
            } else if random == 1 {
                
                self.addTreasure(positionOnSceen: CGPointMake(self.size.width * 0.50, self.platformsAdded * -self.gapHeight))
                self.addAxe(positionOnSceen: CGPointMake(self.size.width * 0.25, self.platformsAdded * -self.gapHeight))
                self.addTreasure(positionOnSceen: CGPointMake(self.size.width * 0.75, self.platformsAdded * -self.gapHeight))
                
            } else {
                
                self.addAxe(positionOnSceen: CGPointMake(self.size.width * 0.50, self.platformsAdded * -self.gapHeight))
                self.addTreasure(positionOnSceen: CGPointMake(self.size.width * 0.25, self.platformsAdded * -self.gapHeight))
                self.addTreasure(positionOnSceen: CGPointMake(self.size.width * 0.75, self.platformsAdded * -self.gapHeight))
                
            }
            
            
            
        })
        
        let wait = SKAction.waitForDuration(0.5)
        self.runAction(SKAction.repeatActionForever(SKAction.sequence([spawn, wait])), withKey: "spawnItems")
        
    }
    
    func addPlatform(#positionOnSceen: CGPoint) {
        
        // Platform
        let platform = SKSpriteNode(imageNamed: "platform")
        platform.position = positionOnSceen
        platform.zPosition = Positions.Platform.rawValue
        platform.physicsBody = SKPhysicsBody(rectangleOfSize: CGSizeMake(200, 50))
        platform.physicsBody?.affectedByGravity = false
        platform.physicsBody?.dynamic = false
        platform.physicsBody?.restitution = 0
        platform.physicsBody?.friction = 1
        platform.physicsBody?.categoryBitMask = PhysicsCategory.Platform
        platform.name = "platform"
        platformsNode.addChild(platform)
        
    }
    
    func addTreasure(#positionOnSceen: CGPoint) {
        
        let textures = [
            SKTexture(imageNamed: "coin1"),
            SKTexture(imageNamed: "coin2"),
            SKTexture(imageNamed: "coin3"),
            SKTexture(imageNamed: "coin4"),
            SKTexture(imageNamed: "coin5")
        ]
        
        let item = SKSpriteNode(imageNamed: "coin1")
        item.position = CGPointMake(positionOnSceen.x, positionOnSceen.y + item.size.width/2)
        item.zPosition = Positions.Item.rawValue
        item.physicsBody = SKPhysicsBody(circleOfRadius: 50)
        item.physicsBody?.affectedByGravity = false
        item.physicsBody?.dynamic = false
        item.physicsBody?.categoryBitMask = PhysicsCategory.Treasure
        item.name = "platform"
        platformsNode.addChild(item)
        
        item.runAction(SKAction.repeatActionForever(SKAction.animateWithTextures(textures, timePerFrame: 0.1)))
        
    }
    
    func addAxe(#positionOnSceen: CGPoint) {
        
        let textures = [
            SKTexture(imageNamed: "axe1"),
            SKTexture(imageNamed: "axe2"),
            SKTexture(imageNamed: "axe3"),
            SKTexture(imageNamed: "axe4"),
        ]
        
        let item = SKSpriteNode(imageNamed: "axe1")
        item.position = CGPointMake(positionOnSceen.x, positionOnSceen.y + item.size.width/2)
        item.zPosition = Positions.Item.rawValue
        item.physicsBody = SKPhysicsBody(circleOfRadius: 50)
        item.physicsBody?.affectedByGravity = false
        item.physicsBody?.dynamic = false
        item.physicsBody?.categoryBitMask = PhysicsCategory.Axe
        item.name = "platform"
        platformsNode.addChild(item)
        
        item.runAction(SKAction.repeatActionForever(SKAction.animateWithTextures(textures, timePerFrame: 0.2)))
        
    }
    
    func endGame() {
        
        gameOver = true
        runAction(playGameOverSound)
        character.removeAllActions()
        removeActionForKey("spawnPlatforms")
        removeActionForKey("spawnItems")
        
        runAction(SKAction.sequence([SKAction.waitForDuration(1.0), SKAction.runBlock({
            
            let scene = GameScene(size: CGSize(width: screenWidth, height: screenHeight), delegate: self.sceneDelegate)
            scene.scaleMode = .AspectFill
            self.view?.presentScene(scene)
            
        })]))
        
    }
    
    
    override func update(currentTime: CFTimeInterval) {
        
        if !gameOver {
            
            platformsNode.enumerateChildNodesWithName("platform", usingBlock: {
                node, stop in
                let convertedPosition = self.convertPoint(node.position, fromNode: self.platformsNode)
                if  convertedPosition.y > self.character.position.y {
                    node.removeFromParent()
                }
            })
            
            if platformsAdded <= 5 {
                levelSpeed = 8
            } else if platformsAdded <= 10 {
                levelSpeed = 10
            } else {
                levelSpeed = 15
            }
            
            platformsNode.position.y += levelSpeed
            
            
            // If character is out of bounds
            
            if (character.position.y) <= 0 || (character.position.y + character.size.height/3) >= self.size.height {
                
                endGame()
                
            }
            
        }
        
    }
    
}
