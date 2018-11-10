//
//  StoreKitManager.swift
//  NowPlayingView
//
//  Created by Jason Goodney on 11/9/18.
//

import Foundation
import StoreKit

protocol StoreKitOpenable: class {}

class StoreKitManager {
    
    static func showAppStoreInstall<T: UIViewController & StoreKitOpenable & SKStoreProductViewControllerDelegate>(from viewController: T) {
        
        viewController.presentInstallAlert(title: "Install Spotify", message: "SoundWorld plays music with Spotify. Install Spotify to play.", okCompletion: { _ in
            StoreKitManager.presentAppStoreToSpotifyInstall(from: viewController)
        })
    }
    
    private static func presentAppStoreToSpotifyInstall<T: UIViewController & StoreKitOpenable & SKStoreProductViewControllerDelegate>(from viewController: T) {

        guard let view = viewController.view else { return }
        
        let loadingView = UIActivityIndicatorView(frame: view.bounds)
        loadingView.style = .whiteLarge
        view.addSubview(loadingView)
        loadingView.startAnimating()
        loadingView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
        let storeProductViewController = SKStoreProductViewController()
        storeProductViewController.delegate = viewController
        storeProductViewController.loadProduct(withParameters: [SKStoreProductParameterITunesItemIdentifier: SPTAppRemote.spotifyItunesItemIdentifier()], completionBlock: { (success, error) in
            loadingView.removeFromSuperview()
            if let error = error {
                viewController.presentAlert(
                    title: "Error accessing App Store",
                    message: error.localizedDescription)
            } else {
                viewController.present(storeProductViewController, animated: true)
            }
        })
    }
}
