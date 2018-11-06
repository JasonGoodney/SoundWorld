//
//  PlayerStateController.swift
//  NowPlayingView
//
//  Created by Jason Goodney on 11/5/18.
//  Copyright © 2018 Spotify. All rights reserved.
//

import Foundation

class PlayerStateController {
    
    static let shared = PlayerStateController(); private init() {}
    
    var state: SPTAppRemotePlayerState?
}
