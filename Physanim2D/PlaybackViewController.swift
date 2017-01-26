//
//  PlaybackViewController.swift
//  Physanim2D
//
//  Created by Tima Peshin on 1/24/17.
//  Copyright © 2017 timoffex. All rights reserved.
//

import Foundation
import UIKit

class PlaybackViewController : UIViewController {
    
    @IBOutlet var playbackView: AnimationPlaybackView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        playbackView.playbackModelAnimation()
    }
}
