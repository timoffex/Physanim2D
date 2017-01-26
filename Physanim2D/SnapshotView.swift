//
//  SnapshotView.swift
//  Physanim2D
//
//  Created by Tima Peshin on 1/24/17.
//  Copyright © 2017 timoffex. All rights reserved.
//

import Foundation
import UIKit

class SnapshotView: UIView {
    
    private var previewedModel: Model
    
    
    init(withModel model: Model) {
        previewedModel = model
        
        
        
        super.init(frame: CGRect.zero)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func draw(_ rect: CGRect) {
        //if previewedModel != nil {
            if let ctx = UIGraphicsGetCurrentContext() {
                // Draw the model!
                RenderUtilities.draw(model: previewedModel, in: rect, withContext: ctx)
            }
        //}
    }
    
}
