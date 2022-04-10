//
//  Boids.swift
//  BoidSimulate
//
//  Created by Avinash P on 4/10/22.
//

import Foundation
import SpriteKit

class Boids: SKSpriteNode {
    let perceivedConstant: CGFloat = CGFloat(50 * 50)
    let boidSpeed: CGFloat = 100
    
    static func generateBoids(count: Int, size: CGSize, parentNode: SKNode, sceneSize: CGSize) -> [Boids] {
        var boids: [Boids] = []
        let boidSize = size
        let image = NSImage(systemSymbolName: "location.north.fill", accessibilityDescription: nil)!
        let texture = SKTexture(image: image)
        
        for _ in 0..<count {
            let boid = Boids(texture: texture)
            boid.size = boidSize
            let xPos = CGFloat.random(in: 0...sceneSize.width)
            let yPos = CGFloat.random(in: 0...sceneSize.height)
            boid.position = CGPoint(x: xPos, y: yPos)
            boid.physicsBody = SKPhysicsBody(rectangleOf: boid.size)
            boid.physicsBody?.velocity = .zero
            boid.physicsBody?.collisionBitMask = 0
            parentNode.addChild(boid)
            boids.append(boid)
        }
        
        return boids
    }
    
    func align(boids: [Boids]) -> CGVector {
        let perceivedRadius: CGFloat = perceivedConstant
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

        if (total > 0) {
            steeringVelocity = steeringVelocity / total
            steeringVelocity = steeringVelocity - velocity
        }
        
        
        var normalised: CGVector = steeringVelocity.normalized
        normalised.dx = normalised.dx * boidSpeed
        normalised.dy = normalised.dy * boidSpeed
        
        return normalised
    }
    
    func cohesion(boids: [Boids]) -> CGVector {
        let perceivedRadius: CGFloat = perceivedConstant
        var cohesionPosition: CGVector = .zero
        var total: CGFloat = 0
        let positionVector = CGVector(dx: self.position.x, dy: self.position.y)
        
        for other in boids {
            if other != self && other.position.distance(point: self.position) < perceivedRadius {
                total += 1
                let otherBoidPosition = CGVector(dx: other.position.x, dy: other.position.y)
                cohesionPosition = cohesionPosition + otherBoidPosition
            }
        }

        if (total > 0) {
            cohesionPosition = cohesionPosition / total
            cohesionPosition = cohesionPosition - positionVector
        }
        
        var normalised: CGVector = cohesionPosition.normalized
        normalised.dx = normalised.dx * boidSpeed
        normalised.dy = normalised.dy * boidSpeed
        
        return normalised
    }
    
    func separation(boids: [Boids]) -> CGVector {
        let perceivedRadius: CGFloat = perceivedConstant
        var separationVector: CGVector = .zero
        var total: CGFloat = 0
        let positionVector = CGVector(dx: self.position.x, dy: self.position.y)
        for other in boids {
            let d = other.position.distance(point: self.position)
            if other != self && d < perceivedRadius {
                total += 1
                let otherBoidPosition = CGVector(dx: other.position.x, dy: other.position.y)
                let diff = positionVector - otherBoidPosition
                let diffPerceived = diff / (sqrt(d))
                separationVector = separationVector + diffPerceived
            }
        }
        
        if (total > 0) {
            separationVector = separationVector / total
        }
                        
        var normalised: CGVector = separationVector.normalized
        normalised.dx = normalised.dx * boidSpeed
        normalised.dy = normalised.dy * boidSpeed
        
        return normalised
    }
    
    func flock(boids: [Boids]) {
        self.physicsBody?.velocity = .zero
        let alignment = self.align(boids: boids)
        let cohesion = self.cohesion(boids: boids)
        let separation = self.separation(boids: boids)
        self.physicsBody!.velocity = separation + cohesion + alignment
//        print("\(separation)  \(cohesion)  \(alignment)")
        if self.physicsBody!.velocity.dx == 0 && self.physicsBody!.velocity.dy == 0 {
            self.physicsBody!.velocity = CGVector(dx: boidSpeed, dy: boidSpeed)
        }
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
