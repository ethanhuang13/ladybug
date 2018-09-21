//
//  TableViewCellViewModel.swift
//  Ladybug
//
//  Created by Ethanhuang on 2018/6/14.
//  Copyright © 2018年 Elaborapp Co., Ltd. All rights reserved.
//

import UIKit

typealias UIViewControllerClosure = () -> UIViewController?
typealias Closure = () -> Void

struct TableViewCellViewModel {
    let title: String
    let subtitle: String?
    let reuseIdentifier: String
    let cellStyle: UITableViewCell.CellStyle
    let selectionStyle: UITableViewCell.SelectionStyle
    let accessoryType: UITableViewCell.AccessoryType
    var leadingSwipeActions: UISwipeActionsConfiguration?
    var trailingSwipeActions: UISwipeActionsConfiguration?
    var previewingViewController: UIViewControllerClosure?
    var selectAction: Closure

    init(title: String,
         subtitle: String? = nil,
         cellStyle: UITableViewCell.CellStyle = .default,
         selectionStyle: UITableViewCell.SelectionStyle = .default,
         accessoryType: UITableViewCell.AccessoryType = .disclosureIndicator,
         leadingSwipeActions: UISwipeActionsConfiguration? = nil,
         trailingSwipeActions: UISwipeActionsConfiguration? = nil,
         previewingViewController: UIViewControllerClosure? = nil,
         selectAction: @escaping Closure = {}
         ) {
        self.title = title
        self.subtitle = subtitle
        self.cellStyle = cellStyle
        self.reuseIdentifier = String(cellStyle.rawValue)
        self.selectionStyle = selectionStyle
        self.accessoryType = accessoryType
        self.leadingSwipeActions = leadingSwipeActions
        self.trailingSwipeActions = trailingSwipeActions
        self.previewingViewController = previewingViewController
        self.selectAction = selectAction
    }

    init(textViewString: String) {
        self.title = textViewString
        self.subtitle = ""
        self.cellStyle = .default
        self.reuseIdentifier = "textView"
        self.selectionStyle = .none
        self.accessoryType = .none
        self.leadingSwipeActions = nil
        self.trailingSwipeActions = nil
        self.previewingViewController = nil
        self.selectAction = {}
    }

    func configure(_ cell: UITableViewCell) {
        if self.reuseIdentifier == "textView" {
            let textView: UITextView = {
                if let textView = cell.contentView.subviews.filter({ $0 is UITextView }).first as? UITextView {
                    return textView
                } else {
                    let textView = UITextView(frame: cell.contentView.bounds)
                    textView.dataDetectorTypes = .all
                    textView.isScrollEnabled = false
                    textView.font = cell.textLabel?.font
                    textView.isEditable = false
                    textView.isSelectable = true
                    textView.backgroundColor = cell.backgroundColor
                    textView.textContainerInset = .zero
                    textView.textContainer.lineFragmentPadding = 0

                    cell.contentView.addSubview(textView)
                    textView.translatesAutoresizingMaskIntoConstraints = false
                    textView.topAnchor.constraint(equalTo: cell.contentView.readableContentGuide.topAnchor).isActive = true
                    textView.bottomAnchor.constraint(equalTo: cell.contentView.readableContentGuide.bottomAnchor).isActive = true
                    textView.leftAnchor.constraint(equalTo: cell.contentView.readableContentGuide.leftAnchor).isActive = true
                    textView.rightAnchor.constraint(equalTo: cell.contentView.readableContentGuide.rightAnchor).isActive = true

                    return textView
                }
            }()

            textView.text = title
        } else {
            cell.textLabel?.text = title
        }

        cell.textLabel?.numberOfLines = 0
        cell.detailTextLabel?.text = subtitle
        cell.detailTextLabel?.numberOfLines = 0
        cell.selectionStyle = selectionStyle
        cell.accessoryType = accessoryType
    }
}
