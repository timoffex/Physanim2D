//
//  ViewController.swift
//  Physanim2D
//
//  Created by Tima Peshin on 1/21/17.
//  Copyright © 2017 timoffex. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet var modelAnimateView: ModelAnimateView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        
        // Create a model for testing.
        let testingModel = Model(rootPos: Vec2(x: 0, y: 0), rootDir: Vec2(x: 0, y: -1)) // 0
        
        // Legs
        testingModel.addJoint(parent: 0, distance: 1, angle: Angle(7*M_PI/6))           // 1
        testingModel.addJoint(parent: 1, distance: 1, angle: Angle(0))                  // 2
        testingModel.addJoint(parent: 0, distance: 1, angle: Angle(5*M_PI/6))           // 3
        testingModel.addJoint(parent: 3, distance: 1, angle: Angle(0))                  // 4
        
        // Torso
        testingModel.addJoint(parent: 0, distance: 1, angle: Angle(0))                  // 5
        
        // Arms
        testingModel.addJoint(parent: 5, distance: 1, angle: Angle(M_PI/2))             // 6
        testingModel.addJoint(parent: 6, distance: 1, angle: Angle(0))                  // 7
        testingModel.addJoint(parent: 5, distance: 1, angle: Angle(-M_PI/2))            // 8
        testingModel.addJoint(parent: 8, distance: 1, angle: Angle(0))                  // 9
        
        // Head
        testingModel.addJoint(parent: 5, distance: 0.5, angle: Angle(0))
        
        
        ProgramData.model = testingModel
        ProgramData.worldViewRect = CGRect(x: -5, y: -5, width: 10, height: 10)
        
        
        
        // Set up the view and tell it to draw self.
        
        // Double-tapping should take a snapshot of the model.
        let doubleTapRecognizer = UITapGestureRecognizer(target: modelAnimateView, action: #selector(modelAnimateView.doubleTapOccured))
        doubleTapRecognizer.numberOfTapsRequired = 2
        
        
        // Tapping on the screen should lock/unlock joints.
        let tapRecognizer = UITapGestureRecognizer(target: modelAnimateView, action: #selector(modelAnimateView.tapOccured))
        tapRecognizer.numberOfTapsRequired = 1
        
        
        // Panning (dragging) should drag joints.
        let panRecognizer = UIPanGestureRecognizer(target: modelAnimateView, action: #selector(modelAnimateView.panOccured))
        panRecognizer.maximumNumberOfTouches = 1
        
        
        modelAnimateView.addGestureRecognizer(doubleTapRecognizer)
        modelAnimateView.addGestureRecognizer(tapRecognizer)
        modelAnimateView.addGestureRecognizer(panRecognizer)
        
        modelAnimateView.setNeedsDisplay()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

