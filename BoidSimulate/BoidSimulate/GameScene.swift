//
//  GameScene.swift
//  BoidSimulate
//
//  Created by Avinash P on 4/7/22.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    var flocks: [Boids] = []
    var grid: Grid = Grid()
    
    override func didMove(to view: SKView) {
        self.backgroundColor = .white
        self.grid.min = 0
        self.grid.max = self.size.width
        self.setupBoids()
        self.configurePhysicsWorld()
    }
    
    func setupBoids() {
        let boidSize = CGSize(width: 20, height: 20)
        self.flocks = Boids.generateBoids(count: 100, size: boidSize, parentNode: self, sceneSize: self.size)
    }
    
    func configurePhysicsWorld() {
        physicsWorld.gravity = CGVector.zero
        physicsWorld.contactDelegate = self
    }
    
    func touchDown(atPoint pos : CGPoint) {
        self.resetFlock()
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

    }
    let offset = CGFloat(Double.pi/2)
    
    override func update(_ currentTime: TimeInterval) {
        for boid in flocks {
            grid.addToBucket(boid)
            boid.flock(boids: flocks, using: grid)
            boid.edges(self.size)
            if let body = boid.physicsBody {
                boid.zRotation = body.velocity.angle() - offset
            }            
        }
    }
    

}

extension GameScene: SKPhysicsContactDelegate {

}


