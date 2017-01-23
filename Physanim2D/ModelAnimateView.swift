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
    
    var pointRadius: CGFloat = 3
    
    var viewRect: CGRect!
    
    override func draw(_ rect: CGRect) {
        if let ctx = UIGraphicsGetCurrentContext() {
            
            if model != nil {
                // Draw the model.
                
                // 1) Get model's joint positions in screen coordinates.
                let positions = model.getPositions()
                
//                print(positions)
                
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
                    
                    if idx == 0 {
                        ctx.setFillColor(UIColor.blue.cgColor)
                    } else {
                        ctx.setFillColor(UIColor.green.cgColor)
                    }
                    
                    ctx.fillEllipse(in: CGRect(x: pos.x-pointRadius, y: pos.y-pointRadius, width: 2*pointRadius, height: 2*pointRadius))
                }
            }
        }
    }
    
    
    /// Takes a set of points in world coordinates and converts each point to screen coordinates
    /// using the given screen rect and viewRect.
    private func worldToScreenCoords(pos: [Vec2], screenRect: CGRect) -> [CGPoint] {
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
}
