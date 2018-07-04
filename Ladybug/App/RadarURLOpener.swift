//
//  URLOpener.swift
//  Ladybug
//
//  Created by Ethanhuang on 2018/6/13.
//  Copyright © 2018年 Elaborapp Co., Ltd. All rights reserved.
//

import UIKit

protocol RadarURLOpenerUI {
    func openRadarLinkInSafariViewController(_ radarNumber: RadarNumber, radarOption: RadarOption, readerMode: Bool)
}

class RadarURLOpener {
    static let shared = RadarURLOpener()
    var delegate: RadarURLOpenerUI?

    func canOpen(in browserOption: BrowserOption) -> Bool {
        switch browserOption {
        case .sfvcReader, .sfvc:
            return delegate != nil
        case .safari:
            return true
        case .briskApp:
            let url = URL(string: "brisk-rdar://")!
            return UIApplication.shared.canOpenURL(url)
        }
    }

    func open(_ radarNumber: RadarNumber, radarOption: RadarOption = .openRadar, in browserOption: BrowserOption = .sfvcReader, completion: @escaping (Result<Void>) -> Void) {

        guard canOpen(in: browserOption) else {
            completion(.error(RadarURLOpenerError.cannotOpenIn(browserOption)))
            return
        }

        guard let delegate = self.delegate else {
            completion(.error(RadarURLOpenerError.delegateIsNil))
            return
        }

        let url: URL = radarNumber.url(by: radarOption)
        
        switch browserOption {
        case .sfvcReader:
            delegate.openRadarLinkInSafariViewController(radarNumber, radarOption: radarOption, readerMode: true)
            completion(.value(()))

        case .sfvc:
            delegate.openRadarLinkInSafariViewController(radarNumber, radarOption: radarOption, readerMode: false)
            completion(.value(()))

        case .safari, .briskApp:
            UIApplication.shared.open(url, options: [:]) { (success) in
                if success {
                    completion(.value(()))
                } else {
                    completion(.error(RadarURLOpenerError.appOpenURLError))
                }
            }
        }
    }
}
