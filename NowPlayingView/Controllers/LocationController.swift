//
//  LocationController.swift
//  NowPlayingView
//
//  Created by Jason Goodney on 11/3/18.
//  Copyright © 2018 Spotify. All rights reserved.
//

import Foundation
import CoreLocation

class LocationController {
    
    private let locationManager = CLLocationManager()
    
    var latitude: CLLocationDegrees = 0
    var longitude: CLLocationDegrees = 0
    var coordinates: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    
    static let shared = LocationController(); private init() {}
    
    func requestCurrentLocation() {
        self.locationManager.requestAlwaysAuthorization()
        
        // For use in foreground
        self.locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            //locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
            
            guard let lat = self.locationManager.location?.coordinate.latitude,
                let long = self.locationManager.location?.coordinate.longitude else { return }
            
            
            latitude = lat
            longitude = long
        }
    }
}
