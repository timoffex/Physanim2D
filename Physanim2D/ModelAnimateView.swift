//
//  ModelAnimateView.swift
//  Physanim2D
//
//  Created by Tima Peshin on 1/22/17.
//  Copyright © 2017 timoffex. All rights reserved.
//

import CoreGraphics
import UIKit


class ModelAnimateView : UIView {
    
    
    var model: Model!
    
    
    /// The radius of the dot drawn at every joint in the model.
    var pointRadius: CGFloat = 3
    
    /// The screen rectangle in world-coordinates. Anything in this rectangle
    /// is guaranteed to be shown on the screen.
    var viewRect: CGRect!
    
    
    /// Maximum distance between a touch and a joint for the joint to be considered under the touch.
    var maxSelectDistance: Double = 5
    
    
    /// The indices and positions of joints that should be locked in place.
    var lockedJoints: [(Int, Vec2)] = []
    
    /// The joint that is currently being dragged. Nil if nothing is being dragged.
    var draggedJoint: Int?

    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        
        
        // Tapping on the screen should lock/unlock joints.
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapOccured))
        tapRecognizer.numberOfTapsRequired = 1
        
        
        // Panning (dragging) should drag joints.
        let panRecognizer = UIPanGestureRecognizer(target: self, action: #selector(panOccured))
        panRecognizer.maximumNumberOfTouches = 1
        
        
        self.addGestureRecognizer(tapRecognizer)
        self.addGestureRecognizer(panRecognizer)
    }
    
    
    
    
    /// This draws the view.
    override func draw(_ rect: CGRect) {
        if let ctx = UIGraphicsGetCurrentContext() {
            
            if model != nil {
                // Draw the model.
                
                // 1) Get model's joint positions in screen coordinates.
                let positions = model.getPositions()
                
                
                let screenPositions = worldToScreenCoords(pos: positions, screenRect: rect)
                
                
                // 2) Draw a line from every joint to its parent.
                ctx.setLineWidth(4)
                ctx.setStrokeColor(UIColor.black.cgColor)
                for idx in 1..<model.numJoints {
                    let parent = model.jointParents[idx]
                    ctx.strokeLineSegments(between: [screenPositions[idx], screenPositions[parent]])
                }
                
                
                // 3) Draw a little circle at the position of every joint.
                for idx in 0..<model.numJoints {
                    let pos = screenPositions[idx]
                    
                    // If this joint is being dragged..
                    if draggedJoint != nil && draggedJoint == idx {
                        ctx.setFillColor(UIColor.yellow.cgColor) // ..set color to yellow
                        
                        // Else if this joint is locked..
                    } else if lockedJoints.contains(where: {(i,v) in i == idx}) {
                        
                        ctx.setFillColor(UIColor.red.cgColor) //..set color to red
                        
                    } else {
                        
                        if idx == 0 { // If this is the root joint..
                            ctx.setFillColor(UIColor.blue.cgColor) // ..set color to blue
                        } else {
                            ctx.setFillColor(UIColor.green.cgColor) // ..set color to green
                        }
                    }
                    
                    ctx.fillEllipse(in: CGRect(x: pos.x-pointRadius, y: pos.y-pointRadius, width: 2*pointRadius, height: 2*pointRadius))
                }
            }
        }
    }
    
    
    
    /// Responds to a tap on the screen.
    func tapOccured(recognizer: UITapGestureRecognizer) {
        
        let screenLocation = recognizer.location(in: self)
        
        let worldLocation = screenToWorldCoords(screenCoords: screenLocation)
        
        
        let (closestJointIdx, closestJointPosition, closestJointDist) = findClosestJoint(to: worldLocation)
        
        
        // If we tapped on a joint..
        if closestJointDist <= maxSelectDistance {
            
            // If the joint was locked before..
            if let lockedIdx = lockedJoints.index(where: {(i,v) in i == closestJointIdx}) {
                // Unlock it.
                lockedJoints.remove(at: lockedIdx)
            } else {
                // Else, lock it.
                lockedJoints.append((closestJointIdx, closestJointPosition))
            }
            
            setNeedsDisplay()
        }
    }
    
    func panOccured(recognizer: UIPanGestureRecognizer) {
        
        let worldLocation = screenToWorldCoords(screenCoords: recognizer.location(in: self))
        
        // If the pan is stopped or cancelled..
        if recognizer.state == UIGestureRecognizerState.cancelled
            || recognizer.state == UIGestureRecognizerState.ended {
            // Stop dragging and exit.
            draggedJoint = nil
            return
        }
        
        
        if draggedJoint == nil {
            let (idx, _, dist) = findClosestJoint(to: worldLocation)
            
            // If we're too far, just exit.
            if dist > maxSelectDistance {
                return
            } else {
                draggedJoint = idx
            }
        }
        
        
        // Dragged joint is not nil at this point for sure and we're definitely dragging.
        
        let targetPositions = lockedJoints.map { (i,v) in v } + [worldLocation]
        let indices = lockedJoints.map { (i,v) in i } + [draggedJoint!]
        
        
        // Move the model, keeping locked joints in their places and moving the dragged joint to the new location.
        model.moveToPoseWith(targetPositions: targetPositions, forIndices: indices, maxIterations: 30)
        
        // Redraw.
        setNeedsDisplay()
    }
    
    
    
    /// Returns the index of the joint closest to the given position, its actual position, and its distance from that position.
    func findClosestJoint(to pos: Vec2) -> (Int, Vec2, Double) {
        
        let jointPositions = model.getPositions()
        
        var minIdx = 0
        var minDist = (jointPositions[0] - pos).magnitude
        
        for idx in 1..<model.numJoints {
            let dist = (jointPositions[idx] - pos).magnitude
            
            if dist < minDist {
                minIdx = idx
                minDist = dist
            }
        }
        
        
        return (minIdx, jointPositions[minIdx], minDist)
    }
    
    
    
    /// Takes a set of points in world coordinates and converts each point to screen coordinates
    /// using the given screen rect and viewRect.
    func worldToScreenCoords(pos: [Vec2], screenRect: CGRect) -> [CGPoint] {
        // 1) Get the normalized coordinates in our viewRect.
        let normalized = pos.map {
            CGPoint(x: (CGFloat($0.x) - viewRect.minX) / viewRect.size.width,
                    y: (CGFloat($0.y) - viewRect.minY) / viewRect.size.height)
        }
        
        // 2) Decide how viewRect should be positioned in screenRect while preserving aspect ratio.
        let viewAspect = viewRect.size.width / viewRect.size.height
        let screenAspect = screenRect.size.width / screenRect.size.height
        
        
        if viewAspect > screenAspect {
            // If view aspect > screen aspect, there will be empty space above and below the view.
            
            let viewWidth = screenRect.size.width
            let viewHeight = screenRect.size.width / viewAspect
            
            // Size of the empty space above and below the view
            let viewY = (screenRect.size.height - viewHeight) / 2
            
            return normalized.map {
                CGPoint(x: viewWidth * $0.x, y: viewY + viewHeight * $0.y)
            }
        } else {
            // If view aspect <= screen aspect, there will be empty space on the sides of the view.
            
            let viewWidth = screenRect.size.height * viewAspect
            let viewHeight = screenRect.size.height
            
            // Size of the empty space on the sides of the view
            let viewX = (screenRect.size.width - viewWidth) / 2
            
            return normalized.map {
                CGPoint(x: viewX + viewWidth * $0.x, y: viewHeight * $0.y)
            }
        }
    }
    
    
    /// Takes a set of points in world coordinates and converts each point to screen coordinates
    /// using the given screen rect and viewRect.
    func worldToScreenCoords(pos: Vec2) -> CGPoint {
        let screenRect = self.bounds
        
        // 1) Get the normalized coordinates in our viewRect.
        let normalized = CGPoint(x: (CGFloat(pos.x) - viewRect.minX) / viewRect.size.width,
                                 y: (CGFloat(pos.y) - viewRect.minY) / viewRect.size.height)
        
        // 2) Decide how viewRect should be positioned in screenRect while preserving aspect ratio.
        let viewAspect = viewRect.size.width / viewRect.size.height
        let screenAspect = screenRect.size.width / screenRect.size.height
        
        
        if viewAspect > screenAspect {
            // If view aspect > screen aspect, there will be empty space above and below the view.
            
            let viewWidth = screenRect.size.width
            let viewHeight = screenRect.size.width / viewAspect
            
            // Size of the empty space above and below the view
            let viewY = (screenRect.size.height - viewHeight) / 2
            
            return CGPoint(x: viewWidth * normalized.x, y: viewY + viewHeight * normalized.y)
        } else {
            // If view aspect <= screen aspect, there will be empty space on the sides of the view.
            
            let viewWidth = screenRect.size.height * viewAspect
            let viewHeight = screenRect.size.height
            
            // Size of the empty space on the sides of the view
            let viewX = (screenRect.size.width - viewWidth) / 2
            
            return CGPoint(x: viewX + viewWidth * normalized.x, y: viewHeight * normalized.y)
        }
    }
    
    
    func screenToWorldCoords(screenCoords: CGPoint) -> Vec2 {
        let screenRect = self.bounds
        
        // 1) Figure out where the viewRect occupies the screen
        let viewAspect = viewRect.size.width / viewRect.size.height
        let screenAspect = screenRect.size.width / screenRect.size.height
        
        
        if viewAspect > screenAspect {
            // If view aspect > screen aspect, there will be empty space above and below the view.
            
            let viewWidth = screenRect.size.width
            let viewHeight = screenRect.size.width / viewAspect
            
            // Size of the empty space above and below the view
            let viewY = (screenRect.size.height - viewHeight) / 2
            
            return Vec2(x: Double(viewRect.minX + viewRect.size.width * screenCoords.x / viewWidth),
                        y: Double(viewRect.minY + viewRect.size.height * (screenCoords.y-viewY) / viewHeight))
        } else {
            // If view aspect <= screen aspect, there will be empty space on the sides of the view.
            
            let viewWidth = screenRect.size.height * viewAspect
            let viewHeight = screenRect.size.height
            
            // Size of the empty space on the sides of the view
            let viewX = (screenRect.size.width - viewWidth) / 2
            
            return Vec2(x: Double(viewRect.minX + viewRect.size.width * (screenCoords.x-viewX) / viewWidth),
                        y: Double(viewRect.minY + viewRect.size.height * screenCoords.y / viewHeight))
        }
    }
}
