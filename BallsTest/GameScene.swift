//
//  GameScene.swift
//  BallsTest
//
//  Created by Alex Motor on 24.01.2018.
//  Copyright © 2018 Alex Motor. All rights reserved.
//

import SpriteKit

private struct PhysicsCategory {
    static let none: UInt32 = 0b0
    static let edge: UInt32 = 0b1
    static let circle: UInt32 = 0b10
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    private let circleRadius: CGFloat = 5.0
    private let circlesCount = 10
    private let circleSpeed: CGFloat = 50.0
    
    private var lastUpdateTime: TimeInterval = 0
    private var circles: [CircleShape] = []
    private var isCirclesRunning = true
    
    override func didMove(to view: SKView) {
        preparePhysics()
        circles = generateCircles()
    }
    
    private func preparePhysics() {
        physicsWorld.gravity = CGVector.zero
        physicsWorld.contactDelegate = self
        physicsBody = SKPhysicsBody(edgeLoopFrom: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        physicsBody!.categoryBitMask = PhysicsCategory.edge
    }
    
    private func generateCircles() -> [CircleShape] {
        let circles = generateRandomPositionCircle(radius: circleRadius, count: circlesCount, fieldSize: size)
        circles.forEach {
            prepareCircleToMovement($0, circleSpeed, self.size)
            addChild($0)
        }
        return circles
    }
    
    private func generateRandomPositionCircle(radius: CGFloat, count: Int, fieldSize: CGSize) -> [CircleShape] {
        
        var circles: [CircleShape] = []
        for _ in 0..<count {
            var randomPosition = CGPoint.random(maxX: Int(fieldSize.width - radius * 2),
                                                maxY: Int(fieldSize.height - radius * 2))
            randomPosition += radius
            let circle = CircleShape(radius)
            circle.zPosition = 10
            circle.position = randomPosition
            circles.append(circle)
        }
        
        return circles
    }

    private func prepareCircleToMovement(_ circle: CircleShape, _ speed: CGFloat, _ fieldSize: CGSize) {
        let randomPointToMove = CGPoint.random(maxX: Int(fieldSize.width), maxY: Int(fieldSize.height))
        circle.prepareToMovement(speed, randomPointToMove)
    }
    
    override func update(_ currentTime: TimeInterval) {
        
        let dt: TimeInterval
        if lastUpdateTime > 0 {
            dt = currentTime - lastUpdateTime
        } else {
            dt = 0
        }
        
        lastUpdateTime = currentTime
        
        guard isCirclesRunning else {
            return
        }
        
        circles.forEach { self.moveCircles($0, dt) }
    }
    
    private func moveCircles( _ circle: CircleShape, _ lastUpdateTimeDifference: TimeInterval) {
        circle.position += circle.velocity * CGFloat(lastUpdateTimeDifference)
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        
        let collision = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
        if collision == PhysicsCategory.edge | PhysicsCategory.circle {
            let circle = contact.bodyA.categoryBitMask == PhysicsCategory.circle ?
                contact.bodyA.node as! CircleShape : contact.bodyB.node as! CircleShape
            
            circle.correctDirectionAfterCollision(contact.contactPoint)
        } else if collision == PhysicsCategory.circle {
            (contact.bodyA.node as! CircleShape).correctDirectionAfterCollision(contact.contactPoint)
            (contact.bodyB.node as! CircleShape).correctDirectionAfterCollision(contact.contactPoint)
        }
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        guard let touch = touches.first else {
            return
        }
        let touchLocation = touch.location(in: self)

        if !isCirclesRunning, let node = nodes(at: touchLocation).first {
            let circle = node as! CircleShape
            circle.selected = !circle.selected
        } else {
            isCirclesRunning = !isCirclesRunning
        }
    }
    
}
