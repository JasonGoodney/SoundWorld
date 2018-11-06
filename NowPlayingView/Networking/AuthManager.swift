//
//  AuthManager.swift
//  SoundWorld
//
//  Created by Jason Goodney on 10/31/18.
//  Copyright © 2018 Jason Goodney. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class AuthManager {

    let ref = Database.database().reference()
    let databaseManager = DatabaseManager()
    static let shared = AuthManager(); private init() {}

    var uid: String? {
        return Auth.auth().currentUser?.uid
    }
    
    func signInAnonymously(completion: @escaping (AuthDataResult?) -> Void) {
        
        
        Auth.auth().signInAnonymously { (authResult, error) in
            if let error = error {
                print("Failed to sign in user: \(error)")
                completion(nil)
            }
        
            completion(authResult)
//
//            if Auth.auth().currentUser?.uid != nil &&
//                authResult?.user.uid == Auth.auth().currentUser?.uid {
//
//                guard let user = Auth.auth().currentUser else { return }
//                self.ref.child(User.Key.users).child(user.uid).observeSingleEvent(of: .value, with: { (snapshot) in
//                    var currentUser = User(snapshot: snapshot)
//                    if currentUser == nil {
//                        currentUser = User(uid: user.uid, email: "\(UUID().uuidString)@email.com", latitude: self.currentLocation.latitude, longitude: self.currentLocation.longitude)
//                        self.databaseManager.setUser(currentUser!.firebaseDictionary, forUid: currentUser!.uid)
//
//                    } else {
////                        self.databaseManager.updateLocation(
////                            ["latitude": self.currentLocation.latitude,
////                             "longitude": self.currentLocation.longitude],
////                            forUid: self.currentUser.locationUid)
//
//                    }
//
//                    let defaults = UserDefaults.standard
//
//                    let dictionary: [String:Any] = currentUser!.firebaseDictionary
//
//                    defaults.setValue(dictionary, forKey: "currentUser") //Saved the Dictionary in user default
//
//                    guard let dictValue = UserDefaults.standard.value(forKey: "currentUser") as? [String: Any] else { return }
//                    //self.currentUser = User(dictionary: dictValue)
//                    print(dictValue)
//                    // Music.app
//                   // self.getNowPlayingItem()
//
//                    // Spotify.app
//
//                })
//            }
        }
    }

}
