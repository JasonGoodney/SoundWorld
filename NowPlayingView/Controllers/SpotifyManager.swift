//
//  SpotifyManager.swift
//  NowPlayingView
//
//  Created by Jason Goodney on 11/6/18.
//

import Foundation

protocol SpotifyManagerDelegate: class {
    
}

class SpotifyManager {
    
    static let shared = SpotifyManager(); private init() {}
    
    private var appRemote: SPTAppRemote {
        return AppDelegate.sharedInstance.appRemote
    }
    
    func fetchAlbumArtForTrack(_ appRemote: SPTAppRemote, _ track: SPTAppRemoteTrack, callback: @escaping (UIImage) -> Void ) {
        appRemote.imageAPI?.fetchImage(forItem: track, with:CGSize(width: 1000, height: 1000), callback: { (image, error) -> Void in
            guard error == nil else { return }
            
            let image = image as! UIImage
            callback(image)
        })
    }
    
//    fileprivate func startPlayback() {
//        if playerState == nil {
//            appRemote.playerAPI?.play("", callback: defaultCallback)
//        } else {
//            appRemote.playerAPI?.resume(defaultCallback)
//        }
//    }
//    
//    fileprivate func pausePlayback() {
//        appRemote.playerAPI?.pause(defaultCallback)
//    }
}
