//
//  Kinematics.swift
//  Particles
//
//  Created by Andrew Barba on 11/17/15.
//  Copyright © 2015 abarba.me. All rights reserved.
//

import Foundation
import UIKit

struct Kinematics {
    
    let position: CGPoint
    let velocity: CGVector
    let acceleration: CGVector
    
    private let gutter = 300.0
    
    init(position: CGPoint, velocity: CGVector, acceleration: CGVector) {
        self.position = position
        self.velocity = velocity
        self.acceleration = acceleration
    }
}

// MARK: - Timing

extension Kinematics {
    
    var timeUpDown: NSTimeInterval {
        return (timeUp * 2) + timeDown
    }
    
    func position(time: NSTimeInterval) -> CGPoint {
        
        let vi = Double(velocity.dy)
        let ay = Double(acceleration.dy)
        
        let x = Double(velocity.dx) * time
        let y = (vi * time) + (0.5 * ay * pow(time, 2))
        
        return CGPointMake(
            position.x + CGFloat(x),
            position.y + CGFloat(y)
        )
    }
}

// MARK: - Rise

extension Kinematics {
    
    var timeUp: NSTimeInterval {
        
        let vi = Double(velocity.dy)
        let vf = Double(0.0)
        let ay = Double(acceleration.dy)
        
        return abs((vf - vi) / ay)
    }
    
    var timeDown: NSTimeInterval {
        
        let vi = Double(-velocity.dy)
        let dy = Double(-position.y) - gutter
        let ay = Double(acceleration.dy)
        
        let vf = -sqrt(pow(vi, 2) + (2 * ay * dy))
        
        return dy * (2 / (vi + vf))
    }
}
