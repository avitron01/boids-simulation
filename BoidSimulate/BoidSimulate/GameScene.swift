//
//  GameScene.swift
//  BoidSimulate
//
//  Created by Avinash P on 4/7/22.
//

import SpriteKit
import GameplayKit

class Boids: SKSpriteNode {
    func align(boids: [Boids]) -> CGVector {
        let perceivedRadius: CGFloat = 50
        var steeringVelocity: CGVector = .zero
        var total: CGFloat = 0
        let velocity = self.physicsBody!.velocity
        
        for other in boids {
            if other != self && other.position.distance(point: self.position) < perceivedRadius {
                total += 1
                let otherBoidVelocity = other.physicsBody!.velocity
                steeringVelocity = steeringVelocity + otherBoidVelocity
            }
        }
        print("Total : \(total)")
        if (total > 0) {
            steeringVelocity = steeringVelocity / total
            steeringVelocity = steeringVelocity - velocity
        }
        
        let vectorLength: CGFloat = sqrt(steeringVelocity.dx*steeringVelocity.dx + steeringVelocity.dy*steeringVelocity.dy)
        var normalised: CGVector = (vectorLength > 0) ? (steeringVelocity / vectorLength) : .zero
        let speed: CGFloat = 10
        normalised.dx = normalised.dx * speed
        normalised.dy = normalised.dy * speed
        
        return steeringVelocity
    }
    
    func cohesion(boids: [Boids]) -> CGVector {
        let perceivedRadius: CGFloat = 50
        var steeringVelocity: CGVector = .zero
        var total: CGFloat = 0
        let velocity = CGVector(dx: self.position.x, dy: self.position.y)
        
        for other in boids {
            if other != self && other.position.distance(point: self.position) < perceivedRadius {
                total += 1
                let otherBoidVelocity = CGVector(dx: other.position.x, dy: other.position.y)
                steeringVelocity = steeringVelocity + otherBoidVelocity
            }
        }
        print("Total : \(total)")
        if (total > 0) {
            steeringVelocity = steeringVelocity / total
            steeringVelocity = steeringVelocity - velocity
        }
        
        let vectorLength: CGFloat = sqrt(steeringVelocity.dx*steeringVelocity.dx + steeringVelocity.dy*steeringVelocity.dy)
        var normalised: CGVector = (vectorLength > 0) ? (steeringVelocity / vectorLength) : .zero
        let speed: CGFloat = 10
        normalised.dx = normalised.dx * speed
        normalised.dy = normalised.dy * speed
        
        return steeringVelocity
    }
    
    func flock(boids: [Boids]) {
        self.physicsBody?.velocity = .zero
        var alignment = self.align(boids: boids) //self.align(boids: boids)
        var cohesion = self.cohesion(boids: boids)
        
        self.physicsBody!.velocity = self.physicsBody!.velocity + cohesion + alignment
    }
    

    
    func edges(_ size: CGSize) {
        if (self.position.x < 0) {
            self.position.x = size.width
        } else if (self.position.x > size.width) {
            self.position.x = 0
        }
        
        if (self.position.y < 0) {
            self.position.y = size.height
        } else if (self.position.y > size.height) {
            self.position.y = 0
        }
    }
}

extension CGVector {
    static func + (lhs: Self, rhs: Self) -> Self {
        return CGVector(dx: lhs.dx + rhs.dx, dy: lhs.dy + rhs.dy)
    }
    
    static func - (lhs: Self, rhs: Self) -> Self {
        return CGVector(dx: lhs.dx - rhs.dx, dy: lhs.dy - rhs.dy)
    }
    
    static func / (lhs: Self, rhs: Self) -> Self {
        return CGVector(dx: lhs.dx / rhs.dx, dy: lhs.dy / rhs.dy)
    }
    
    static func / (lhs: Self, rhs: CGFloat) -> Self {
        return CGVector(dx: lhs.dx / rhs, dy: lhs.dy / rhs)
    }
    
    func speed() -> CGFloat {
        return sqrt(dx*dx+dy*dy)
    }
    func angle() -> CGFloat {
        return atan2(dy, dx)
    }
}

class GameScene: SKScene {
    var flocks: [Boids] = []
    
    override func didMove(to view: SKView) {
        self.backgroundColor = .white
        
        
        let boidSize = CGSize(width: 20, height: 20)
        let boidPosition = CGPoint(x: size.width / 2, y: size.height / 2)
        let image = NSImage(systemSymbolName: "location.north.fill", accessibilityDescription: nil)!
        
        let texture = SKTexture(image: image)
        for _ in 0..<100 {
            let boid = Boids(texture: texture)
            boid.size = boidSize
            boid.position = CGPoint(x: CGFloat.random(in: 0...self.size.width), y: CGFloat.random(in: 0...self.size.height))
            boid.physicsBody = SKPhysicsBody(rectangleOf: boid.size)
            boid.physicsBody?.velocity = CGVector(dx: CGFloat.random(in: -100...200), dy: CGFloat.random(in: 100...200))
            flocks.append(boid)
            addChild(boid)
        }

        physicsWorld.gravity = CGVector.zero
        physicsWorld.contactDelegate = self
    }
    
    
    
    func touchDown(atPoint pos : CGPoint) {
//        for boid in flocks {
//            let unitVector = CGVector(dx: 2, dy: 2)
//            boid.physicsBody!.velocity = boid.physicsBody!.velocity + unitVector
//        }
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
            
            boid.flock(boids: flocks)
            boid.edges(self.size)
            if let body = boid.physicsBody {
                if (body.velocity.speed() > 0.01) {
                    boid.zRotation = body.velocity.angle() - offset
                }
            }
        }
    }
    

}

extension GameScene: SKPhysicsContactDelegate {

}

extension CGPoint {
    func distance(point: CGPoint) -> CGFloat {
        return abs(CGFloat(hypotf(Float(point.x - x), Float(point.y - y))))
    }
}