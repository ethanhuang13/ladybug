//
//  Radar+Extension.swift
//  Ladybug
//
//  Created by Ethanhuang on 2018/6/26.
//  Copyright © 2018年 Elaborapp Co., Ltd. All rights reserved.
//

import UIKit

extension Radar {
    var toggleBookmarkAction: UIContextualAction {
        let isBookmarked = bookmarkedDate != nil
        let action = UIContextualAction(style: .normal, title: isBookmarked ? "Unbookmark".localized() : "Bookmark".localized(), handler: { (_, _, completion) in
            try? RadarCollection.shared.toggleBookmark(radarID: self.id)
            completion(true)
        })
        return action
    }

    var removeFromHistoryAction: UIContextualAction {
        let action = UIContextualAction(style: .destructive, title: "Remove".localized(), handler: { (_, _, completion) in
            RadarCollection.shared.removeFromHistory(radarID: self.id)
            completion(true)
        })
        return action
    }
}
