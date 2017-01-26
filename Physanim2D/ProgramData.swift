//
//  ProgramData.swift
//  Physanim2D
//
//  Created by Tima Peshin on 1/23/17.
//  Copyright © 2017 timoffex. All rights reserved.
//

import Foundation
import CoreGraphics


class ProgramData {

    static var model: Model!
    
    /// Snapshots of the model's jointAngles property.
    static var modelSnapshots: [Model] = []
    
    
    static var worldViewRect: CGRect!
}
