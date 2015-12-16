//
//  CoreParticleSystem.swift
//  Particles
//
//  Created by Andrew Barba on 11/19/15.
//  Copyright © 2015 abarba.me. All rights reserved.
//

import Foundation
import UIKit

struct CoreParticleSystem {
    
    var particleSize: CGFloat = 4.0
    var emitRate: NSTimeInterval = 1.0 / 60.0
    var emitPoint: CGPoint = CGPointMake(0.0, 0.0)
    var horizantleSpread: CGFloat = 100.0
    var verticalSpread: CGFloat = 140.0
    var massSpread: CGFloat = 15.0
    var particlesPerEmit: Int = 1
    var gravity = CGVector(dx: 0.0, dy: -14.8)
    
    // Backing view
    private let view: UIView
    private let layer = CAEmitterLayer()
    private let cell = CAEmitterCell()
    
    var particleCount: Int {
        return layer.sublayers?.count ?? 0
    }
    
    init(view: UIView) {
        self.view = view
    }
    
    func start() {
        
        layer.frame = view.bounds
        layer.emitterSize = CGSizeMake(particleSize, particleSize)
        layer.emitterPosition = emitPoint
        layer.renderMode = kCAEmitterLayerAdditive
        layer.emitterShape = kCAEmitterLayerCircle
        
        cell.birthRate = Float(1 / emitRate) * Float(particlesPerEmit)
        cell.lifetime = 10.0
        cell.lifetimeRange = 0
        cell.velocity = 200
        cell.velocityRange = 50
        cell.yAcceleration = 200
        cell.emissionLongitude = CGFloat(M_PI_4 * 6)
        cell.emissionRange = CGFloat(M_PI_4)
        cell.spin = 0
        cell.spinRange = 0
        cell.scaleRange = 0.0
        cell.scaleSpeed = 0.0
        cell.color = UIColor.blueColor().CGColor
        
        let img: UIImage
        let rect = CGRectMake(0, 0, particleSize, particleSize)
        UIGraphicsBeginImageContext(CGSizeMake(particleSize, particleSize))
        let context = UIGraphicsGetCurrentContext()
        CGContextSetFillColorWithColor(context, cell.color);
        CGContextFillEllipseInRect(context, rect);
        img = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        cell.contents = img.CGImage
        
        layer.emitterCells = [cell]
        view.layer.addSublayer(layer)
    }
}
