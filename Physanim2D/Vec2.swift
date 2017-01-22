//
//  Vec2.swift
//  Physanim2D
//
//  Created by Tima Peshin on 1/21/17.
//  Copyright © 2017 timoffex. All rights reserved.
//

import Foundation



infix operator •


class Vec2 {
    let x: Double
    let y: Double
    
    init(x: Double, y: Double) {
        self.x = x
        self.y = y
    }
    
    
    prefix static func -(v: Vec2) -> Vec2 {
        return Vec2(x: -v.x, y: -v.y)
    }
    
    static func +(left: Vec2, right: Vec2) -> Vec2 {
        return Vec2(x: left.x + right.x, y: left.y + right.y)
    }
    
    static func -(left: Vec2, right: Vec2) -> Vec2 {
        return left + (-right)
    }
    
    static func *(left: Double, right: Vec2) -> Vec2 {
        return Vec2(x: left * right.x, y: left * right.y)
    }
    
    static func *(left: Vec2, right: Double) -> Vec2 {
        return Vec2(x: left.x * right, y: left.x * right)
    }
    
    
    static func •(left: Vec2, right: Vec2) -> Double {
        return Vec2.dot(left: left, right: right)
    }
    
    static func dot(left: Vec2, right: Vec2) -> Double {
        return left.x*right.x + left.y*right.y
    }
}
