//
//  UIAlertController+Extension.swift
//  Ladybug
//
//  Created by Ethanhuang on 2018/6/30.
//  Copyright © 2018年 Elaborapp Co., Ltd. All rights reserved.
//

import UIKit

extension UIAlertController {
    static func errorAlertController(_ error: Error) -> UIAlertController {
        let alertController = UIAlertController(title: "Error".localized(), message: error.localizedDescription, preferredStyle: .alert)
        alertController.addAction(.cancelAction)
        return alertController
    }
}
