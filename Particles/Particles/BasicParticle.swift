//
//  Particle.swift
//  Particles
//
//  Created by Andrew Barba on 11/15/15.
//  Copyright © 2015 abarba.me. All rights reserved.
//

import Foundation
import UIKit

class BasicParticle: NSObject {
    
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
        
        super.init()
        
        setupLayer()
    }
    
    private func setupLayer() {
        layer.frame = CGRectMake(position.x, position.y, size, size)
        layer.backgroundColor = color.CGColor
        layer.cornerRadius = size / 2.0
        view.layer.addSublayer(layer)
    }
}

// MARK: - Rendering

extension BasicParticle {
    
    func render() {
        layer.position = position
    }
    
    func die() {
        layer.removeFromSuperlayer()
    }
    
    var dead: Bool {
        let deadX = position.x < -10.0 || position.x > view.bounds.size.width + 10.0
        let deadY = position.y > view.bounds.size.height + 10.0
        return deadX || deadY
    }
}

// MARK: - Movement

extension BasicParticle {
    
    func move() {
        position = CGPoint(x: position.x + velocity.dx, y: position.y + velocity.dy)
        velocity = CGVector(dx: velocity.dx + acceleration.dx, dy: velocity.dy + acceleration.dy)
    }
}
