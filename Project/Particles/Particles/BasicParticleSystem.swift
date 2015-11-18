//
//  ParticleSystem.swift
//  Particles
//
//  Created by Andrew Barba on 11/15/15.
//  Copyright © 2015 abarba.me. All rights reserved.
//

import Foundation
import UIKit

class BasicParticleSystem: NSObject {
    
    var particleSize: CGFloat = 4.0
    var emitRate: NSTimeInterval = 1.0 / 60.0
    var emitPoint: CGPoint = CGPointMake(0.0, 0.0)
    var horizantleSpread: CGFloat = 3.0
    var verticalSpread: CGFloat = 5.0
    var accelerationSpread: CGFloat = 0.3
    var particlesPerEmit: Int = 1
    var gravity = CGVector(dx: 0.0, dy: 0.15)
    
    // Particles in the system
    private var particles = Set<BasicParticle>()
    
    // View to render particles
    private let view: UIView
    
    var particleCount: Int {
        return view.layer.sublayers!.count
    }
    
    // MARK: - Tiemrs
    
    private var renderTimer: NSTimer? {
        didSet {
            guard let timer = renderTimer else { return }
            NSRunLoop.mainRunLoop().addTimer(timer, forMode: NSRunLoopCommonModes)
        }
    }
    
    // MARK: - Initialization
    
    init(view: UIView) {
        self.view = view
    }
    
    // MARK: - Start
    
    func start() {
        renderTimer = NSTimer(timeInterval: emitRate, target: self, selector: "renderTimerFired:", userInfo: nil, repeats: true)
    }
    
    func stop() {
        renderTimer?.invalidate()
        renderTimer = nil
        clear()
    }
}

// MARK: - Render

extension BasicParticleSystem {
    
    func renderTimerFired(timer: NSTimer) {
        for _ in 0...particlesPerEmit { emit() }
        render()
    }
    
    func render() {
        CATransaction.begin()
        CATransaction.setAnimationDuration(0.0)
        for particle in particles {
            particle.acceleration = gravity
            particle.move()
            if particle.dead {
                particle.die()
                particles.remove(particle)
            } else {
                particle.render()
            }
        }
        CATransaction.commit()
    }
    
    func clear() {
        for particle in particles {
            particle.layer.removeFromSuperlayer()
            particles.remove(particle)
        }
    }
}

// MARK: - Emit particles

extension BasicParticleSystem {
    
    func emit() {
        
        let vx = CGFloat.random(-horizantleSpread, horizantleSpread)
        let vy = CGFloat.random(-(verticalSpread + 2.0), -2.0)
        
        let particle = BasicParticle(
            view: view,
            position: emitPoint,
            velocity: CGVector(dx: vx, dy: vy),
            acceleration: gravity,
            size: particleSize
        )
        
        particles.insert(particle)
    }
}
