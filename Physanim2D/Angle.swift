//
//  Angle.swift
//  Physanim2D
//
//  Created by Tima Peshin on 1/21/17.
//  Copyright © 2017 timoffex. All rights reserved.
//

import Foundation


class Angle {
    private let representative: Double
    
    init(_ rep: Double) {
        representative = Angle.getMod2PI(rep)
    }
    
    
    
    
    
    
   
    
    prefix static func -(param: Angle) -> Angle {
        return Angle(-param.representative)
    }
    
    static func +(left: Angle, right: Angle) -> Angle {
        return Angle(left.representative + right.representative)
    }
    
    static func -(left: Angle, right: Angle) -> Angle {
        return left + (-right)
    }
    
    
    static func IsAngleBetween(_ angle: Angle, ccwFrom: Angle, cwFrom: Angle) -> Bool {
        return (cwFrom - ccwFrom).representative >= (angle - ccwFrom).representative
    }
    
    
    static func getMod2PI(_ angle: Double) -> Double {
        var t = angle
        
        while t < 0 {
            t = t + 2 * M_PI
        }
        
        while t > 2 * M_PI {
            t = t - 2 * M_PI
        }
        
        return t
    }
}
