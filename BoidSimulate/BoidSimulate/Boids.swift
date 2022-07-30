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
    var cellSize: CGFloat = 200
    
    var width: CGFloat {
        return (max - min) / cellSize
    }
    
    var numberOfBuckets: CGFloat {
        return self.width * self.width
    }
    
    var bucket: [Int: Set<Boid>] = [:]
    
    func addToBucket(boids: [Boid]) {
        for boid in boids {
            addToBucket(boid)
        }
    }
    
    func addToBucket(_ boid: Boid) {
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
    
    func getBoidForPoint(for point: CGPoint) -> Set<Boid>? {
        let gridIndex = gridCell(for: point)
        return bucket[gridIndex]
    }
}

class Boid: SKSpriteNode {
    let perceivedConstant: CGFloat = CGFloat(30 * 30)
    let boidSpeed: CGFloat = 150
    var lineNodes: [Boid : SKShapeNode]? = [:]
    var enableNodeWireFrame: Bool = false
    var enableBucketCount: Bool = false
    
    lazy var debugInfoNode: SKLabelNode = {
        let info = SKLabelNode(fontNamed: "Times-Roman")
        info.text = "No"
        info.fontSize = 20
        info.fontColor = SKColor.blue
        
        return info
    }()
    
    static func generateBoids(count: Int, size: CGSize, parentNode: SKNode, sceneSize: CGSize) -> [Boid] {
        var boids: [Boid] = []
        let boidSize = size
        let image = NSImage(systemSymbolName: "location.north.line.fill", accessibilityDescription: nil)!
        let texture = SKTexture(image: image)
        
        for _ in 0..<count {
            let boid = Boid(texture: texture)
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
    
    func flock(boids: [Boid], using grid: Grid) {
        self.physicsBody?.velocity = .zero
        self.physicsBody!.velocity = getFinalVelocity(boids: boids, grid: grid)
        if self.physicsBody!.velocity.dx == 0 && self.physicsBody!.velocity.dy == 0 {
            let finalVelocity = CGVector(dx: boidSpeed, dy: boidSpeed)
            self.physicsBody!.velocity = finalVelocity
        }
    }
    
    func getFinalVelocity(boids: [Boid], grid: Grid) -> CGVector {
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
        
        self.resetWireFrame()
        
        for other in boidsNearGrid {
            if other != self {
                let distance = other.position.distance(point: self.position)
                self.setupDebugInfoNodes(with: boidsNearGrid.count)
                if distance < perceivedRadius {
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
                    if enableNodeWireFrame {
                        self.updateLine(from: self, to: other)
                    }
                }
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
        
    func setupDebugInfoNodes(with bucketCount: Int) {
        if enableBucketCount {
            debugInfoNode.text = "\(bucketCount)"
            debugInfoNode.position = self.position
            
            if debugInfoNode.parent == nil {
                self.parent?.addChild(debugInfoNode)
            }
        } else {
            if debugInfoNode.parent != nil {
                debugInfoNode.removeFromParent()
            }
        }
    }
    
    func resetWireFrame() {
        guard let linesNodes = lineNodes else {
            return
        }
        
        linesNodes.values.forEach { $0.removeFromParent() }
        self.lineNodes = [:]
    }
    
    func updateLine(from first: Boid, to second: Boid) {
        if let _ = first.lineNodes?[second] {
            //Update path
            first.lineNodes?[second]?.path = getLinePath(for: first.position, to: second.position)
        } else {
            //Add new Shape
            self.addLine(from: first, to: second)
        }
    }
    
    func addLine(from first: Boid, to second: Boid) {
        let lineNode = self.getLineShape(for: first.position, to: second.position)
        first.lineNodes?[second] = lineNode
        self.parent?.addChild(lineNode)
    }
    
    func getLineShape(for start: CGPoint, to end: CGPoint) -> SKShapeNode {
        let path = CGMutablePath()
        path.move(to: start)
        path.addLine(to: end)
        
        let shape = SKShapeNode()
        shape.path = path
        shape.strokeColor = NSColor.blue
        shape.lineWidth = 2
        return shape
    }

    func getLinePath(for start: CGPoint, to end: CGPoint) -> CGMutablePath {
        let path = CGMutablePath()
        path.move(to: start)
        path.addLine(to: end)
        return path
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

