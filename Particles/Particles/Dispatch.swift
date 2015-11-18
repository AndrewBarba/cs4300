//
//  Dispatch.swift
//  Tablelist
//
//  Created by Andrew Barba on 8/25/15.
//  Copyright (c) 2015 Tablelist Inc. All rights reserved.
//

import Foundation

public struct Dispatch {
    
    // MARK: - Async
    
    /**
        Asynchronously dispatch a block on a background thread
    */
    public static func async(block: ()->()) {
        let queue = dispatch_queue_create("com.abarba.queue.async", nil)
        async(queue, block: block)
    }
    
    public static func async(queue: dispatch_queue_t, block: ()->()) {
        dispatch_async(queue, block)
    }
    
    /**
        Asynchronously dispatch a block on a background thread after a specified number of seconds
    */
    public static func async(queue: dispatch_queue_t, time: Double, block: ()->()) {
        let after = dispatch_time(DISPATCH_TIME_NOW, Int64(time * Double(NSEC_PER_SEC)))
        dispatch_after(after, queue, block)
    }
    
    public static func async(time: Double, block: ()->()) {
        let queue = dispatch_queue_create("com.abarba.queue.async.after", nil)
        async(queue, time: time, block: block)
    }
    
    // MARK: - Main
    
    /**
        Asynchronously dispatch a block on the main thread
    */
    public static func main(block: ()->()) {
        async(dispatch_get_main_queue(), block: block)
    }
    
    /**
        Asynchronously dispatch a block on the main thread after a specified number of seconds
    */
    public static func main(time: Double, block: ()->()) {
        async(dispatch_get_main_queue(), time: time, block: block)
    }
    
    // MARK: - Synchronized
    
    /**
        Swift function for ObjC @synchronized
    */
    public static func sync(queue: dispatch_queue_t, block: () -> ()) {
        dispatch_sync(queue, block)
    }
    
    // MARK: - Timer
    
    public static func timerMain(interval: Double, block: () -> ()) -> dispatch_source_t {
        return timer(interval, queue: dispatch_get_main_queue(), block: block)
    }
    
    public static func timerAsync(interval: Double, block: () -> ()) -> dispatch_source_t {
        let queue = dispatch_queue_create("com.abarba.queue.timer.async", nil)
        return timer(interval, queue: queue, block: block)
    }
    
    public static func timer(interval: Double, queue: dispatch_queue_t, block: () -> ()) -> dispatch_source_t {
        let timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
        dispatch_source_set_timer(
            timer,
            dispatch_time(DISPATCH_TIME_NOW, Int64(interval * Double(NSEC_PER_SEC))),
            UInt64(interval * Double(NSEC_PER_SEC)),
            10
        );
        dispatch_source_set_event_handler(timer, block);
        dispatch_resume(timer);
        return timer;
    }
}
