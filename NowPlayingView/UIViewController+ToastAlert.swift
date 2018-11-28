//
//  UIViewController+Alert.swift
//  PairRandomizer
//
//  Created by Jason Goodney on 10/5/18.
//  Copyright © 2018 Jason Goodney. All rights reserved.
//

import UIKit

extension UIViewController {
    
    func presentAlert(withTitle title: String, message: String, completion: @escaping (Bool) -> Void) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "OK", style: .default)
        
        [okAction].forEach { alertController.addAction($0) }
        
        present(alertController, animated: true, completion: nil)
    }
    
    func presentErrorAlert(withTitle title: String, message: String) {
        presentAlert(title: title, message: message)
    }
}
