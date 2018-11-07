//
//  Song.swift
//  SoundWorld
//
//  Created by Jason Goodney on 10/30/18.
//  Copyright © 2018 Jason Goodney. All rights reserved.
//

import UIKit
import Firebase

struct Song {
    static var testSongs: [Song] {
        return [
            Song(uid: UUID().uuidString, title: "Ho Hey", artist: "The Lumineers", spotifyUri: "spotify:track:0W4Kpfp1w2xkY3PrV714B7", isSavedToSpotify: false, isPaused: false, playbackDuration: 274),
            Song(title: "Snap Yo Fingers", artist: "Youngbloodz", spotifyUri: "spotify:track:6o3s08kk2fQI37vxGZDrJ1", isSavedToSpotify: false, isPaused: false, playbackDuration: 274),
            Song(title: "Chicken Fried", artist: "Zac Brown Band", spotifyUri: "spotify:track:4dGJf1SER1T6ooX46vwzRB", isSavedToSpotify: false, isPaused: false, playbackDuration: 238),
            Song(title: "Orkany/Balance Pon It", artist: "Major Lazer", spotifyUri: "spotify:track:0e3gi36ySaA3LDYajiRXKt", isSavedToSpotify: false, isPaused: false, playbackDuration: 278),
            Song(title: "SICKO MODE", artist: "Travis Scott", spotifyUri: "spotify:track:2xLMifQCjDGFmkHkpNLD9h", isSavedToSpotify: false, isPaused: false, playbackDuration: 313),
            Song(title: "T.N.T.", artist: "AC/DC", spotifyUri: "spotify:track:7LRMbd3LEoV5wZJvXT1Lwb", isSavedToSpotify: false, isPaused: false, playbackDuration: 214),
            Song(title: "Ruin My Life", artist: "Zara Larsson", spotifyUri: "spotify:track:5tAa8Uaqr4VvA3693mbIhU", isSavedToSpotify: false, isPaused: false, playbackDuration: 191)
        ]
    }
    
    let uid: String
    let title: String
    let artist: String
    let spotifyUri: String?
    let isSavedToSpotify: Bool
    let isPaused: Bool
    let playbackDuration: TimeInterval
    
    var firebaseDictionary: [String: Any] {
        return [
            Key.uid: uid,
            Key.title: title,
            Key.artist: artist,
            Key.spotifyUri: spotifyUri as! String,
            Key.isSavedToSpotify: isSavedToSpotify,
            Key.isPaused: isPaused,
            Key.playbackDuration: playbackDuration,
        ]
    }
    
    enum Key {
        
        static let songs = "songs"
        // Properties
        static let uid = "uid"
        static let title = "title"
        static let artist = "artist"
        static let spotifyUri  = "spotifyUri"
        static let isSavedToSpotify = "isSavedToSpotify"
        static let isPaused = "isPaused"
        static let playbackDuration = "playbackDuration"
    }
    
    init(uid: String = UUID().uuidString, title: String = "No Title" , artist: String = "No Artist", spotifyUri: String = "No URI", isSavedToSpotify: Bool = false, isPaused: Bool = false, playbackDuration: TimeInterval = 0.0) {
        self.uid = uid
        self.title = title
        self.artist = artist
        self.spotifyUri = spotifyUri
        self.isSavedToSpotify = isSavedToSpotify
        self.isPaused = isPaused
        self.playbackDuration = playbackDuration
    }

}

// MARK: - Firebase snapshot initialization
extension Song {
    init?(snapshot: DataSnapshot) {
        guard let value = snapshot.value as? [String: Any] else { return nil }
        
        guard let uid = value[Key.uid] as? String,
            let title = value[Key.title] as? String,
            let artist = value[Key.artist] as? String,
            let spotifyUri = value[Key.spotifyUri] as? String,
            let isSavedToSpotify = value[Key.isSavedToSpotify] as? Bool,
            let isPaused = value[Key.isPaused] as? Bool,
            let playbackDuration = value[Key.playbackDuration] as? Double
        else { return nil }
        
        self.uid = uid
        self.title = title
        self.artist = artist
        self.spotifyUri = spotifyUri
        self.isSavedToSpotify = isSavedToSpotify
        self.isPaused = isPaused
        self.playbackDuration = playbackDuration
    }
}
