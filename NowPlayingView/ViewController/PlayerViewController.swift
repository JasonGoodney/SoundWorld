//
//  PlayerViewController.swift
//  NowPlayingView
//
//  Created by Jason Goodney on 11/14/18.
//

import UIKit

class PlayerViewController: UIViewController {

    override func loadView() {
        super.view = PlayerView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
}
