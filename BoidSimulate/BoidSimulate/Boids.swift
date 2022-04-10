//
//  Boids.swift
//  BoidSimulate
//
//  Created by Avinash P on 4/10/22.
//

import Foundation
import SpriteKit

class Grid {
    var min: CGFloat = 0
    var max: CGFloat = 0
    var cellSize: CGFloat = 250
    
    lazy var width: CGFloat = {
        return (max - min) / cellSize
    }()
    
    lazy var numberOfBuckets: CGFloat = {
        return self.width * self.width
    }()
    
    var bucket: [Int: Set<Boids>] = [:]
    
    func addToBucket(_ boid: Boids) {
        let gridCell = self.gridCell(for: boid.position)
        if let _ = bucket[gridCell] {
            bucket[gridCell]?.insert(boid)
        } else {
            bucket[gridCell] = [boid]
        }
    }
    
    lazy var conversionFactor: CGFloat = {
       return 1 / cellSize
    }()
    
    func gridCell(for point: CGPoint) -> Int {
        let gridCell = Int((point.x * conversionFactor) + (point.y * conversionFactor) * width)
        return gridCell
    }
    
    func getBoidForPoint(for point: CGPoint) -> Set<Boids>? {
        let gridIndex = gridCell(for: point)
        return bucket[gridIndex]
    }
}

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
    
    func flock(boids: [Boids], using grid: Grid) {
        self.physicsBody?.velocity = .zero
        self.physicsBody!.velocity = getFinalVelocity(boids: boids, grid: grid)
        if self.physicsBody!.velocity.dx == 0 && self.physicsBody!.velocity.dy == 0 {
            self.physicsBody!.velocity = CGVector(dx: boidSpeed, dy: boidSpeed)
        }
    }
    
    func getFinalVelocity(boids: [Boids], grid: Grid) -> CGVector {
        let perceivedRadius: CGFloat = perceivedConstant
        var steeringVelocity: CGVector = .zero //Alignment
        var cohesionPosition: CGVector = .zero //Cohesion
        var separationVector: CGVector = .zero //Separation
        
        var total: CGFloat = 0
        let selfVelocity = self.physicsBody!.velocity
        let positionVector = CGVector(dx: self.position.x, dy: self.position.y)
        
        guard let boidsNearGrid = grid.getBoidForPoint(for: self.position) else {
            return .zero
        }
        
        for other in boidsNearGrid {
            let distance = other.position.distance(point: self.position)
            if other != self && distance < perceivedRadius {
                total += 1
                //Alignment
                let otherBoidVelocity = other.physicsBody!.velocity
                steeringVelocity = steeringVelocity + otherBoidVelocity
                
                //Cohesion
                let otherBoidPosition = CGVector(dx: other.position.x, dy: other.position.y)
                cohesionPosition = cohesionPosition + otherBoidPosition
                
                //Separation
                let diff = positionVector - otherBoidPosition
                let diffPerceived = diff / (sqrt(distance))
                separationVector = separationVector + diffPerceived
            }
        }

        if (total > 0) {
            steeringVelocity = steeringVelocity / total
            steeringVelocity = steeringVelocity - selfVelocity
            
            cohesionPosition = cohesionPosition / total
            cohesionPosition = cohesionPosition - positionVector
            
            separationVector = separationVector / total
        }
        
        
        var normalisedSteering: CGVector = steeringVelocity.normalized
        normalisedSteering.dx *= boidSpeed
        normalisedSteering.dy *= boidSpeed
        
        var normalisedCohesion: CGVector = cohesionPosition.normalized
        normalisedCohesion.dx *= boidSpeed
        normalisedCohesion.dy *= boidSpeed
        
        var normalisedSeparation: CGVector = separationVector.normalized
        normalisedSeparation.dx *= boidSpeed
        normalisedSeparation.dy *= boidSpeed
        
        return normalisedSteering + normalisedCohesion + normalisedSeparation
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
