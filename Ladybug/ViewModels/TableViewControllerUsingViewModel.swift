//
//  TableViewControllerUsingViewModel.swift
//  Ladybug
//
//  Created by Ethanhuang on 2018/6/30.
//  Copyright © 2018年 Elaborapp Co., Ltd. All rights reserved.
//

import UIKit

protocol TableViewControllerUsingViewModel {
    var tableView: UITableView! { get set }
    var tableViewViewModel: TableViewViewModel { get }
    func reloadData()
}
