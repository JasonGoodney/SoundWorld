//
//  PlayerView.swift
//  SoundWorld
//
//  Created by Jason Goodney on 11/2/18.
//  Copyright © 2018 Jason Goodney. All rights reserved.
//

import UIKit

protocol PlayButtonDelegate: class {
    func playButton(_ button: UIButton, isPaused: Bool)
}
extension PlayButtonDelegate {
    func playButton(_ button: UIButton, isPaused: Bool) {
        let playPauseButtonImage = isPaused ? PlaybackButtonGraphics.playButtonImage() : PlaybackButtonGraphics.pauseButtonImage()
        button.setImage(playPauseButtonImage, for: UIControl.State())
        button.setImage(playPauseButtonImage, for: .highlighted)
    }
}

protocol PlayerViewDelegate: class {
    func playerView(_ view: PlayerView, playButtonTapped: UIButton)
    func playerView(_ view: PlayerView, addSongToSpotifyButtonTapped: UIButton)
    func playerView(_ view: PlayerView, albumArtTapped: UITapGestureRecognizer)
}

class PlayerView: UIView {

    weak var delegate: PlayerViewDelegate?
   
    
    // MARK: - Subviews
    let durationView: UISlider = {
        let view = UISlider()
        view.isUserInteractionEnabled = false
        view.setThumbImage(UIImage(), for: .normal)
        view.tintColor = UIColor.Theme.primary
        return view
    }()

    lazy var buttonStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [addSongToSpotifyButton, playButton])
        stackView.axis = .horizontal
        return stackView
    }()
    
    lazy var addSongToSpotifyButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("+", for: .normal)
        button.addTarget(self, action: #selector(addSongToSpotifyButtonTapped), for: .touchUpInside)
        return button
    }()
    
    lazy var playButton: UIButton = {
        let button = UIButton(type: .system)
        button.addTarget(self, action: #selector(playButtonTapped(_:)), for: .touchUpInside)
        button.setImage(PlaybackButtonGraphics.playButtonImage(), for: .normal)
        button.setImage(PlaybackButtonGraphics.playButtonImage(), for: .highlighted)
        button.tintColor = UIColor.Theme.primary
        return button
    }()
    
    lazy var albumArtTapGesture = UITapGestureRecognizer(target: self, action: #selector(albumArtTapped(_:)))
    
    private lazy var albumArtImageView: UIImageView = {
        let view = UIImageView()
        view.addGestureRecognizer(albumArtTapGesture)
        view.isUserInteractionEnabled = true
        return view
    }()
    
    private let songNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        label.textColor = UIColor.Theme.primary
        return label
    }()

    private let artistNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = #colorLiteral(red: 0.9019607843, green: 0.9019607843, blue: 0.9028870679, alpha: 1)
        return label
    }()
    
    lazy var songInfoStackView: UIStackView = {
        let view = UIStackView(arrangedSubviews: [songNameLabel, artistNameLabel])
        view.axis = .vertical
        view.alignment = .leading
        view.spacing = 4
        return view
    }()
    
    lazy var stackView: UIStackView = {
        let view = UIStackView(arrangedSubviews: [albumArtImageView, songInfoStackView, playButton])
        view.axis = .horizontal
        return view
    }()
    
    convenience init() {
        self.init(frame: .zero)
        
        setupView()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setupView()
    }
    
    // MARK: - UpdateView
    func updatePlayerState(_ playerState: SPTAppRemotePlayerState) {
        let song = playerState.track
        
        let songName = song.name
        let artistName = song.artist.name
        
        DispatchQueue.main.async {
            self.songNameLabel.text = songName
            self.artistNameLabel.text = artistName
        }
    }
    
    func updateAlbumArtWithImage(_ image: UIImage) {
        DispatchQueue.main.async {
            self.albumArtImageView.image = image
        }
        
        let transition = CATransition()
        transition.duration = 0.3
        transition.type = .fade
        self.albumArtImageView.layer.add(transition, forKey: "transition")
    }
    
    @objc private func playButtonTapped(_ sender: UIButton) {
        delegate?.playerView(self, playButtonTapped: sender)
    }
    
    @objc private func albumArtTapped(_ sender: UITapGestureRecognizer) {
        delegate?.playerView(self, albumArtTapped: sender)
    }
    
    @objc func addSongToSpotifyButtonTapped(_ sender: UIButton) {
        delegate?.playerView(self, addSongToSpotifyButtonTapped: sender)
    }
}

// MARK: - UI
private extension PlayerView {
    func setupView() {
        backgroundColor = UIColor.Theme.primaryBackground
        
        addSubviews([albumArtImageView, songInfoStackView, buttonStackView, durationView])
        
        albumArtImageViewConstraints()
        songInfoConstraints()
//        playButtonConstraints()
        buttonConstraints()
        durationViewConstraints()
    }

    func songInfoConstraints() {
        songInfoStackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            songInfoStackView.centerYAnchor.constraint(equalTo: centerYAnchor),
            songInfoStackView.leftAnchor.constraint(equalTo: albumArtImageView.rightAnchor, constant: 16),
            songInfoStackView.rightAnchor.constraint(equalTo: playButton.leftAnchor, constant: -16),
        ])
    }
    
    func albumArtImageViewConstraints() {
        let imageViewLength: CGFloat = 56
        albumArtImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            albumArtImageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            albumArtImageView.leftAnchor.constraint(equalTo: leftAnchor, constant: 16),
            albumArtImageView.widthAnchor.constraint(equalToConstant: imageViewLength),
            albumArtImageView.heightAnchor.constraint(equalToConstant: imageViewLength),
        ])
    }
    
    func playButtonConstraints() {
        playButton.translatesAutoresizingMaskIntoConstraints = false
        playButton.rightAnchor.constraint(equalTo: rightAnchor, constant: -16).isActive = true
        playButton.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
    }
    
    func buttonConstraints() {
        buttonStackView.translatesAutoresizingMaskIntoConstraints = false
        buttonStackView.rightAnchor.constraint(equalTo: rightAnchor, constant: -16).isActive = true
        buttonStackView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
    }
    
    func durationViewConstraints() {
        durationView.translatesAutoresizingMaskIntoConstraints = false
        durationView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        durationView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        durationView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
    }
}

extension UIView {
    func addSubviews(_ subviews: [UIView]) {
        subviews.forEach{
            addSubview($0)
            
        }
    }
}
