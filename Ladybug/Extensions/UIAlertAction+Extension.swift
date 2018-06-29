//
//  UIAlertAction+Extension.swift
//  Ladybug
//
//  Created by Ethanhuang on 2018/6/14.
//  Copyright © 2018年 Elaborapp Co., Ltd. All rights reserved.
//

import UIKit

extension UIAlertAction {
    static let okAction = UIAlertAction(title: "OK".localized(), style: .cancel, handler: nil)
    static let cancelAction = UIAlertAction(title: "Cancel".localized(), style: .cancel, handler: nil)
}
