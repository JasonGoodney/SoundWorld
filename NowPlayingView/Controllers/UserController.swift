//
//  UserController.swift
//  NowPlayingView
//
//  Created by Jason Goodney on 11/2/18.
//  Copyright © 2018 Spotify. All rights reserved.
//

import Foundation

class UserController {
    
    static let shared = UserController(); private init() {}
    
    var user: User?
}
