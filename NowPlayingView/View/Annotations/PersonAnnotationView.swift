/*
See LICENSE folder for this sample’s licensing information.

Abstract:
The annotation views that represent the different types of cycles.
*/
import MapKit

protocol PersonAnnotationViewDelegate: class {
    func personAnnotationView(_ view: PersonAnnotationView, playButtonTapped button: UIButton)
}

/// - Tag: PersonAnnotationView
class PersonAnnotationView: MKMarkerAnnotationView {

    static let ReuseID = "personAnnotation"
    
    weak var delegate: PersonAnnotationViewDelegate?
    
    
//    lazy var playButton: UIButton = {
//        let button = UIButton(type: .system)
//        button.addTarget(self, action: #selector(playButtonTapped(_:)), for: .touchUpInside)
//        button.setImage(PlaybackButtonGraphics.playButtonImage(), for: .normal)
//        button.setImage(PlaybackButtonGraphics.playButtonImage(), for: .highlighted)
//        button.tintColor = .black
//        return button
//    }()
    
    
    lazy var playButton: UIButton = {
        let button = UIButton(type: .detailDisclosure)
        button.addTarget(self, action: #selector(playButtonTapped(_:)), for: .touchUpInside)
        button.setImage(PlaybackButtonGraphics.playButtonImage(), for: .normal)
        button.setImage(PlaybackButtonGraphics.playButtonImage(), for: .highlighted)
        button.tintColor = UIColor.Theme.primaryBackground
        return button
    }()

    /// - Tag: ClusterIdentifier
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        clusteringIdentifier = "person"
        canShowCallout = true
        
        markerTintColor = UIColor.Theme.primaryBackground
        glyphTintColor = UIColor.Theme.primary
        
        rightCalloutAccessoryView = playButton

        titleVisibility = .hidden
        subtitleVisibility = .hidden

        let pinImage = UIImage(named: "mapPin")
        let size = CGSize(width: 30, height: 30)
        UIGraphicsBeginImageContext(size)
        pinImage?.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        let resizeImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
//        image = resizeImage
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForDisplay() {
        super.prepareForDisplay()
        displayPriority = .defaultHigh
    }
    
    @objc func playButtonTapped(_ sender: UIButton) {
        delegate?.personAnnotationView(self, playButtonTapped: sender)
    }
}
