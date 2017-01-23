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
        
//        print("Testing")
        
        let testingModel = Model(rootPos: Vec2(x: 0, y: 0), rootDir: Vec2(x: 0, y: 1))
        
        testingModel.addJoint(parent: 0, distance: 1, angle: Angle(M_PI/4))
        testingModel.addJoint(parent: 1, distance: 2, angle: Angle(-M_PI/3))
        testingModel.addJoint(parent: 2, distance: 1, angle: Angle(M_PI/5))
        
        modelAnimateView.model = testingModel
        modelAnimateView.viewRect = CGRect(x: -10, y: -10, width: 20, height: 20)
        
        self.modelAnimateView.setNeedsDisplay()
        
//        testingModel.moveToPoseWith(targetPositions: [Vec2(x: 4, y: 3)], forIndices: [1])
        
//        print("Final positions: \(testingModel.getPositions())")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

