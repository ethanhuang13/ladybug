//
//  OpenRadarKeychain+Extension.swift
//  Ladybug
//
//  Created by Ethanhuang on 2018/7/9.
//  Copyright © 2018年 Elaborapp Co., Ltd. All rights reserved.
//

import UIKit

extension OpenRadarKeychain {
    static func presentSetupAlertController(on vc: UIViewController, completion: @escaping (_ success: Bool) -> Void) {
        DispatchQueue.main.async {
            let alertController = UIAlertController(title: "Open Radar API Key is Required".localized(), message: "Sign in Open Radar to...".localized(), preferredStyle: .alert)
            alertController.addTextField { (textField) in
                textField.placeholder = "Paste the API Key here".localized()
            }
            alertController.addAction(UIAlertAction(title: "Save".localized(), style: .default, handler: { (_) in
                if let apiKey = alertController.textFields?.first?.text,
                    apiKey.isEmpty == false {
                    completion(set(apiKey: apiKey))
                } else {
                    completion(false)
                }
            }))
            alertController.addAction(UIAlertAction(title: "Get My API Key".localized(), style: .default, handler: { (_) in
                let url = URL(string: "https://openradar.appspot.com/apikey")!
                UIApplication.shared.open(url, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: { (success) in
                    if success {
                        DispatchQueue.main.async {
                            vc.present(alertController, animated: true) { }
                        }
                    }
                })
            }))
            alertController.addAction(UIAlertAction(title: "Cancel".localized(), style: .cancel, handler: { (_) in
                completion(false)
            }))

            vc.present(alertController, animated: true) { }
        }
    }

    static func presentRemoveKeyAlertContrller(on vc: UIViewController, completion: @escaping (_ success: Bool) -> Void) {
        DispatchQueue.main.async {
            let alertController = UIAlertController(title: "Remove Open Radar API Key".localized(), message: "", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Remove".localized(), style: .destructive, handler: { (_) in
                completion(deleteAPIKey())
            }))

            alertController.addAction(UIAlertAction(title: "Cancel".localized(), style: .cancel, handler: { (_) in
                completion(false)
            }))

            vc.present(alertController, animated: true) { }
        }
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
}
