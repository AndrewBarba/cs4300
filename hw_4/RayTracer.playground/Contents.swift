//: Playground - noun: a place where people can play

import Foundation

/**
    An abstract protocol representing a pixel in an image
*/
protocol Pixel {
    
}

/**
    An abstract protocol representing an object in a scene
 */
protocol Object {
    
}

/**
    An abstract protocol representing a full scene
*/
protocol Scene {
    
    // Array of pixels representing the scene
    var pixels: [Pixel] { get }
    
    // Array of objects in the scene
    var objects: [Object] { get }
    
    // Background color represented as a single pixel
    var backgroundColor: Pixel { get }
}

/**
    Render a scene by ray tracing each pixel in the scene
*/
func render(scene: Scene) -> [Pixel] {
    return scene.pixels.map { pixel in
        return raytrace(pixel, scene: scene)
    }
}

/**
    Raytrace a single pixel in the scene
 */
func raytrace(pixel: Pixel, scene: Scene, depth: Int = 0) -> Pixel {
    return scene.backgroundColor
}
