//
//  LogicMock.swift
//  BallsTest
//
//  Created by Motarykin, Alexander on 26.01.18.
//  Copyright © 2018 Alex Motor. All rights reserved.
//

import UIKit
import SpriteKit

class LogicMock: CirclesSceneDelegate {
    
    private let needCorrectCount = 3
    weak var scene: CirclesScene!
    
    private var correctIndexes: Set<Int> = []
    private var tryCount: Int = 0
    private var correctCount: Int = 0
    
    func start() {
        scene.generateCirclesOnScreen()
        scene.launch()
    }
    
    func correctCircles(_ count: Int) -> Set<Int> {
        correctIndexes.removeAll()
        
        for _ in 0..<needCorrectCount {
            var newIndex: Int
            repeat {
                newIndex = Int(arc4random_uniform(UInt32(count)))
            } while correctIndexes.contains(newIndex)
            
            correctIndexes.insert(newIndex)
        }
        
        return correctIndexes
    }
    
    func wasSelectedCorrectCircle(_ index: Int) -> Bool {
        let result = correctIndexes.contains(index)
        if result {
            correctCount += 1
        }
        
        tryCount += 1
        return result
    }
    
    func shouldHandleCircleSelection() -> Bool {
        return tryCount < needCorrectCount
    }
    
    func selectionHandled() {
        guard tryCount == needCorrectCount else {
            return
        }
        
        scene.highlightCorrectCircles(correctIndexes)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2)) {
            if self.correctCount == self.needCorrectCount {
                self.scene.addCircle(2)
            } else {
                self.scene.removeCircle(1)
            }
            
            self.tryCount = 0
            self.correctCount = 0
            self.scene.launch()
        }
    }
}
