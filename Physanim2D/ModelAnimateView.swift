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
    
    
    /// Convenience var quivalent to ProgramData.model.
    var model: Model! {
        return ProgramData.model
    }
    
    /// The screen rectangle in world-coordinates. Anything in this rectangle
    /// is guaranteed to be shown on the screen. Equivalent to ProgramData.worldViewRect.
    var viewRect: CGRect {
        return ProgramData.worldViewRect
    }
    
    
    /// Maximum distance in screen coordinates between a touch and a joint for the joint to be considered under the touch.
    var maxSelectDistance: Double = 25
    
    
    /// The indices and positions of joints that should be locked in place.
    var lockedJoints: [(Int, Vec2)] = []
    
    /// The joint that is currently being dragged. Nil if nothing is being dragged.
    var draggedJoint: Int?
    
    
    @IBOutlet weak var snapshotViewContainer: UIStackView!
    
    
    /// This draws the model and colors the appropriate joints.
    override func draw(_ rect: CGRect) {
        if let ctx = UIGraphicsGetCurrentContext() {
            
            var jointColors: [(Int, CGColor)] = lockedJoints.map {
                (i,v) in (i, UIColor.red.cgColor)
            }
            
            if let dragged = draggedJoint {
                jointColors.append((dragged, UIColor.yellow.cgColor))
            }
            
            RenderUtilities.drawModel(in: self.bounds, withContext: ctx, withColors: jointColors)
        }
    }
    
    
    
    /// Responds to a tap on the screen.
    func tapOccured(recognizer: UITapGestureRecognizer) {
        
        let screenLocation = recognizer.location(in: self)
        
        let worldLocation = RenderUtilities.screenToWorldCoords(screenCoords: screenLocation, screenRect: self.bounds)
        
        
        let (closestJointIdx, closestJointPosition, closestJointDist) = findClosestJoint(to: worldLocation)
        
        
        // If we tapped on a joint..
        if RenderUtilities.worldToScreenDistance(worldDist: closestJointDist, screenRect: self.bounds) <= maxSelectDistance {
            
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
        
        let worldLocation = RenderUtilities.screenToWorldCoords(screenCoords: recognizer.location(in: self), screenRect: self.bounds)
        
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
            if RenderUtilities.worldToScreenDistance(worldDist: dist, screenRect: self.bounds) > maxSelectDistance {
                return
            } else {
                draggedJoint = idx
            }
        }
        
        
        // Dragged joint is not nil at this point for sure and we're definitely dragging.
        
        
        // Is draggedJoint locked?
        if let lockedIdx = lockedJoints.index(where: {(i,v) in i == draggedJoint!}) {
            // If so, unlock it.
            lockedJoints.remove(at: lockedIdx)
        }
        
        let targetPositions = lockedJoints.map { (i,v) in v } + [worldLocation]
        let indices = lockedJoints.map { (i,v) in i } + [draggedJoint!]
        
        
        // Move the model, keeping locked joints in their places and moving the dragged joint to the new location.
        model.moveToPoseWith(targetPositions: targetPositions, forIndices: indices, maxIterations: 30)
        
        // Redraw.
        setNeedsDisplay()
    }
    
    
    
    func doubleTapOccured(recognizer: UITapGestureRecognizer) {
        
        
        // Make a flashing effect.
        let whiteView = UIView(frame: self.bounds)
        whiteView.alpha = 1
        whiteView.backgroundColor = UIColor.white
        
        addSubview(whiteView)
        
        UIView.animate(withDuration: 0.5, animations: { whiteView.alpha = 0.0 },
                       completion: { _ in whiteView.removeFromSuperview() })
        
        
        // Record the positions of the model's joints.
        ProgramData.modelSnapshots.append(model.clone())
    }
    
    
    /// Returns the index of the joint closest to the given position, its actual position, and its distance from that position in world coordinates.
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
}
