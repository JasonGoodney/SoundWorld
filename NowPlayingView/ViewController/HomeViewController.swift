import UIKit
import StoreKit
import MapKit
import FirebaseAuth

class HomeViewController: UIViewController, SKStoreProductViewControllerDelegate {

    // MARK: - Properties
    var appRemote: SPTAppRemote {
        get {
            return AppDelegate.sharedInstance.appRemote
        }
    }
    fileprivate var playURI = ""
    var trackIdentifier = "" {
        didSet {
            playTrackWithUri(trackIdentifier)
        }
    }
    fileprivate var currentlyPlayingSong: Song?
    fileprivate var isDurationInProgress = false
    
    // MARK: - Subviews
    private let mapViewController = MapViewController()
    private var connectionIndicatorView = ConnectionStatusIndicatorView()
    lazy var playerView: PlayerView = {
        let view = PlayerView(frame: .zero)
        view.delegate = self
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isHidden = true
        return view
    }()
    lazy var spotifyConnectButton: SpotifyConnectButton = {
        let button = SpotifyConnectButton(frame: .zero)
        button.delegate = self
        button.addTarget(self, action: #selector(spotifyConnectButtonTapped(_:)), for: .touchUpInside)
        return button
    }()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.isHidden = true
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        updateView()
        
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
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print(playerView.playButton.frame)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - View
    fileprivate func updateViewWithPlayerState(_ playerState: SPTAppRemotePlayerState) {
        playButton(playerView.playButton, isPaused: playerState.isPaused)
        SpotifyManager.shared.fetchAlbumArtForTrack(appRemote, playerState.track) { (image) in
            self.playerView.updateAlbumArtWithImage(image)
        }
   
        updateProgressView(playerState)
        let title = playerState.track.name
        let artist = playerState.track.artist.name
        let playbackDuration = Double(playerState.track.duration / 1000)
        let isPaused = playerState.isPaused
        let spotifyUri = playerState.track.uri
        let isSavedToSpotify = playerState.track.isSaved
        
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
            playButton(playerView.playButton, isPaused: true)
        }
    }
    
    // MARK: - Progress View
    
    func updateProgressView(_ playerState: SPTAppRemotePlayerState) {
        let durationSeconds = Float(playerState.track.duration) / 1000
        let playbackPosition = Float(playerState.playbackPosition) / 1000

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

    var playerState: SPTAppRemotePlayerState?
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

    fileprivate func startPlayback() {
        appRemote.playerAPI?.resume(defaultCallback)
    }

    fileprivate func pausePlayback() {
        appRemote.playerAPI?.pause(defaultCallback)
    }

    fileprivate func enqueueTrack() {
        appRemote.playerAPI?.enqueueTrackUri(trackIdentifier, callback: defaultCallback)
    }

    fileprivate func getPlayerState() {
        appRemote.playerAPI?.getPlayerState { (result, error) -> Void in
            guard error == nil else { return }

            let playerState = result as! SPTAppRemotePlayerState
            PlayerStateController.shared.state = playerState
            self.playURI = playerState.track.uri
            self.playerStateDidChange(playerState)
        }
    }

    func playTrackWithUri(_ uri: String) {
        if PlayerStateController.shared.state?.track.uri == uri {
            return
        }
        if !(appRemote.isConnected) {
            if (!appRemote.authorizeAndPlayURI(uri)) {
                // The Spotify app is not installed, present the user with an App Store page
                showAppStoreInstall()
            }
        }
        
        appRemote.playerAPI?.play(uri, callback: { (callback, error) in
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
        }
    }

    fileprivate func unsubscribeFromPlayerState() {
        guard (subscribedToPlayerState) else { return }
        appRemote.playerAPI?.unsubscribe { (_, error) -> Void in
            guard error == nil else { return }
            self.subscribedToPlayerState = false
        }
    }

    // MARK: - User API
    fileprivate var subscribedToCapabilities: Bool = false

    fileprivate func subscribeToCapabilityChanges() {
        guard (!subscribedToCapabilities) else { return }
        appRemote.userAPI!.delegate = self
        appRemote.userAPI?.subscribe(toCapabilityChanges: { (success, error) in
            guard error == nil else { return }

            self.subscribedToCapabilities = true
        })
    }

    fileprivate func unsubscribeFromCapailityChanges() {
        guard (subscribedToCapabilities) else { return }
        AppDelegate.sharedInstance.appRemote.userAPI?.unsubscribe(toCapabilityChanges: { (success, error) in
            guard error == nil else { return }

            self.subscribedToCapabilities = false
        })
    }
    
    func connectToSpotify() {
        if !(appRemote.isConnected) {
            getPlayerState()
            if (!appRemote.authorizeAndPlayURI(playURI)) {
                // The Spotify app is not installed, present the user with an App Store page
                showAppStoreInstall()
            }
        } else if playerState == nil || playerState!.isPaused {
            startPlayback()
        } else {
            pausePlayback()
        }
        
//        getPlayerState()
    }

}

// MARK: - UI
private extension HomeViewController {
    func updateView() {
        view.backgroundColor = .black
        addSubviews([spotifyConnectButton, playerView])
        setupPlayerView()
        setupSpotifyConnectButton()
        setupMapView()
    }
    
    func addSubviews(_ subviews: [UIView]) {
        subviews.forEach{ view.addSubview($0) }
    }

    func setupSpotifyConnectButton() {
        NSLayoutConstraint.activate([
            spotifyConnectButton.leftAnchor.constraint(equalTo: view.leftAnchor),
            spotifyConnectButton.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            spotifyConnectButton.rightAnchor.constraint(equalTo: view.rightAnchor),
            spotifyConnectButton.heightAnchor.constraint(equalToConstant: 72)
        ])
    }
    
    func setupMapView() {
        addChild(mapViewController)
        view.addSubview(mapViewController.view)
        mapViewController.didMove(toParent: self)
        mapViewController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            mapViewController.view.bottomAnchor.constraint(equalTo: playerView.topAnchor, constant: 0),
            mapViewController.view.topAnchor.constraint(equalTo: view.topAnchor, constant: 0),
            mapViewController.view.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 0),
            mapViewController.view.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 0),
        ])
    }
    
    func setupPlayerView() {
        playerView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 0).isActive = true
        playerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 0).isActive = true
        playerView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 0).isActive = true
        playerView.heightAnchor.constraint(equalToConstant: 72).isActive = true
    }
}

// MARK: - SPTAppRemotePlayerStateDelegate
extension HomeViewController: SPTAppRemotePlayerStateDelegate {
    func playerStateDidChange(_ playerState: SPTAppRemotePlayerState) {
        self.playerState = playerState
        PlayerStateController.shared.state = self.playerState
        updateViewWithPlayerState(playerState)
    }
}

// MARK: - SPTAppRemoteUserAPIDelegate
extension HomeViewController: SPTAppRemoteUserAPIDelegate {
    
    func userAPI(_ userAPI: SPTAppRemoteUserAPI, didReceive capabilities: SPTAppRemoteUserCapabilities) {
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
        
        spotifyConnectButton.isHidden = true
        playerView.isHidden = false
        enableInterface(true)

    }
    
    func appRemoteDisconnect() {
        connectionIndicatorView.state = .disconnected
        self.subscribedToPlayerState = false
        self.subscribedToCapabilities = false
        enableInterface(false)
    }

}

// MARK: - PlayerViewDelegate
extension HomeViewController: PlayerViewDelegate {

    func playerView(_ view: PlayerView, addSongToSpotifyButtonTapped: UIButton) {
        
        appRemote.userAPI?.addItemToLibrary(withURI: playURI, callback: defaultCallback)
    }
    
    func playerView(_ view: PlayerView, playButtonTapped: UIButton) {
        connectToSpotify()
    }
    
    func open(scheme: String, appStoreUrlString: String) {
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
            UIApplication.shared.open(URL(string: appStoreUrlString)!, options: [:]) { (success) in
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
        
        open(scheme: spotifyUrl, appStoreUrlString: "https://itunes.apple.com/app/spotify-music/id324684580")
    }
}

// MARK: - PlayButtonDelegate
extension HomeViewController: PlayButtonDelegate {
    func playButton(_ button: UIButton, isPaused: Bool) {
        let playPauseButtonImage = isPaused ? PlaybackButtonGraphics.playButtonImage() : PlaybackButtonGraphics.pauseButtonImage()
        button.setImage(playPauseButtonImage, for: UIControl.State())
        button.setImage(playPauseButtonImage, for: .highlighted)
    }
}

// MARK: - SpotifyConnectButtonDelegate
extension HomeViewController: SpotifyConnectButtonDelegate {
    @objc func spotifyConnectButtonTapped(_ button: SpotifyConnectButton) {
        connectToSpotify()
    }
}

// Move view with keyboard presentation
extension HomeViewController {
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0{
                self.view.frame.origin.y -= keyboardSize.height
            }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y != 0{
                self.view.frame.origin.y += keyboardSize.height
            }
        }
    }
}
