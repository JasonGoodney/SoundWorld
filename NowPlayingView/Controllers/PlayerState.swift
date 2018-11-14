//
//  PlayerState.swift
//  NowPlayingView
//
//  Created by Jason Goodney on 11/5/18.
//  Copyright © 2018 Spotify. All rights reserved.
//

import Foundation

class PlayerState {
    
    static let shared = PlayerState(); private init() {}
    
    var state: SPTAppRemotePlayerState?
}
