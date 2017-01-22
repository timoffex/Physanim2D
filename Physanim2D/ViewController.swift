//
//  ViewController.swift
//  Physanim2D
//
//  Created by Tima Peshin on 1/21/17.
//  Copyright © 2017 timoffex. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        print("Testing")
        
        var testingModel = Model(rootPos: Vec2(x: 0, y: 0), rootDir: Vec2(x: 0, y: 1))
        
        testingModel.addJoint(parent: 0, distance: 1, angle: Angle(0))
        
        
        testingModel.moveToPoseWith(targetPositions: [Vec2(x: 4, y: 3)], forIndices: [1])
        
        print("Final positions: \(testingModel.getPositions())")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

