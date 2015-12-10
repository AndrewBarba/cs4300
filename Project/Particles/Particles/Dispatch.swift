//
//  Dispatch.swift
//  Tablelist
//
//  Created by Andrew Barba on 8/25/15.
//  Copyright (c) 2015 Tablelist Inc. All rights reserved.
//

import Foundation

public struct Dispatch {
    
    public static func queue(label: String = "com.abarba.queue.async", _ attr: dispatch_queue_attr_t = DISPATCH_QUEUE_SERIAL) -> dispatch_queue_t {
        return dispatch_queue_create(label, attr)
    }
    
    // MARK: - Async

    public static func async(queue: dispatch_queue_t = Dispatch.queue(), delay: Double = 0.0, block: ()->()) {
        let after = dispatch_time(DISPATCH_TIME_NOW, Int64(delay * Double(NSEC_PER_SEC)))
        dispatch_after(after, queue, block)
    }
    
    /**
        Asynchronously dispatch a block on the main thread after a specified number of seconds
    */
    public static func main(delay delay: Double = 0.0, block: ()->()) {
        async(dispatch_get_main_queue(), delay: delay, block: block)
    }
    
    // MARK: - Timer
    
    public static func timerMain(interval: Double, block: () -> ()) -> dispatch_source_t {
        return timer(interval, queue: dispatch_get_main_queue(), block: block)
    }
    
    public static func timerAsync(interval: Double, block: () -> ()) -> dispatch_source_t {
        let queue = dispatch_queue_create("com.abarba.queue.timer.async", DISPATCH_QUEUE_SERIAL)
        return timer(interval, queue: queue, block: block)
    }
    
    public static func timer(interval: Double, queue: dispatch_queue_t, block: () -> ()) -> dispatch_source_t {
        let timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
        dispatch_source_set_timer(timer, DISPATCH_TIME_NOW, UInt64(interval * Double(NSEC_PER_SEC)), 10);
        dispatch_source_set_event_handler(timer, block);
        dispatch_resume(timer);
        return timer;
    }
}

public extension dispatch_source_t {
    
    public func invalidate() -> Self {
        dispatch_source_cancel(self)
        return self
    }
}
