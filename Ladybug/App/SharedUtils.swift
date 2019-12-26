//
//  SharedUtils.swift
//  Ladybug
//
//  Created by Jeriel Ng on 12/24/19.
//  Copyright © 2019 Elaborapp Co., Ltd. All rights reserved.
//

import Foundation
import UIKit

class SharedUtils {
    
    // Helper function inserted by Swift 4.2 migrator.
    class func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
        return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
    }
}
