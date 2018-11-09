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
    
    lazy var playButton: UIButton = {
        let button = UIButton(type: UIButton.ButtonType.detailDisclosure)
        button.addTarget(self, action: #selector(playButtonTapped(_:)), for: .touchUpInside)
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
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForDisplay() {
        super.prepareForDisplay()
        displayPriority = .defaultHigh
    }
    
    func updatePlayButton() {
        guard let annotation = annotation as? Annotation else { return }
        guard let song = annotation.song else { return }
        
        let playButtonImage = song.isPaused ? PlaybackButtonGraphics.playButtonImage() : PlaybackButtonGraphics.pauseButtonImage()
        playButton.setImage(playButtonImage, for: UIControl.State())
        playButton.setImage(playButtonImage, for: .highlighted)
        
    }
    
    @objc func playButtonTapped(_ sender: UIButton) {
        delegate?.personAnnotationView(self, playButtonTapped: sender)
    }
}
