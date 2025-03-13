//
//  ZMBaseTableViewController.swift
//  ZMMVVM
//
//  Created by 朱猛 on 2025/3/14.
//

import Foundation
import UIKit

open class ZMBaseTableViewController: UIViewController, ZMBaseTableViewContainerProtocol {
   
    /// section 数组
    public let tableViewProxy: ZMBaseTableViewProxy
    
    public init(style: UITableView.Style = UITableView.Style.grouped) {
        self.tableViewProxy = ZMBaseTableViewProxy(style: style)
        super.init(nibName: nil, bundle: nil)
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


