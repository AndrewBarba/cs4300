//
//  ParticleSystem.swift
//  Particles
//
//  Created by Andrew Barba on 11/15/15.
//  Copyright © 2015 abarba.me. All rights reserved.
//

import Foundation
import UIKit

struct ThreadedParticleSystem {
    
    var particleSize: CGFloat = 4.0
    var emitRate: NSTimeInterval = 1.0 / 60.0
    var emitPoint: CGPoint = CGPointMake(0.0, 0.0)
    var horizantleSpread: CGFloat = 100.0
    var verticalSpread: CGFloat = 140.0
    var massSpread: CGFloat = 15.0
    var particlesPerEmit: Int = 1
    var gravity = CGVector(dx: 0.0, dy: -20.0)
    
    // View to render particles
    private let view: UIView
    
    // MARK: - Timers
    private var emitTimer: dispatch_source_t?
    
    var particleCount: Int {
        return view.layer.sublayers!.count
    }
    
    // MARK: - Initialization
    
    init(view: UIView) {
        self.view = view
    }
    
    // MARK: - Start
    
    mutating func start() {
        emitTimer = Dispatch.timerAsync(emitRate, block: emitTimerFired)
    }
    
    mutating func stop() {
        guard let timer = emitTimer else { return }
        dispatch_source_cancel(timer)
        emitTimer = nil
    }
}

// MARK: - Render

extension ThreadedParticleSystem {
    
    func emitTimerFired() {
        for _ in 0..<particlesPerEmit { emit() }
    }
    
    func emit() {
        
        let mass = CGFloat.random(massSpread, massSpread * 2.0)
        let vx = CGFloat.random(-horizantleSpread, horizantleSpread)
        let vy = CGFloat.random(verticalSpread, verticalSpread * 2.0)
        
        ThreadedParticle(
            view: self.view,
            position: self.emitPoint,
            velocity: CGVector(dx: vx, dy: vy),
            acceleration: CGVector(dx: 0.0, dy: self.gravity.dy * mass),
            size: self.particleSize
        ).render()
    }
}
