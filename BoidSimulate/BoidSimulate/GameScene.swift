//
//  GameScene.swift
//  BoidSimulate
//
//  Created by Avinash P on 4/7/22.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    var flocks: [Boid] = []
    var grid: Grid = Grid()
    var enableWireFrame: Bool = false
    var enableBucketCounts: Bool = false
    var totalBoids: Int = 200 {
        didSet {
            setupBoids(total: totalBoids)
        }
    }
    
    override func didMove(to view: SKView) {
        self.backgroundColor = .white
        self.totalBoids = 200
        self.configurePhysicsWorld()
        
    }
    
    func addInstructionNodes() {
        var heightOffset: CGFloat = 0
        let messages = ["Total Boids in system: - \(self.totalBoids)",
                        "Press W - Toggle Wireframes",
                        "Press R - Reset Flocking",
                        "Press P - Pause Flocking",
                        "Press B - Bucket counts",
                        "Press '+' - Add 100 Boids",
                        "Press '-' - Remove 100 Boids",]
        for message in messages.reversed() {
            let info = SKLabelNode(fontNamed: "Times-Roman")
            info.text = message
            info.fontSize = 15
            info.fontColor = SKColor.blue
            self.addChild(info)
            info.position = CGPoint(x: self.frame.origin.x + (info.frame.width / 2), y: 10 + heightOffset)
            heightOffset += info.frame.height
        }
    }
    
    func setupBoids(total: Int) {
        self.removeAllChildren()
        self.addInstructionNodes()
        let boidSize = CGSize(width: 20, height: 20)
        self.flocks = Boid.generateBoids(count: total, size: boidSize, parentNode: self, sceneSize: self.size)
        self.grid.addToBucket(boids: self.flocks)
    }
    
    func configurePhysicsWorld() {
        physicsWorld.gravity = CGVector.zero
        physicsWorld.contactDelegate = self
    }
    
    func touchDown(atPoint pos : CGPoint) {
        
    }
    
    func resetFlock() {
        for boid in flocks {
            boid.physicsBody?.velocity = .zero
            let xPos = CGFloat.random(in: 0...size.width)
            let yPos = CGFloat.random(in: 0...size.height)
            boid.position = CGPoint(x: xPos, y: yPos)
        }
    }
    
    func touchMoved(toPoint pos : CGPoint) {

    }
    
    func touchUp(atPoint pos : CGPoint) {

    }
    
    override func mouseDown(with event: NSEvent) {
        self.touchDown(atPoint: event.location(in: self))
    }
    
    override func mouseDragged(with event: NSEvent) {
        self.touchMoved(toPoint: event.location(in: self))
    }
    
    override func mouseUp(with event: NSEvent) {
        self.touchUp(atPoint: event.location(in: self))
    }
    
    override func keyDown(with event: NSEvent) {
        if event.characters == "w" {
            self.enableWireFrame.toggle()
        } else if event.characters == "p" {
            self.isPaused.toggle()
        } else if event.characters == "r" {
            self.resetFlock()
        } else if event.characters == "b" {
            self.enableBucketCounts.toggle()
        } else if event.characters == "+" || event.characters == "=" {
            self.totalBoids += 100
        } else if event.characters == "-"{
            self.totalBoids -= 100
            self.totalBoids = max(self.totalBoids, 100)
        }
    }
    
    let offset = CGFloat(Double.pi/2)
    
    override func update(_ currentTime: TimeInterval) {
        self.updateGrid()
        for boid in flocks {
            boid.enableNodeWireFrame = self.enableWireFrame
            boid.enableBucketCount = self.enableBucketCounts
            boid.flock(boids: flocks, using: grid)
            boid.edges(self.size)
            if let body = boid.physicsBody {
                boid.zRotation = body.velocity.angle() - offset
            }
        }
    }
    
    func updateGrid() {
        self.grid.min = 0
        self.grid.max = self.size.width
        self.grid.cellSize = self.size.width * 0.50
        self.grid.bucket = [:]
        self.grid.addToBucket(boids: flocks)
    }
    

}

extension GameScene: SKPhysicsContactDelegate {

}


