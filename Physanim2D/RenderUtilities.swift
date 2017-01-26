//
//  RenderUtilities.swift
//  Physanim2D
//
//  Created by Tima Peshin on 1/24/17.
//  Copyright © 2017 timoffex. All rights reserved.
//

import Foundation
import CoreGraphics
import UIKit


class RenderUtilities {
    
    
    /// The radius of the dot drawn at every joint in the model.
    static var pointRadius: CGFloat = 3
    
    
    static func drawModel(in rect: CGRect, withContext ctx: CGContext, withColors colors: [(Int, CGColor)]? = nil) {
        if let model = ProgramData.model {
            // Draw the model.
            
            
            // 1) Get model's joint positions in screen coordinates.
            let positions = model.getPositions()
            
            
            let screenPositions = positions.map {
                worldToScreenCoords(pos: $0, screenRect: rect)
            }
            
            
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
                if colors != nil, let (_, color) = colors!.first(where: { (i,v) in i == idx }) {
                    ctx.setFillColor(color)
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
    
    
    static func draw(model: Model, in rect: CGRect, withContext ctx: CGContext, withColors colors: [(Int, CGColor)]? = nil) {
        // Draw the model.
        
        
        // 1) Get model's joint positions in screen coordinates.
        let positions = model.getPositions()
        
        
        let screenPositions = positions.map {
            worldToScreenCoords(pos: $0, screenRect: rect)
        }
        
        
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
            if colors != nil, let (_, color) = colors!.first(where: { (i,v) in i == idx }) {
                ctx.setFillColor(color)
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
    
    
    
    /// Takes a set of points in world coordinates and converts each point to screen coordinates
    /// using the given screen rect and viewRect.
    static func worldToScreenCoords(pos: Vec2, screenRect: CGRect) -> CGPoint {
        let viewRect = ProgramData.worldViewRect!
        
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
    
    
    static func screenToWorldCoords(screenCoords: CGPoint, screenRect: CGRect) -> Vec2 {
        let viewRect = ProgramData.worldViewRect!
        
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
    
    
    static func worldToScreenDistance(worldDist: Double, screenRect: CGRect) -> Double {
        let viewRect = ProgramData.worldViewRect!
        
        let viewAspect = viewRect.size.width / viewRect.size.height
        let screenAspect = screenRect.size.width / screenRect.size.height
        
        if viewAspect > screenAspect {
            return Double(screenRect.width / viewRect.width) * worldDist
        } else {
            return Double(screenRect.height / viewRect.height) * worldDist
        }
    }
}
