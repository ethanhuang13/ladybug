//
//  Radar+Extension.swift
//  Ladybug
//
//  Created by Ethanhuang on 2018/6/26.
//  Copyright © 2018年 Elaborapp Co., Ltd. All rights reserved.
//

import UIKit

extension Radar {
    var toggleFavoriteAction: UIContextualAction {
        let isFavorited = favoritedDate != nil
        return UIContextualAction(style: .normal, title: isFavorited ? "Unbookmark".localized() : "Bookmark".localized(), handler: { (_, _, completion) in
            try? RadarCollection.shared.toggleFavorite(radarID: self.id)
            completion(true)
        })
    }

    var deleteAction: UIContextualAction {
        return UIContextualAction(style: .destructive, title: "Delete".localized(), handler: { (_, _, completion) in
            RadarCollection.shared.remove(radar: self)
            completion(true)
        })
    }
}
