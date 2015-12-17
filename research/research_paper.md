How-To Efficiently Animate with Core Animation
==============================================

## Abstract

This paper looks to introduce Core Animation to the common graphics artist. It discusses the original need for a more performant animation system on mobile phones, when it was first introduced, and how it has performed overtime. In the methods section we discuss the layer hierarchy used behind the scenes of Core Animation and then dive into threading and common misconceptions about the inner workings of the framework. Finally we introduce real examples of Core Animation and demonstrate how you can start using it today in your applications. All code examples are written in Swift 2.0; the preferred language for working with Core Animation. Optionally, all of the examples will work with the Objective-C runtime although this is not recommended for programmers unfamiliar with the language.

## Introduction

#### History

In 2006 the world was abuzz with rumors when Apple Computers officially dropped "Computers" from their name, hinting that something big was in store. Rumors had been swirling of an Apple made mobile phone, except no one but the core team would ever know what it would truly look like and be capable of. Touch screen phones were not entirely unheard of at the time, with devices from Palm leading the way with their resistive screens and stylus. However, in 2007, that may have been the last time Palm was recognized as a leader in touch screen technology. Apple introduced the original iPhone with a capacitive touch screen, a first in the industry, and a mind blowing operating system that felt life like, mimicking physics of everyday objects. The audience literally gasped in amazement when Steve Jobs first demoing how "scrolling" functioned; with a single flick of the finger the list of names came alive and sprung into position as it reached the end. It was obvious the hardware was revolutionary, but the software running on the device was just as so. It was backed by framework which the original iPhone team dubbed `CoreAnimation`.

#### Need for Performance

When the original iPhone came out in 2007, desktop computers were running graphics cards with gigabytes of memory and processors running at speeds upwards of 3.0 gigahertz. How did the compare to mobile devices? Well, it didn't. Phones had no dedicated graphics cards and were running at speeds of around 300 megahertz. Not to mention, desktop computers had a minimum of 2 cores, with a lot having 4 cores, and mobile phone had 1 core. All together you were looking at devices that had about 1/100th the processing power of a desktop computer and around 1/50th the processing power of a laptop. With these types of limitations, it was crucial to develop a framework that could use as little resources as possible to still animate content efficiently yet maintain the life-like feel that Apple wanted.

#### Architecture

Because of the speed of the processor, Apple knew there was no way to achieve the results they wanted by only running animation on the CPU. Even though there was no dedicated graphics chip in the phone, the processor was built with a subset of silicon that had threads specifically for graphics processing. Core Animation took full advantage of this in a very clever way. It designed an implicit animation model where the starting position and final position of a view could be specified on the CPU, and then Core Animation could interpolate between those positions, taking into account physics, and render the frames on the graphics threads available to the device.

One limitation of iOS that even exists today, is all UI behavior must be specified on the main thread. From placing and removing views, to specifying transformations and changing view colors. The main thread is also the thread that recognizes touch gestures, and because you always want the device to feel responsive to the user, it is crucial to keep as little processing on the main thread as possible. If the animations had to be rendered on the same main thread, then users would experience very slow response times to their touch, making for a very unpleasant experience. However, since the animations are happening on background threads, users can actually interact with content even as it is animating. For example, suddenly stop a list from scrolling, and flick it in the other direction. These types of interactions greatly increase the user experience and ultimately led to Apple's domination of the mobile handset.

## Methods

Let's start with basic view and add it to the screen:

```
// Initialize a view
let view = UIView(frame: CGRectMake(0, 0, 100.0, 100.0))
view.backgroundColor = UIColor.blueColor()

// Add the view to the window
self.window.addSubview(view)
```

The above block of code should give us a blue square in the top left corner of the screen. Now we want to use Core Animation to animate the view to the top right corner of the screen. In it's most basic form:

```
UIView.animateWithDuration(2.0) {
  let frame = view.frame
  frame.origin.x = window.frame.size.width - frame.size.width
  view.frame = frame
}
```

That's all there's to it. This view will now animate the to the top right corner in exactly and it will take exactly 2.0 seconds to do so. Now you might be wondering if this animation happens linearly, and the answer is no. By default iOS applies an ease-in-out bezier curve to the animation to give it a more gradual feel. This function alone allows us to accomplish a huge number of animations with little to no work. The magic here is the fact that we are simply specifying where we want the view to end up, and Core Animation is behind the scenes figuring out all the different locations this view will be on background threads. It then passes off the path of the view to GPU and magically provides a buttery smooth animation. Now let's move the view and make it rotate:

```
UIView.animateWithDuration(2.0) {

  // move view to top right corner
  let frame = view.frame
  frame.origin.x = window.frame.size.width - frame.size.width
  view.frame = frame

  // rotate 360 degrees
  view.affineTransform = CGAffineTransformMakeRotation(M_PI)
}
```

Event though two transformations were specified, Core Animation is smart enough to figure out what the view will look like at each frame with both applied simultaneously. Perhaps you don't want both animations to be applied simultaneously, Core Animation makes that easy too:

```
UIView.animateWithDuration(2.0, animation: {

  // move view to top right corner
  let frame = view.frame
  frame.origin.x = window.frame.size.width - frame.size.width
  view.frame = frame

}, completion: { _ in

  UIView.animateWithDuration(1.0) {
    // rotate 360 degrees
    view.affineTransform = CGAffineTransformMakeRotation(M_PI)
  }
}
```

Core Animation provides many options on top of the default `animateWithDuration` method. One of them is the option to specify a completion handler so we can run a block of code when the animation is complete. You'll notice the strange `_ in` in the handler, this is because I actually hid a variable which is a boolean and tells you whether the animation was able to fully animate the entire transformation or if it was cut off for some reason. Depending on whether or not th animation was stopped, perhaps the user dismissed the current view, you may want to take different action. For example:

```
UIView.animateWithDuration(2.0, animation: {

  // move view to top right corner
  let frame = view.frame
  frame.origin.x = window.frame.size.width - frame.size.width
  view.frame = frame

}, completion: { completedAnimation in

  // make sure we completed the animation before continuing
  // otherwise just stop here
  guard completedAnimation else { return }

  UIView.animateWithDuration(1.0) {
    // rotate 360 degrees
    view.affineTransform = CGAffineTransformMakeRotation(M_PI)
  }
}
```

These couple functions just scratch the surface of what is possible in Core Animation. Image compositing, video encoding and decoding, and even animations based on the accelerometer and gyroscope of the device are all posssible with more advanced Core Animation frameworks.

## Results

Using Core Animation effectively can dramatically enhance the end user experience. Animation is a way to guide the human eye to a result, making the overall experience more fluid and lifelike. User's may not always appreciate good animation outright, but subconsciously you can persuade a user to take certain actions within an application by guiding them in the right direction. The examples above show specifically how to animate a single view, or a group of views, but something to also keep in mind is *timing*.

Let's define a function that allows us to easily dispatch a block of code after a specified number of seconds:

```
public static func delay(seconds: Double, block: () -> ())
```

This will be a global function that takes in two arguments: the number of seconds that you want to delay execution, and the block of code (or closure) that you want to be run. To keep the example simple and Core Animation friendly, this function will dispatch the given block onto the main thread.

Implementing this function brings us to an important counterpart of Core Animation, Grand Central Dispatch (GCD). GCD is an open source Apple technology that concurrent code dramatically easier to write, but more importantly, dramatically easier to reason about. I wanted to do something a bit original for this project, so I actually made a YouTube tutorial specifically about Grand Central Dispatch. 4 years ago I made an iOS tutorial and then never made one again. Turns out that video had over 30,000 views and I figured this was a good opportunity to make another one. The video can be watched here: [Threading and Concurrency with Grand Central Dispatch and Swift 2.0](https://www.youtube.com/watch?v=EZGVxQ1oRTI)

The finished implementation of this function, also discussed in the tutorial in more detail, is the following:

```
public static func delay(seconds: Double, block: () -> ()) {
  let nanoSeconds = Int64(seconds * Double(NSEC_PER_SEC))
  let delay = dispatch_time(DISPATCH_TIME_NOW, nanoSeconds)
  dispatch_after(delay, dispatch_get_main_queue(), block)
}
```

Now that we have a function that can control when we dispatch code at an extremely precise time interval, we can begin to tweak our animations even further. A popular function that you override in iOS development is the `viewDidLoad` method that fires when a view is initialized and is about to come on screen. This is a great time to begin animations because now you are guaranteed that your views are front facing to the user. The problem with just starting an animation in this method is the view is not actually on screen yet, it is being animated on screen with either a fade or some modal transition. What you really want to do is delay the animation by a fraction of a second to give the view time to settle. We can do this quite easily:

```
delay(0.3) {
  UIView.animateWithDuration(0.3) { ... }
}
```

Timing is key to animation and Grand Central Dispatch gives a programmer precise control over timing.

## Discussion

Today Core Animation has become such a core piece of the system that many iOS and OS X developers, particular newer ones, are using Core Animation without even knowing it. From compositing, to top level `UIView` methods, to scrolling a basic list, each one at some point in the stack touches the Core Animation rendering layer. Core Animation was originally developed on top of Objective-C and today the default language for iOS and OS X development is Swift. Swift took a very modern, safe approach to programming. With things like optional, closures and generics, the language has very different constructs and paradigms than Objective-C. It will be interesting to see how Core Animation progresses under the Swift language, and whether or not it will adopt more Swift like syntax and paradigms.

## References

#### About Core Animation
[https://developer.apple.com/library/mac/documentation/Cocoa/Conceptual/CoreAnimation_guide/Introduction/Introduction.html](https://developer.apple.com/library/mac/documentation/Cocoa/Conceptual/CoreAnimation_guide/Introduction/Introduction.html)

#### Core Animation with Marin Todorov
[http://www.raywenderlich.com/95785/core-animation-with-marin-todorov-podcast-s03-e05](http://www.raywenderlich.com/95785/core-animation-with-marin-todorov-podcast-s03-e05)

#### Dr. Brad Larson on Core Animation and OpenGL ES 2.0
[https://itunes.apple.com/us/itunes-u/advanced-iphone-development/id407243028?mt=10](https://itunes.apple.com/us/itunes-u/advanced-iphone-development/id407243028?mt=10)
