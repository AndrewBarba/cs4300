
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

## Results

## Discussion

## References  
