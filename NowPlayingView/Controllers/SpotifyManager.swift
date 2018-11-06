//
//  SpotifyManager.swift
//  NowPlayingView
//
//  Created by Jason Goodney on 11/6/18.
//

import Foundation

class SpotifyManager {
    
    static let shared = SpotifyManager(); private init() {}
    
    
    func fetchAlbumArtForTrack(_ appRemote: SPTAppRemote, _ track: SPTAppRemoteTrack, callback: @escaping (UIImage) -> Void ) {
        appRemote.imageAPI?.fetchImage(forItem: track, with:CGSize(width: 1000, height: 1000), callback: { (image, error) -> Void in
            guard error == nil else { return }
            
            let image = image as! UIImage
            callback(image)
        })
    }
}
