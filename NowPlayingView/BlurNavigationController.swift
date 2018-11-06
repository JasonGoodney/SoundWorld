//
//  BlurNavigationController.swift
//  NowPlayingView
//
//  Created by Jason Goodney on 11/5/18.
//  Copyright © 2018 Spotify. All rights reserved.
//

import UIKit

final class BlurNavigationController: UINavigationController {
    
    override func viewDidLoad() {
        
        // Find size for blur effect.
        let statusBarHeight = UIApplication.shared.statusBarFrame.size.height
        let bounds = navigationBar.bounds.insetBy(dx: 0, dy: -(statusBarHeight)).offsetBy(dx: 0, dy: -(statusBarHeight))
        // Create blur effect.
        let visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .light))
        visualEffectView.frame = bounds
        // Set navigation bar up.
        navigationBar.isTranslucent = true
        navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationBar.addSubview(visualEffectView)
        navigationBar.sendSubviewToBack(visualEffectView)
        
        navigationBar.isHidden = true
        
    }
    
}
