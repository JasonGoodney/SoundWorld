//
//  SpotifyConnectButton.swift
//  NowPlayingView
//
//  Created by Jason Goodney on 11/7/18.
//

import UIKit

protocol SpotifyConnectButtonDelegate: class {
    func spotifyConnectButtonTapped(_ button: SpotifyConnectButton)
}

class SpotifyConnectButton: UIButton {

    weak var delegate: SpotifyConnectButtonDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setupView()
    }
    
    func setupView() {
        backgroundColor = #colorLiteral(red: 0.1137254902, green: 0.7254901961, blue: 0.3294117647, alpha: 1)
        setTitle("Connect To Spotify", for: .normal)
        setTitleColor(.white, for: .normal)
        titleLabel?.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        translatesAutoresizingMaskIntoConstraints = false
    }
}
