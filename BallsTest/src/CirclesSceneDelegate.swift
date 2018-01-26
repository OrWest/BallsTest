//
//  CirclesSceneDelegate.swift
//  BallsTest
//
//  Created by Motarykin, Alexander on 26.01.18.
//  Copyright © 2018 Alex Motor. All rights reserved.
//

import Foundation

protocol CirclesSceneDelegate: class {
    
    func correctCircles(_ count: Int) -> Set<Int>
    
    func wasSelectedCorrectCircle(_ index: Int) -> Bool
    
    func shouldHandleCircleSelection() -> Bool
    
    func selectionHandled()
}
