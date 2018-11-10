import Foundation

extension String {
    func encodeStringAsUrlParameter(_ value: String) -> String {
        let escapedString = value.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)
        return escapedString!
    }
}

extension Dictionary {

    func urlParametersRepresentation() -> String {
        // Add the necessary parameters
        var pairs = [String]()
        for (key, value) in self {
            let keyString = key as! String
            let valueString = value as! String
            let encodedKey = keyString.encodeStringAsUrlParameter(key as! String)
            let encodedValue = valueString.encodeStringAsUrlParameter(value as! String)
            let encoded = String(format: "%@=%@", encodedKey, encodedValue);
            pairs.append(encoded)
        }

        return pairs.joined(separator: "&")
    }
}

extension UIViewController {
    func presentAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func presentInstallAlert(title: String, message: String, okCompletion: @escaping (UIAlertAction) -> Void) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Install", style: .default, handler: okCompletion))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}

