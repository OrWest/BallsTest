//
//  Ball.swift
//  BallsTest
//
//  Created by Alex Motor on 24.01.2018.
//  Copyright © 2018 Alex Motor. All rights reserved.
//

import Foundation
import SpriteKit

class CircleShape: SKShapeNode {
    
    var selected: Bool = false {
        didSet {
            updateColor()
        }
    }
    
    var direction = CGPoint.zero
    
    var moveSpeed: CGFloat = 0
    
    var velocity: CGPoint {
        return direction * moveSpeed
    }
    
    convenience init(_ radius: CGFloat) {
        self.init(circleOfRadius: radius)
        name = "circle"
        strokeColor = SKColor.clear
        physicsBody = SKPhysicsBody(circleOfRadius: radius)
        physicsBody!.categoryBitMask = PhysicsCategory.circle
        physicsBody!.contactTestBitMask = PhysicsCategory.circle | PhysicsCategory.edge
                
        updateColor()
    }
    
    func prepareToMovement(_ speed: CGFloat, _ pointToMove: CGPoint) {
        let offset = pointToMove - position
        direction = offset / offset.length()
        moveSpeed = speed
    }
    
    func correctDirectionAfterCollision(_ contactPoint: CGPoint) {
        let offset = contactPoint - position
        let contactDirection = offset / offset.length() * -1

        let scalarVector = direction * -1 * contactDirection
        direction = contactDirection * CGFloat(2) * scalarVector.scalar() + direction
    }
    
    private func updateColor() {
        fillColor = selected ? SKColor.green : SKColor.gray
    }
    
}
