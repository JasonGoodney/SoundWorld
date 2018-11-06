/*
See LICENSE folder for this sample’s licensing information.

Abstract:
The annotation data object representing all types of cycles.
*/

import MapKit

class Annotation: NSObject, MKAnnotation {
    var type: Int = 0
    private var latitude: CLLocationDegrees = 0
    private var longitude: CLLocationDegrees = 0
    
    // This property must be key-value observable, which the `@objc dynamic` attributes provide.
    @objc dynamic var coordinate: CLLocationCoordinate2D {
        get {
            return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        }
        set {
            // For most uses, `coordinate` can be a standard property declaration without the customized getter and setter shown here.
            // The custom getter and setter are needed in this case because of how it loads data from the `Decodable` protocol.
            latitude = newValue.latitude
            longitude = newValue.longitude
        }
        
    }
    
    var user: User?
    var song: Song? {
        didSet {
            title = song?.title
            subtitle = song?.artist
        }
    }
    var playerState: SPTAppRemotePlayerState?
    var title: String? = "(Song Title)"
    var subtitle: String? = "(Artist Name)"
}
