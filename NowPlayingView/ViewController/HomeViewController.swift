import UIKit
import StoreKit
import FirebaseAuth

class HomeViewController: UIViewController,
                      SPTAppRemotePlayerStateDelegate,
                      SPTAppRemoteUserAPIDelegate,
                      SKStoreProductViewControllerDelegate {

    fileprivate let playURI = ""
    var trackIdentifier = "" {
        didSet {
            playTrackWithIdentifier(trackIdentifier)
        }
    }
    fileprivate let name = "Now Playing View"
    fileprivate var currentlyPlayingSong: Song?
    fileprivate var isDurationInProgress = false
    
    let mapViewController = MapViewController()
    lazy var playerView: PlayerView = {
        let view = PlayerView(frame: .zero)
        view.delegate = self
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    // MARK: - Lifecycle

    fileprivate var connectionIndicatorView = ConnectionStatusIndicatorView()

    override func viewDidLoad() {
        super.viewDidLoad()
        
//        navigationController?.navigationBar.isHidden = true
        
        
        addChild(mapViewController)
        view.addSubview(mapViewController.view)
        mapViewController.didMove(toParent: self)
        
        setupPlayerView()
        
        mapViewController.view.translatesAutoresizingMaskIntoConstraints = false
        mapViewController.view.bottomAnchor.constraint(equalTo: playerView.topAnchor, constant: 0).isActive = true
        mapViewController.view.topAnchor.constraint(equalTo: view.topAnchor, constant: 0).isActive = true
        mapViewController.view.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 0).isActive = true
        mapViewController.view.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 0).isActive = true

        LocationController.shared.requestCurrentLocation()
        let dm = DatabaseManager()
        
        if let uid = Auth.auth().currentUser?.uid {
            dm.fetchUser(with: uid, atPath: User.Key.users)
        } else {
            AuthManager.shared.signInAnonymously { (result) in
                guard let user = result?.user else { return }
                UserController.shared.user = User(uid: user.uid, email: "\(user.uid)@gmail.com", latitude: LocationController.shared.latitude, longitude: LocationController.shared.longitude)

                dm.updateUser(UserController.shared.user!.firebaseDictionary, forUid: user.uid)

                if let uid = UserController.shared.user?.songUid,
                    let values = self.currentlyPlayingSong?.firebaseDictionary {
                    dm.updateSong(values, forUid: uid)
                }
            }
        }
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: connectionIndicatorView)
        connectionIndicatorView.frame = CGRect(origin: CGPoint(), size: CGSize(width: 20,height: 20))
    }

    // MARK: - View
    fileprivate func updateViewWithPlayerState(_ playerState: SPTAppRemotePlayerState) {
//        updatePlayPauseButtonState(playerState.isPaused)
        playButton(playerView.playButton, updatePlayButtonState: playerState.isPaused)
        SpotifyManager.shared.fetchAlbumArtForTrack(appRemote, playerState.track) { (image) in
            self.playerView.updateAlbumArtWithImage(image)
        }
   
        updateProgressView(playerState)
        let title = playerState.track.name
        let artist = playerState.track.artist.name
        let playbackDuration = Double(playerState.track.duration / 1000)
        let dm = DatabaseManager()
        
        playerView.updatePlayerState(playerState)
        mapViewController.mapView.userLocation.title = title
        mapViewController.mapView.userLocation.subtitle = artist
        
        if let uid = UserController.shared.user?.songUid {
            let songValues: [String: Any] = [
                Song.Key.title: title,
                Song.Key.artist: artist,
                Song.Key.playbackDuration: playbackDuration,
            ]
            dm.updateSong(songValues, forUid: uid)
        }
    }

    fileprivate func encodeStringAsUrlParameter(_ value: String) -> String {
        let escapedString = value.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)
        return escapedString!
    }

    fileprivate func enableInterface(_ enabled: Bool = true) {
        if (!enabled) {
//            updatePlayPauseButtonState(true)
            playButton(playerView.playButton, updatePlayButtonState: true)
        }
    }

//    fileprivate func updatePlayPauseButtonState(_ paused: Bool) {
//        let playPauseButtonImage = paused ? PlaybackButtonGraphics.playButtonImage() : PlaybackButtonGraphics.pauseButtonImage()
//        playerView.playButton.setImage(playPauseButtonImage, for: UIControl.State())
//        playerView.playButton.setImage(playPauseButtonImage, for: .highlighted)
//    }
    
    fileprivate func setupPlayerView() {
        view.addSubview(playerView)
        playerView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 0).isActive = true
        playerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 0).isActive = true
        playerView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 0).isActive = true
        playerView.heightAnchor.constraint(equalToConstant: 72).isActive = true
    }
    
    // MARK: - Progress View
    
    func updateProgressView(_ playerState: SPTAppRemotePlayerState) {
        let durationSeconds = Float(playerState.track.duration) / 1000
        let playbackPosition = Float(playerState.playbackPosition) / 1000
        
        //        self.playbackDurationProgressView.setProgress(currentPlaybackPositionProgress, animated: false)
        //        print("Progress:", self.playbackDurationProgressView.progress)
        //
        
        print("Seconds:", Float(playerState.playbackPosition / 1000))
        
        playerView.durationView.maximumValue = durationSeconds
        playerView.durationView.value = playbackPosition
        
        
        
        if !isDurationInProgress {
            runProgress(durationSeconds)
            isDurationInProgress = true
        }

        if playerState.isPaused {
            timer?.invalidate()
            isDurationInProgress = false
        }
    }
    
    var timer: Timer?
    func runProgress(_ duration: Float) {
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: { timer in
            if self.playerView.durationView.value >= duration {
                self.timer?.invalidate()
                self.isDurationInProgress = false
            }
            
            self.playerView.durationView.value += 1
        })
    }

    // MARK: Player State

    fileprivate func updatePlayerStateSubscriptionButtonState() {
        let playerStateSubscriptionButtonTitle = subscribedToPlayerState ? "Unsubscribe" : "Subscribe"
        
    }

    fileprivate func updateViewWithCapabilities(_ capabilities: SPTAppRemoteUserCapabilities) {
       
    }

    fileprivate func updateCapabilitiesSubscriptionButtonState() {
        let capabilitiesSubscriptionButtonTitle = subscribedToCapabilities ? "Unsubscribe" : "Subscribe"

    }

    fileprivate var playerState: SPTAppRemotePlayerState?
    fileprivate var subscribedToPlayerState: Bool = false
    
    
    var defaultCallback: SPTAppRemoteCallback {
        get {
            return {[weak self] _, error in
                if let error = error {
                    self?.displayError(error as NSError)
                }
            }
        }
    }
    
    fileprivate func displayError(_ error: NSError?) {
        if let error = error {
            presentAlert(title: "Error", message: error.description)
        }
    }

    fileprivate func presentAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }

    // MARK: StoreKit

    fileprivate func showAppStoreInstall() {
        if TARGET_OS_SIMULATOR != 0 {
            presentAlert(title: "Simulator In Use", message: "The App Store is not available in the iOS simulator, please test this feature on a physical device.")
        } else {
            let loadingView = UIActivityIndicatorView(frame: view.bounds)
            view.addSubview(loadingView)
            loadingView.startAnimating()
            loadingView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
            let storeProductViewController = SKStoreProductViewController()
            storeProductViewController.delegate = self
            storeProductViewController.loadProduct(withParameters: [SKStoreProductParameterITunesItemIdentifier: SPTAppRemote.spotifyItunesItemIdentifier()], completionBlock: { (success, error) in
                loadingView.removeFromSuperview()
                if let error = error {
                    self.presentAlert(
                        title: "Error accessing App Store",
                        message: error.localizedDescription)
                } else {
                    self.present(storeProductViewController, animated: true, completion: nil)
                }
            })
        }
    }

    public func productViewControllerDidFinish(_ viewController: SKStoreProductViewController) {
        viewController.dismiss(animated: true, completion: nil)
    }
    
    var appRemote: SPTAppRemote {
        get {
            return AppDelegate.sharedInstance.appRemote
        }
    }

    fileprivate func skipNext() {
        appRemote.playerAPI?.skip(toNext: defaultCallback)
    }

    fileprivate func skipPrevious() {
        appRemote.playerAPI?.skip(toPrevious: defaultCallback)
    }

    fileprivate func startPlayback() {
        appRemote.playerAPI?.resume(defaultCallback)
    }

    fileprivate func pausePlayback() {
        appRemote.playerAPI?.pause(defaultCallback)
    }
    
    func playTrack() {
        appRemote.playerAPI?.play(trackIdentifier, callback: { (callback, error) in
            if let error = error {
                print("Error playing track: \(error) \(error.localizedDescription)")
            }
            if let callback = callback {
                print("is playing")
            }
        })
    }

    fileprivate func enqueueTrack() {
        appRemote.playerAPI?.enqueueTrackUri(trackIdentifier, callback: defaultCallback)
    }

    fileprivate func toggleShuffle() {
        guard let playerState = playerState else { return }
        appRemote.playerAPI?.setShuffle(!playerState.playbackOptions.isShuffling, callback: defaultCallback)
    }

    fileprivate func getPlayerState() {
        appRemote.playerAPI?.getPlayerState { (result, error) -> Void in
            guard error == nil else { return }

            let playerState = result as! SPTAppRemotePlayerState
            PlayerStateController.shared.state = playerState
//            self.updateViewWithPlayerState(playerState)
            self.playerStateDidChange(playerState)
        }
    }

    func playTrackWithIdentifier(_ identifier: String) {
        if PlayerStateController.shared.state?.track.uri == identifier {
            return
        }
        appRemote.playerAPI?.play(identifier, callback: { (callback, error) in
            if let callback = callback {
                print("is playing")
                self.getPlayerState()
            }
        })
        
        
    }

    fileprivate func subscribeToPlayerState() {
        guard (!subscribedToPlayerState) else { return }
        appRemote.playerAPI!.delegate = self
        appRemote.playerAPI?.subscribe { (_, error) -> Void in
            guard error == nil else { return }
            self.subscribedToPlayerState = true
            self.updatePlayerStateSubscriptionButtonState()
        }
    }

    fileprivate func unsubscribeFromPlayerState() {
        guard (subscribedToPlayerState) else { return }
        appRemote.playerAPI?.unsubscribe { (_, error) -> Void in
            guard error == nil else { return }
            self.subscribedToPlayerState = false
            self.updatePlayerStateSubscriptionButtonState()
        }
    }

    fileprivate func toggleRepeatMode() {
        guard let playerState = playerState else { return }
        let repeatMode: SPTAppRemotePlaybackOptionsRepeatMode = {
            switch playerState.playbackOptions.repeatMode {
                case .off: return SPTAppRemotePlaybackOptionsRepeatMode.track
                case .track: return SPTAppRemotePlaybackOptionsRepeatMode.context
                case .context: return SPTAppRemotePlaybackOptionsRepeatMode.off
            }
        }()

        appRemote.playerAPI?.setRepeatMode(repeatMode, callback: defaultCallback)
    }

    // MARK: - Image API


    // MARK: - User API
    fileprivate var subscribedToCapabilities: Bool = false

    fileprivate func fetchUserCapabilities() {
        appRemote.userAPI?.fetchCapabilities(callback: { (capabilities, error) in
            guard error == nil else { return }

            let capabilities = capabilities as! SPTAppRemoteUserCapabilities
            self.updateViewWithCapabilities(capabilities)
        })
    }

    fileprivate func subscribeToCapabilityChanges() {
        guard (!subscribedToCapabilities) else { return }
        appRemote.userAPI!.delegate = self
        appRemote.userAPI?.subscribe(toCapabilityChanges: { (success, error) in
            guard error == nil else { return }

            self.subscribedToCapabilities = true
            self.updateCapabilitiesSubscriptionButtonState()
        })
    }

    fileprivate func unsubscribeFromCapailityChanges() {
        guard (subscribedToCapabilities) else { return }
        AppDelegate.sharedInstance.appRemote.userAPI?.unsubscribe(toCapabilityChanges: { (success, error) in
            guard error == nil else { return }

            self.subscribedToCapabilities = false
            self.updateCapabilitiesSubscriptionButtonState()
        })
    }

    // MARK: - <SPTAppRemotePlayerStateDelegate>

    func playerStateDidChange(_ playerState: SPTAppRemotePlayerState) {
        self.playerState = playerState
        PlayerStateController.shared.state = self.playerState
        updateViewWithPlayerState(playerState)
        //isDurationInProgress = false
    }

    // MARK: - <SPTAppRemoteUserAPIDelegate>

    func userAPI(_ userAPI: SPTAppRemoteUserAPI, didReceive capabilities: SPTAppRemoteUserCapabilities) {
        updateViewWithCapabilities(capabilities)
    }

    func showError(_ errorDescription: String) {
        let alert = UIAlertController(title: "Error!", message: errorDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func appRemoteConnecting() {
        connectionIndicatorView.state = .connecting
    }

    func appRemoteConnected() {
        connectionIndicatorView.state = .connected
        subscribeToPlayerState()
        subscribeToCapabilityChanges()
        getPlayerState()

        enableInterface(true)
    }

    func appRemoteDisconnect() {
        connectionIndicatorView.state = .disconnected
        self.subscribedToPlayerState = false
        self.subscribedToCapabilities = false
        enableInterface(false)
    }
}


extension HomeViewController: PlayerViewDelegate {

    func playerView(_ view: PlayerView, playButtonTapped: UIButton) {
        if !(appRemote.isConnected) {
            if (!appRemote.authorizeAndPlayURI(playURI)) {
                // The Spotify app is not installed, present the user with an App Store page
                showAppStoreInstall()
            }
        } else if playerState == nil || playerState!.isPaused {
            startPlayback()
        } else {
            pausePlayback()
        }
        
        getPlayerState()
    }
    
    func open(scheme: String) {
        guard let url = URL(string: scheme) else { return }
        if UIApplication.shared.canOpenURL(url) {
            if #available(iOS 10, *) { // For ios 10 and greater
                UIApplication.shared.open(url, options: [:], completionHandler: { (success) in
                    if success {
                        print("Open \(scheme): \(success)")
                    }
                })
            } else { // for below ios 10.
                let success = UIApplication.shared.openURL(url)
                print("Open \(scheme): \(success)")
            }
        } else {
            UIApplication.shared.open(URL(string: "https://itunes.apple.com/app/spotify-music/id324684580")!, options: [:]) { (success) in
                if success { print("opening app store to spotify")}
            }
        }
    }
    
    func playerView(_ view: PlayerView, albumArtTapped: UITapGestureRecognizer) {
        guard let artistUri = playerState?.track.artist.uri else { return }
        let artistUriArray = Array(artistUri.split(separator: ":"))
        let artist = artistUriArray[1]
        let artistId = artistUriArray[2]

        let spotifyUrl = "https://open.spotify.com/\(artist)/\(artistId)"
        
        open(scheme: spotifyUrl)
    }
    
    func playerView(_ view: PlayerView, updatePlayPauseButtonState paused: Bool) {
//        let playPauseButtonImage = paused ? PlaybackButtonGraphics.playButtonImage() : PlaybackButtonGraphics.pauseButtonImage()
//        view.playButton.setImage(playPauseButtonImage, for: UIControl.State())
//        view.playButton.setImage(playPauseButtonImage, for: .highlighted)
    }
}

extension HomeViewController: PlayButtonDelegate {
    func playButton(_ button: UIButton, updatePlayButtonState paused: Bool) {
        let playPauseButtonImage = paused ? PlaybackButtonGraphics.playButtonImage() : PlaybackButtonGraphics.pauseButtonImage()
        button.setImage(playPauseButtonImage, for: UIControl.State())
        button.setImage(playPauseButtonImage, for: .highlighted)
    }
}
