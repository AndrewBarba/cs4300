//
//  ThreadedParticle.swift
//  Particles
//
//  Created by Andrew Barba on 11/16/15.
//  Copyright © 2015 abarba.me. All rights reserved.
//

import Foundation
import UIKit

var count = 0

struct ThreadedParticle {
    
    // View containing the particle
    let view: UIView
    let color: UIColor
    let layer: CALayer
    
    // Physics
    let size: CGFloat
    var acceleration: CGVector
    var position: CGPoint
    var velocity: CGVector
    
    init(view: UIView, position: CGPoint, velocity: CGVector, acceleration: CGVector, size: CGFloat = 6.0, color: UIColor = UIColor.blueColor()) {
        
        self.view = view
        self.position = position
        self.velocity = velocity
        self.acceleration = acceleration
        self.size = size
        self.color = color
        self.layer = CALayer()
    }
}

// MARK: - Rendering

extension ThreadedParticle {
    
    func render() {
        
        Dispatch.async {
            let k = Kinematics(position: self.position, velocity: self.velocity, acceleration: self.acceleration)
            let duration = k.timeUpDown
            
            var values: [NSValue] = []
            for (var i = 0.0; i < duration; i += 0.1) {
                let p = k.position(i)
                let value = NSValue(CGPoint: self.pointForView(p))
                values.append(value)
            }
            
            Dispatch.main {
                self.layer.frame = CGRectMake(0.0, 0.0, self.size, self.size)
                self.layer.backgroundColor = self.color.CGColor
                self.layer.cornerRadius = self.size / 2.0
                self.layer.position = self.pointForView(self.position)
                self.view.layer.addSublayer(self.layer)
                
                let animation = CAKeyframeAnimation(keyPath: "position")
                animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
                animation.duration = duration
                animation.fillMode = kCAFillModeForwards
                animation.removedOnCompletion = false
                
                animation.values = values
                
                self.layer.addAnimation(animation, forKey: "position")
                
                Dispatch.async(duration, block: self.die)
            }
        }
    }
    
    func die() {
        layer.removeFromSuperlayer()
    }
    
    func pointForView(point: CGPoint) -> CGPoint {
        return CGPointMake(point.x, view.bounds.size.height - point.y)
    }
}
