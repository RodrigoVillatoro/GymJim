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
    let gameOverNode = SKNode()

    // Sounds
    let playBreakPlatformSound = SKAction.playSoundFileNamed("crawler_die.wav", waitForCompletion: false)
    let playCharacterMoveSound = SKAction.playSoundFileNamed("whoosh.mp3", waitForCompletion: false)
    let playCoinSound = SKAction.playSoundFileNamed("coin.wav", waitForCompletion: false)
    let playGameOverSound = SKAction.playSoundFileNamed("Game Over.wav", waitForCompletion: false)
    
    // Atlas
    var gameAtlas = SKTextureAtlas(named: "game")
    var uiAtlas = SKTextureAtlas(named: "ui")
    
    // Game state
    var gameState = GameState.Playing
    
    // UI
    var playButton = SKSpriteNode()
    
    
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
        addChild(gameOverNode)
        
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
        
        // Add HUD
        let coin = SKSpriteNode(texture: gameAtlas.textureNamed("coin1"))
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
    
    // MARK: - Touches and gestures
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        
        if gameState == .Playing {
            for touch in touches {
                let touchLocation = touch.locationInNode(self)
                if touchLocation.x <= self.size.width/2 {
                    
                } else {
                
                }
            }
        } else if gameState == .GameOver {
            for touch in touches {
                let touchLocation = touch.locationInNode(self)
                if CGRectContainsPoint(playButton.frame, touchLocation) {
                    startNewGame()
                }
            }
        }
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
        if currentPlatform != nil && gameState == .Playing {
        
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
                let coin = firstBody.node as? SKSpriteNode
                coin!.removeFromParent()
                ++score
                scoreLabel.text = "x \(score)"
            }
            
        }
        
        if (collision == PhysicsCategory.Axe | PhysicsCategory.Character) {
            
            switchToGameOver()
            
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
        let platform = SKSpriteNode(texture: gameAtlas.textureNamed("platform"))
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
            gameAtlas.textureNamed("coin1"),
            gameAtlas.textureNamed("coin2"),
            gameAtlas.textureNamed("coin3"),
            gameAtlas.textureNamed("coin4"),
            gameAtlas.textureNamed("coin5")
        ]
        
        let item = SKSpriteNode(texture: gameAtlas.textureNamed("coin1"))
        item.position = CGPointMake(positionOnSceen.x, positionOnSceen.y + item.size.width/2)
        item.zPosition = Positions.Item.rawValue
        item.physicsBody = SKPhysicsBody(circleOfRadius: 50)
        item.physicsBody?.affectedByGravity = false
        item.physicsBody?.dynamic = false
        item.physicsBody?.categoryBitMask = PhysicsCategory.Treasure
        item.name = "coin"
        platformsNode.addChild(item)
        
        item.runAction(SKAction.repeatActionForever(SKAction.animateWithTextures(textures, timePerFrame: 0.1)))
        
    }
    
    func addAxe(#positionOnSceen: CGPoint) {
        
        let textures = [
            gameAtlas.textureNamed("axe1"),
            gameAtlas.textureNamed("axe2"),
            gameAtlas.textureNamed("axe3"),
            gameAtlas.textureNamed("axe4")
        ]
        
        let item = SKSpriteNode(texture: gameAtlas.textureNamed("axe1"))
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
    
    // MARK: - Switch To...
    
    func startNewGame() {
        
        let scene = GameScene(size: CGSize(width: screenWidth, height: screenHeight), delegate: self.sceneDelegate)
        scene.scaleMode = .AspectFill
        self.view?.presentScene(scene)
        
    }
    
    func switchToGameOver() {
        
        gameState = .GameOver
        
        // Clean up scene and stop actions
        character.removeAllActions()
        character.texture = gameAtlas.textureNamed("tomb")
        character.size = character.texture!.size()
        runAction(playGameOverSound)
        removeActionForKey("spawnPlatforms")
        removeActionForKey("spawnItems")
        
        // Position gameOverNode outside of view, then make it visible via SKAction
        gameOverNode.position.x = self.size.width
        
        // Add Game Over Board
        let gameOverBoard = SKSpriteNode(texture: uiAtlas.textureNamed("board"))
        gameOverBoard.position = CGPointMake(self.size.width/2, self.size.height/2)
        gameOverBoard.zPosition = Positions.Board.rawValue
        gameOverNode.addChild(gameOverBoard)
    
        // Play Button
        playButton = SKSpriteNode(texture: uiAtlas.textureNamed("play-button"))
        playButton.position = CGPointMake(self.size.width/2, self.size.height/2)
        playButton.zPosition = Positions.Buttons.rawValue
        gameOverNode.addChild(playButton)
        
        // Run action
        let boardLeft = SKAction.moveToX(-50, duration: 0.4)
        boardLeft.timingMode = SKActionTimingMode.EaseInEaseOut
        
        let boardRight = SKAction.moveToX(20, duration: 0.1)
        boardRight.timingMode = SKActionTimingMode.EaseInEaseOut
        
        let boardSettle = SKAction.moveToX(0, duration: 0.1)
        boardSettle.timingMode = SKActionTimingMode.EaseInEaseOut
        
        gameOverNode.runAction(SKAction.sequence([boardLeft, boardRight, boardSettle]))

        
    }
    
    // MARK: - Update
    
    override func update(currentTime: CFTimeInterval) {
        
        if gameState == .Playing {
            
            platformsNode.enumerateChildNodesWithName("platform", usingBlock: {
                node, stop in
                let convertedPosition = self.convertPoint(node.position, fromNode: self.platformsNode)
                if  convertedPosition.y > self.character.position.y {
                    node.removeFromParent()
                }
            })

            platformsNode.enumerateChildNodesWithName("coin", usingBlock: {
                node, stop in
                let convertedPosition = self.convertPoint(node.position, fromNode: self.platformsNode)
                if  convertedPosition.y > self.character.position.y {
                    
                    let duration: NSTimeInterval = 0.2
                    let zoom = SKAction.scaleBy(3, duration: duration)
                    let center = SKAction.moveTo(CGPointMake(self.size.width/2, self.size.height/2), duration: duration)
                    let group = SKAction.group([zoom, center])
                    node.runAction(group)
                    
                    self.runAction(SKAction.sequence([SKAction.waitForDuration(duration), SKAction.runBlock({
                        self.switchToGameOver()
                    })]))

                }
            })
            
            if platformsAdded <= 5 {
                levelSpeed = 10
            } else if platformsAdded <= 10 {
                levelSpeed = 15
            } else {
                levelSpeed = 20
            }
            
            platformsNode.position.y += levelSpeed
            
            
            // If character is out of bounds
            
            if (character.position.y) <= 0 || (character.position.y + character.size.height/3) >= self.size.height {
                
                switchToGameOver()
                
            }
            
        }
        
    }
    
}
