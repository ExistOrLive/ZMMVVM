//
//  ZMBaseViewUpdatable.swift
//
//  Created by admin on 3/13/23.
//

import Foundation
import UIKit

// MARK: ZMBaseViewUpdatable
public protocol ZMBaseViewUpdatable: AnyObject {
        
    func zm_fillWithData(data: Any)
}

// MARK: ZLViewUpdatableForView
public protocol ZMBaseViewUpdatableWithViewData: ZMBaseViewUpdatable {
    
    associatedtype ViewData
    
    func zm_fillWithViewData(viewData: ViewData)
}

public extension ZMBaseViewUpdatableWithViewData where Self: UIView {
    
    func zm_fillWithData(data: Any) {
        if let viewData = data as? ViewData {
            if let viewModel = viewData as? ZMBaseViewModelProtocol {
                viewModel.zm_view = self
                self.zm_viewModel = viewModel
            }
            zm_fillWithViewData(viewData: viewData)
            if let viewModel = viewData as? ZMBaseViewModelProtocol {
                viewModel.zm_onViewUpdated()
            }
        }
    }
}


private var zm_viewModelKey = 0
public extension UIView {
    @objc dynamic var zm_viewModel: ZMBaseViewModelProtocol? {
        get {
            (objc_getAssociatedObject(self, &zm_viewModelKey) as? ZMWeakViewModelContainer)?.zm_viewModel as? ZMBaseViewModelProtocol
        }
        set {
            let container = ZMWeakViewModelContainer(viewModel: newValue)
            objc_setAssociatedObject(self, &zm_viewModelKey, container, .OBJC_ASSOCIATION_RETAIN)
        }
    }
}

fileprivate class ZMWeakViewModelContainer: NSObject {
    @objc dynamic weak var zm_viewModel: ZMBaseViewModelProtocol?
    init(viewModel: ZMBaseViewModelProtocol?) {
        zm_viewModel = viewModel
        super.init()
    }
}
