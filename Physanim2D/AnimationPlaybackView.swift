//
//  AnimationPlaybackView.swift
//  Physanim2D
//
//  Created by Tima Peshin on 1/23/17.
//  Copyright © 2017 timoffex. All rights reserved.
//

import UIKit
import CoreGraphics


class AnimationPlaybackView : UIView {
    
    private var drawnModel: Model!
    

    
    override func draw(_ rect: CGRect) {
        if let ctx = UIGraphicsGetCurrentContext() {
            
            if drawnModel != nil {
                
                RenderUtilities.draw(model: drawnModel, in: self.bounds, withContext: ctx)
                
            } else {
                print("AnimationPlaybackView.drawnModel was nil!")
            }
        }
    }
    
    
    func playbackModelAnimation() {
        
        // If we have at least one snapshot...
        if ProgramData.modelSnapshots.count > 0 {
            let keyFrameSecs: TimeInterval = 0.5
            let frameCount = 20
            let frameSecs = keyFrameSecs / Double(frameCount)
            
            var frameTime: Double = 0.0
            
            
            _ = Timer.scheduledTimer(withTimeInterval: frameSecs, repeats: true) { (tmr) in
                let keyFrameIdx = Int(floor(frameTime / keyFrameSecs))
                
                // If we're done with the last frame.
                if keyFrameIdx >= ProgramData.modelSnapshots.count-1 {
                    
                    // Stop the timer
                    tmr.invalidate()
                    
                    // And reset the snapshots
                    ProgramData.modelSnapshots = []
                } else {
                    
                    
                    let keyFramePercentage = frameTime / keyFrameSecs - Double(keyFrameIdx)
                    
                    
                    let snapshotCurrent = ProgramData.modelSnapshots[keyFrameIdx]
                    let snapshotNext = ProgramData.modelSnapshots[keyFrameIdx + 1]
                    
                    self.drawnModel = snapshotCurrent.clone()
                    
                    self.drawnModel.jointAngles = zip(snapshotCurrent.jointAngles, snapshotNext.jointAngles).map { (a0, a1) in
                        Angle.interpolateInnerAngle(from: a0, to: a1, withPercentage: keyFramePercentage)
                    }
                    
                    self.drawnModel.rootPosition = snapshotCurrent.rootPosition + (snapshotNext.rootPosition - snapshotCurrent.rootPosition) * keyFramePercentage
                    
                    
                    
                    self.setNeedsDisplay()
                    
                    frameTime += frameSecs
                }
            }
        }
    }
    
}
