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
        
        
        // Set up the view and tell it to draw self.
        modelAnimateView.model = testingModel
        modelAnimateView.viewRect = CGRect(x: -5, y: -5, width: 10, height: 10)
        modelAnimateView.setNeedsDisplay()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

