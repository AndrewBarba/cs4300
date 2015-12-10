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
    let layer: CAShapeLayer
    
    // Physics
    let size: CGFloat
    var acceleration: CGVector
    var position: CGPoint
    var velocity: CGVector
    
    // Threads
    private let queue = dispatch_queue_create("particle.die.queue", DISPATCH_QUEUE_SERIAL)
    
    init(view: UIView, position: CGPoint, velocity: CGVector, acceleration: CGVector, size: CGFloat = 6.0, color: UIColor = UIColor.blueColor()) {
        
        self.view = view
        self.position = position
        self.velocity = velocity
        self.acceleration = acceleration
        self.size = size
        self.color = color
        self.layer = CAShapeLayer()
        
        setupLayer()
    }
}

// MARK: - Rendering

extension ThreadedParticle {
    
    func addLayer() {
        view.layer.addSublayer(layer)
    }
    
    func setupLayer() {
        layer.frame = CGRectMake(0.0, 0.0, size, size)
        layer.fillColor = self.color.CGColor
        layer.path = UIBezierPath(ovalInRect: layer.bounds).CGPath
        layer.opaque = true
        layer.position = self.pointForView(self.position)
        layer.drawsAsynchronously = true
    }
    
    func render() {
        let k = Kinematics(position: self.position, velocity: self.velocity, acceleration: self.acceleration)
        let duration = k.timeUpDown
        
        var values: [NSValue] = []
        for (var i = 0.0; i < duration; i += 0.1) {
            let p = k.position(i)
            let value = NSValue(CGPoint: self.pointForView(p))
            values.append(value)
        }
        
        let animation = CAKeyframeAnimation(keyPath: "position")
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        animation.duration = duration
        animation.fillMode = kCAFillModeForwards
        animation.removedOnCompletion = false
        animation.values = values
        layer.addAnimation(animation, forKey: "position")

        Dispatch.main(block: addLayer)
        Dispatch.async(queue, delay: duration, block: die)
    }
    
    func die() {
        layer.removeFromSuperlayer()
    }
    
    func pointForView(point: CGPoint) -> CGPoint {
        return CGPointMake(point.x, view.bounds.size.height - point.y)
    }
}
