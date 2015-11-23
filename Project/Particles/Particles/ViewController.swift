//
//  ViewController.swift
//  Particles
//
//  Created by Andrew Barba on 11/15/15.
//  Copyright © 2015 abarba.me. All rights reserved.
//

import Foundation
import UIKit

class ViewController: UIViewController {
    
//    var particleSystem: BasicParticleSystem!
//    var particleSystem: ThreadedParticleSystem!
    var particleSystem: CoreParticleSystem!
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
//        particleSystem = BasicParticleSystem(view: view)
//        particleSystem = ThreadedParticleSystem(view: view)
        particleSystem = CoreParticleSystem(view: view)
        
        particleSystem.particleSize = 4.0
        particleSystem.emitRate = 1.0 / 120.0
        particleSystem.particlesPerEmit = 100
        particleSystem.emitPoint = CGPointMake(
            CGRectGetMidX(view.bounds),
            CGRectGetMidY(view.bounds)
        )
        
        particleSystem.start()
    }
    
    
    
    
    
    
    
    
    
    
    
    let label = UILabel()
    private var updateTimer: dispatch_source_t?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Label
        label.frame = CGRectMake(30.0, 30.0, 200.0, 100.0)
        view.addSubview(label)
        updateTimer = Dispatch.timerMain(0.5) {
            self.label.text = "Particles: \(self.particleSystem.particleCount)"
        }
    }
}
