//
//  RayTrace.swift
//
//  Created by Andrew Barba on 12/9/15.
//  Copyright (c) 2015 Andrew Barba. All rights reserved.
//

import Foundation

let MAX_TRACE_DEPTH = 128

/**
    An abstract protocol representing a pixel in an image
*/
protocol Pixel {
    
    static var blackPixel: Pixel { get }
    
    func attenuate(value: Int) -> Pixel
    
    func reflect(pixel: Pixel, reflectivity: Int) -> Pixel
    
    func refract(pixel: Pixel, transmit: Int) -> Pixel
}

/**
    An abstract protocol representing an object in a scene
*/
protocol Object {
    
    var reflectivity: Int { get }
    
    var transmittivity: Int { get }
    
    func distanceToNearestIntersection(ray: Ray) -> Int?
    
    func pointToNearestIntersection(ray: Ray) -> (x: Int, y: Int)?
    
    func attenuation(object: Object, light: Light, position: (x: Int, y: Int)) -> Int
}

/**
    An abstract protocol representing a light source in a scene
*/
protocol Light {
    
}

/**
    An abstract protocol representing a single ray from a point to a pixel
*/
protocol Ray {
    
    func reflected(position: (x: Int, y: Int)) -> Ray
    
    func refracted(position: (x: Int, y: Int)) -> Ray
}

/**
    An abstract protocol representing a full scene
*/
protocol Scene {
    
    // Array of pixels representing the scene
    var pixels: [Pixel] { get }
    
    // Array of objects in the scene
    var objects: [Object] { get }
    
    // Array of light sources in the scene
    var lights: [Light] { get }
    
    // Background color represented as a single pixel
    var backgroundColor: Pixel { get }
    
    // Black pixel
    var blackColor: Pixel { get }
    
    // Generate a ray R from the viewing position to this pixel.
    func generateRay(pixel: Pixel) -> Ray
}

/**
    Render a scene by ray tracing each pixel in the scene
*/
func render(scene: Scene) -> [Pixel] {
    return scene.pixels.map { pixel in
        
        // generate a ray for this pixel
        let ray = scene.generateRay(pixel)
        
        // ray trace the ray with the given scene
        return raytrace(ray, scene: scene)
    }
}

/**
    Raytrace a single pixel in the scene
 */
func raytrace(ray: Ray, scene: Scene, depth: Int = 0) -> Pixel {
    
    var object: Object? = nil
    var distance: Int = NSIntegerMax
    
    for obj in scene.objects {
        if let dist = obj.distanceToNearestIntersection(ray) where dist < distance {
            distance = dist
            object = obj
        }
    }
    
    // if we don't have an object, or a point to nearest intersection
    // return the scenes background color
    guard let obj = object, pos = obj.pointToNearestIntersection(ray) else { return scene.backgroundColor }
    
    var pixel = scene.blackColor
    
    // loop through light sources
    for light in scene.lights {
        
        // loop through objects
        for _obj in scene.objects {
            
            // attenutate the color by each object based on how much light it blocks
            pixel = pixel.attenuate(obj.attenuation(_obj, light: light, position: pos))
        }
    }
    
    // check recursion depth
    guard depth < MAX_TRACE_DEPTH else { return pixel }
    
    let refractedRay = ray.refracted(pos)
    let reflectedRay = ray.reflected(pos)
    
    // recursive reflec
    let reflectedPixel = raytrace(reflectedRay, scene: scene, depth: depth + 1)
    pixel = pixel.reflect(reflectedPixel, reflectivity: obj.reflectivity)
    
    // recursive refract
    let refractedPixel = raytrace(refractedRay, scene: scene, depth: depth + 1)
    pixel = pixel.refract(refractedPixel, transmit: obj.transmittivity)
    
    return pixel
}

