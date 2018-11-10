//
//  MapViewController.swift
//  SoundWorld
//
//  Created by Jason Goodney on 10/29/18.
//  Copyright © 2018 Jason Goodney. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import AVFoundation
import FirebaseAuth
import FirebaseDatabase
import StoreKit

class MapViewController: UIViewController, AVAudioPlayerDelegate, StoreKitOpenable {
    
    // MARK: - Properties
    var annotionsDictionary: [String: Annotation] = [:]
    var currentLocatation: CLLocationCoordinate2D!
    let databaseManager = DatabaseManager()
    var currentUser: User!
    let locationManager = CLLocationManager()
    var currentLocation: CLLocationCoordinate2D!
    var ref: DatabaseReference!
    
    // MARK: - Subviews
    lazy var mapView: MKMapView = {
        let view = MKMapView(frame: self.view.bounds)
        view.delegate = self
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.mapType = .mutedStandard
        view.isPitchEnabled = false
        view.showsUserLocation = true
        return view
    }()
    
    lazy var userTrackingButton: MKUserTrackingButton = {
        let button = MKUserTrackingButton(mapView: mapView)
        button.layer.backgroundColor = UIColor.Theme.primaryBackground.cgColor
        button.layer.borderColor = UIColor.Theme.primary.cgColor
        button.layer.borderWidth = 1
        button.layer.cornerRadius = 5
        button.clipsToBounds = true
        button.translatesAutoresizingMaskIntoConstraints = false
        button.tintColor = UIColor.Theme.primary

        return button
    }()

    let artworkImageView: UIImageView = {
        let view = UIImageView()
        view.backgroundColor = .blue
        view.isHidden = true
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        ref = Database.database().reference()
        
        setupAuthorizedLocation()
        
        view.addSubview(mapView)
        view.addSubview(userTrackingButton)
        NSLayoutConstraint.activate([
            userTrackingButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            userTrackingButton.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -16),
        ])
        
        mapView.register(PersonAnnotationView.self, forAnnotationViewWithReuseIdentifier: PersonAnnotationView.ReuseID)
        mapView.register(ClusterAnnotationView.self, forAnnotationViewWithReuseIdentifier: MKMapViewDefaultClusterAnnotationViewReuseIdentifier)

        fetchUsers()
    }

    func fetchUsers() {
        
        ref.child("users").observeSingleEvent(of: .value, with: { (snapshot) in
            for child in snapshot.children {
                let snap = child as! DataSnapshot
                guard let user = User(snapshot: snap) else { return }
                self.ref.child(Song.Key.songs).child(user.songUid).observeSingleEvent(of: .value) { (snapshot) in
                    var song = Song(snapshot: snapshot)
                    if song == nil {
                        song = Song.testSongs.randomElement()
                    }
                    
                    DispatchQueue.main.async {
                        if user.uid != AuthManager.shared.uid {
                            let coord = CLLocationCoordinate2D(latitude: user.latitude, longitude: user.longitude)
                            self.createAnnotion(forUser: user, song: song!, at: coord)
                        }
                    }
                }
            }
        })
    }
    
    func fetchSong(forUser user: User, completion: @escaping (Song?) -> Void) {
        ref.child(Song.Key.songs).child(user.songUid).observeSingleEvent(of: .value) { (snapshot) in
            var song = Song(snapshot: snapshot)
            if song == nil {
                song = Song.testSongs.randomElement()
            }
            print("Fetch Song title: \(song!.title)")
            completion(song)
        }
        
        completion(nil)
    }
    
    @objc func refreshButtonTapped() {
        fetchUsers()
    }
    
    func updateAnnotation(_ annotation: Annotation, with title: String, subtitle: String) {
        annotation.title = title
        annotation.subtitle = subtitle
    }
    
    func createAnnotion(forUser user: User, song: Song, at coord: CLLocationCoordinate2D) {
        
        let annotation = Annotation()
        annotation.coordinate = coord
        annotation.user = user
        annotation.song = song
        
        self.mapView.addAnnotation(annotation)
        annotionsDictionary[user.uid] = annotation
    }
    
    func setupUsertrackingButton() {
        view.addSubview(userTrackingButton)
        NSLayoutConstraint.activate([
            userTrackingButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 32),
            userTrackingButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 16)
        ])
    }

}

extension MapViewController: MKMapViewDelegate {
    func setupAuthorizedLocation() {
        // Ask for Authorisation from the User.
        self.locationManager.requestAlwaysAuthorization()
        
        // For use in foreground
        self.locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
            
            guard let lat = self.locationManager.location?.coordinate.latitude,
                let long = self.locationManager.location?.coordinate.longitude else { return }
            
            let span = MKCoordinateSpan(latitudeDelta: 9, longitudeDelta: 9)
            currentLocation = CLLocationCoordinate2D(latitude: lat, longitude: long)
            
            let region = MKCoordinateRegion(center: currentLocation, span: span)
            mapView.region = region
        }
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard let annotation = annotation as? Annotation else { return nil }
        
        let personAnnotationView = PersonAnnotationView(annotation: annotation, reuseIdentifier: PersonAnnotationView.ReuseID)
        personAnnotationView.delegate = self
        
        return personAnnotationView
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        guard let personAnnotationView = view as? PersonAnnotationView else { return }
        guard let annotation = personAnnotationView.annotation as? Annotation else { return }
        guard let user = annotation.user else { return }
        guard let song = annotation.song else { return }
        
        personAnnotationView.delegate = self
//        if PlayerStateController.shared.state?.track.uri == song.spotifyUri {
//            playButton(personAnnotationView.playButton, isPaused: false)
//        }
        
        print(user.uid)
        print(song.title)
    }
    
    func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
        guard let homeVC = self.parent as? HomeViewController else { return }
        if homeVC.searchBar.isFirstResponder {
            homeVC.searchBar.resignFirstResponder()
        }
    }

}

extension String {
    func toDouble() -> Double {
        let nsString = self as NSString
        return nsString.doubleValue
    }
}

extension MapViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        let locationAuthorized = status == .authorizedWhenInUse
        userTrackingButton.isHidden = !locationAuthorized
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {

        
    }
}

extension MapViewController: PersonAnnotationViewDelegate {
    func personAnnotationView(_ view: PersonAnnotationView, playButtonTapped button: UIButton) {
        if !AppDelegate.sharedInstance.appRemote.isConnected {
            StoreKitManager.showAppStoreInstall(from: self)
        }
        
        guard let annotation = view.annotation as? Annotation else { return }
        guard let song = annotation.song else { return }
        guard let uri = song.spotifyUri else { return }
//        view.updatePlayButton()
//        playButton(view.playButton, isPaused: song.isPaused)
        let vc = HomeViewController()
        vc.trackIdentifier = uri
    }
}

extension MapViewController: PlayButtonDelegate {
//    func playButton(_ button: UIButton, updatePlayButtonState paused: Bool) {
//        let playPauseButtonImage = paused ? PlaybackButtonGraphics.playButtonImage() : PlaybackButtonGraphics.pauseButtonImage()
//        button.setImage(playPauseButtonImage, for: UIControl.State())
//        button.setImage(playPauseButtonImage, for: .highlighted)
//    }
}

extension MapViewController: SKStoreProductViewControllerDelegate {
    func productViewControllerDidFinish(_ viewController: SKStoreProductViewController) {
        viewController.dismiss(animated: true) {
            //self.isSpotifyInstalled()
        }
    }
}


