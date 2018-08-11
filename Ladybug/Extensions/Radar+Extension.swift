//
//  Radar+Extension.swift
//  Ladybug
//
//  Created by Ethanhuang on 2018/6/26.
//  Copyright © 2018年 Elaborapp Co., Ltd. All rights reserved.
//

import UIKit
import Echo

extension Radar {
    var toggleBookmarkAction: UIContextualAction {
        let isBookmarked = bookmarkedDate != nil
        let action = UIContextualAction(style: .normal, title: isBookmarked ? "Unbookmark".localized() : "Bookmark".localized(), handler: { (_, _, completion) in
            try? RadarCollection.shared.toggleBookmark(radarNumber: self.number)
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
    
    var cellTitle: String {
        return number.string
    }
    
    var cellSubtitle: String {
        return metadata?.title ?? "(No record on Open Radar)".localized()
    }
    
    func caseInsensitiveContains(string: String) -> Bool {
        let searchText = string.lowercased()
        
        if let metadata = self.metadata {
            return metadata.number.contains(searchText)
                || metadata.title.lowercased().contains(searchText)
                || metadata.description.lowercased().contains(searchText)
                || metadata.product.lowercased().contains(searchText)
                || metadata.classification.lowercased().contains(searchText)
                || metadata.status.lowercased().contains(searchText)
                || metadata.resolved.lowercased().contains(searchText)
                || metadata.user.lowercased().contains(searchText)
                || metadata.reproducible.lowercased().contains(searchText)
                || metadata.originated.lowercased().contains(searchText)
                || metadata.productVersion.lowercased().contains(searchText)
        }
        return number.string.contains(searchText)
    }
}
