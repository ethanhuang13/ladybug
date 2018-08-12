//
//  Radar+Extension.swift
//  Ladybug
//
//  Created by Ethanhuang on 2018/6/26.
//  Copyright © 2018年 Elaborapp Co., Ltd. All rights reserved.
//

import UIKit

extension Radar {
    var isBookmarked: Bool {
        return bookmarkedDate != nil
    }

    func toggleBookmark() {
        try? RadarCollection.shared.toggleBookmark(radarNumber: self.number)
    }

    var toggleBookmarkAction: UIContextualAction {
        let action = UIContextualAction(style: .normal, title: isBookmarked ? "Unbookmark".localized() : "Bookmark".localized(), handler: { (_, _, completion) in
            self.toggleBookmark()
            completion(true)
        })
        return action
    }

    var removeFromHistoryAction: UIContextualAction {
        let action = UIContextualAction(style: .destructive, title: "Remove".localized(), handler: { (_, _, completion) in
            RadarCollection.shared.removeFromHistory(radarNumber: self.number)
            completion(true)
        })
        return action
    }
}
