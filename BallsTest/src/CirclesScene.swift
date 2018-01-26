//
//  CirclesScene.swift
//  BallsTest
//
//  Created by Alex Motor on 24.01.2018.
//  Copyright © 2018 Alex Motor. All rights reserved.
//

import SpriteKit

struct PhysicsCategory {
    static let none: UInt32 = 0b0
    static let edge: UInt32 = 0b1
    static let circle: UInt32 = 0b10
}

class CirclesScene: SKScene, SKPhysicsContactDelegate {
    
    var neutralCircleColor = SKColor.gray
    var correctCircleColor = SKColor.green
    var incorrectCircleColor = SKColor.red
    
    var circleRadius: CGFloat = 20.0
    var circleSpeed: CGFloat = 50.0

    /**
     Для изменения количества используй методы addCircle и removeCircle.
     */
    private(set) var circlesCount = 5
    
    /**
     Time for showing correct (and incorrect when was selected) circles after start movement.
     */
    var circleShowTimeAfterStart: TimeInterval = 3.0
    
    /**
     Time after showing correct and incorrect circles before stopping.
     */
    var allCircleNeutralTime: TimeInterval = 2.0
    
    weak var uiDelegate: CirclesSceneDelegate!
    
    private var lastUpdateTime: TimeInterval = 0
    private var timeToResetHighlight: TimeInterval = 0
    private var timeToStopRound: TimeInterval = 0
    private var circles: [CircleShape] = []
    private var isCirclesRunning = false
    
    /**
     Конструктор с передачей делегата, без которого не будет работать логика.
     */
    static func create(size: CGSize, delegate: CirclesSceneDelegate) -> CirclesScene {
        let scene = CirclesScene(size: size)
        scene.uiDelegate = delegate
        
        return scene
    }
    
    override func didMove(to view: SKView) {
        preparePhysics()
    }
    
    /**
     Удаляет с экрана все предыдущие шары и добавляет новые. Количество шаров не изменится.
     */
    func generateCirclesOnScreen() {
        circles.forEach { $0.removeFromParent() }
        circles.removeAll()
        
        circles = generateRandomPositionCircles(radius: circleRadius, count: circlesCount, fieldSize: size)
        circles.forEach { addChild($0) }
    }
    
    /**
     Запускает раунд и подсвечивает корректные шары.
     */
    func launch() {
        circles.forEach { $0.state = .neutral }
        highlightCorrectCircles(uiDelegate.correctCircles(circles.count))
        startRound()
    }
    
    private func startRound() {
        timeToResetHighlight = circleShowTimeAfterStart
        timeToStopRound = circleShowTimeAfterStart + allCircleNeutralTime
        
        isCirclesRunning = true
    }
    
    func highlightCorrectCircles(_ indexes: Set<Int>) {
        for index in indexes {
            guard index < circles.count else {
                assertionFailure()
                continue
            }
            
            circles[index].state = .correct
        }
    }
    
    private func resetHighlights() {
        circles.forEach { $0.state = .neutral }
    }
    
    /**
     Добавленяет новый шар на экран.
     */
    func addCircle(_ count: Int) {
        for _ in 0..<count {
            let circle = generateRandomPositionCircle(radius: circleRadius, fieldSize: size)
            circles.append(circle)
            addChild(circle)
        }
        
        circlesCount += count
    }
    
    /**
     Удаляет последние N шаров. Если в массиве столько нет, то удаляет все.
     */
    func removeCircle(_ count: Int) {
        let correctCount = count <= circles.count ? count : circles.count
        
        for _ in 0..<count {
            circles.removeLast().removeFromParent()
        }
        
        circlesCount -= correctCount
    }
    
    private func preparePhysics() {
        physicsWorld.gravity = CGVector.zero
        physicsWorld.contactDelegate = self
        physicsBody = SKPhysicsBody(edgeLoopFrom: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        physicsBody!.categoryBitMask = PhysicsCategory.edge
    }
    
    private func generateRandomPositionCircles(radius: CGFloat, count: Int, fieldSize: CGSize) -> [CircleShape] {
        
        var circles: [CircleShape] = []
        for _ in 0..<count {
            circles.append(generateRandomPositionCircle(radius: radius, fieldSize: size))
        }
        return circles
    }
    
    private func generateRandomPositionCircle(radius: CGFloat, fieldSize: CGSize) -> CircleShape {
        let randomPosition = CGPoint.random(maxX: Int(fieldSize.width - radius * 2),
                                            maxY: Int(fieldSize.height - radius * 2)) + radius

        let circle = CircleShape(radius)
        circle.zPosition = 10
        circle.position = randomPosition
        
        circle.neutralColor = neutralCircleColor
        circle.correctColor = correctCircleColor
        circle.incorrectColor = incorrectCircleColor
        
        prepareCircleToMovement(circle, circleSpeed, size)
        return circle
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
        
        timeToResetHighlight -= dt
        timeToStopRound -= dt
        
        if timeToResetHighlight <= 0 {
            resetHighlights()
        }
        
        if timeToStopRound <= 0 {
            stopRound()
        }
        
        circles.forEach { self.moveCircles($0, dt) }
    }
    
    private func stopRound() {
        isCirclesRunning = false
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
        
        guard !isCirclesRunning, let touch = touches.first else {
            return
        }
        let touchLocation = touch.location(in: self)

        if let node = nodes(at: touchLocation).first, uiDelegate.shouldHandleCircleSelection() {
            let circle = node as! CircleShape
            if circle.state == .neutral {
                circle.state = uiDelegate.wasSelectedCorrectCircle(circles.index(of: circle)!) ? .correct : .incorrect
            }
            
            uiDelegate.selectionHandled()
        }
    }
    
}
