//
//  DatabaseManager.swift
//  SoundWorld
//
//  Created by Jason Goodney on 10/30/18.
//  Copyright © 2018 Jason Goodney. All rights reserved.
//

import Foundation
import FirebaseDatabase

struct DatabaseManager {
    
    private static let ref = Database.database().reference()
    
    func setLocation(_ values: [String: Any], forUid uid: String) {
        DatabaseManager.setValues(values, forUid: uid, toPath: "locations")
    }
    
    func updateLocation(_ values: [String: Any], forUid uid: String) {
        DatabaseManager.updateValues(values, forUid: uid, toPath: "locations")
    }
    
    func setSong(_ values: [String: Any], forUid uid: String) {
        DatabaseManager.setValues(values, forUid: uid, toPath: Song.Key.songs)
    }
    
    func updateSong(_ values: [String: Any], forUid uid: String) {
        DatabaseManager.updateValues(values, forUid: uid, toPath: Song.Key.songs)
    }
    
    func setUser(_ values: [String: Any], forUid uid: String) {
        DatabaseManager.setValues(values, forUid: uid, toPath: User.Key.users)
    }
    
    func updateUser(_ values: [String: Any], forUid uid: String) {
        DatabaseManager.updateValues(values, forUid: uid, toPath: User.Key.users)
    }
    
    func fetchUser(with uid: String, atPath path: String) {
        Database.database().reference().child(path).child(uid).observeSingleEvent(of: .value) { (snapshot) in
            UserController.shared.user = User(snapshot: snapshot)
            
        }
    }
    
    func fetchUser(with uid: String, atPath path: String, completion: @escaping (User?) -> Void ) {
        Database.database().reference().child(path).child(uid).observeSingleEvent(of: .value) { (snapshot) in
            let user = User(snapshot: snapshot)
            completion(user)
        }
        completion(nil)
    }
    
    private static func setValues(_ values: [String: Any], forUid uid: String, toPath pathString: String) {
        DatabaseManager.ref.child(pathString).child(uid).setValue(values)
    }
    
    private static func updateValues(_ values: [String: Any], forUid uid: String, toPath pathString: String) {
        DatabaseManager.ref.child(pathString).child(uid).updateChildValues(values)
    }
}
