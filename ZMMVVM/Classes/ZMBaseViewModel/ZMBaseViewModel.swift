//
//  ZMBaseViewModel.swift
//
//  Created by admin on 3/13/23.
//

import Foundation
import UIKit

// MARK: - baseViewModel 协议 ZMBaseViewModelProtocol
@objc public protocol ZMBaseViewModelProtocol: NSObjectProtocol {
    
    @objc var zm_ID: String { get }                               /// ViewModel 业务id
     
    @objc var zm_viewController: UIViewController? { get }        ///
    
    // MARK: Parent and children
    @objc var zm_superViewModel: ZMBaseViewModelProtocol? { get }
    
    @objc var zm_subViewModels: [ZMBaseViewModel] { get }
    
    @objc func zm_addSubViewModel(_ viewModel: ZMBaseViewModel)
    
    @objc func zm_addSubViewModels(_ viewModels: [ZMBaseViewModel])
    
    @objc func zm_removeSubViewModel(_ viewModel: ZMBaseViewModel)
    
    @objc func zm_removeFromSuperViewModel()
    
    @objc func zm_removeAllSubViewModels()
    
    // MARK: bind view
    @objc var zm_view: UIView? {  get set }                           ///  当前关联的view
    
    @objc func zm_reloadView()
    
    @objc func zm_onViewUpdated()                      /// 在View执行完zm_fillWithData 时调用
    
    // MARK: life cycle
    @objc func zm_viewWillAppear()
    
    @objc func zm_viewDidAppear()
    
    @objc func zm_viewWillDisappear()
    
    @objc func zm_viewDidDisappear()
    
    @objc func zm_didReceiveMemoryWarning()
}

// MARK: - ZMBaseViewModel
/// ZMBaseViewModel 的方法必须在主线程调用
@objc open class ZMBaseViewModel: NSObject {

    @objc dynamic var _subViewModels: [ZMBaseViewModel] = []
    
    @objc dynamic weak var _superViewModel: ZMBaseViewModelProtocol?
    
    @objc dynamic weak var _view: UIView?
    
    @objc dynamic open var zm_ID: String = ""
}

extension ZMBaseViewModel: ZMBaseViewModelProtocol {
    
    @objc dynamic public var zm_view: UIView? {
        set {
            _view = newValue
        }
        get {
            _view
        }
    }
    
    @objc dynamic public var zm_viewController: UIViewController? {
        zm_superViewModel?.zm_viewController
    }
    
    @objc dynamic public var zm_superViewModel: ZMBaseViewModelProtocol? {
        _superViewModel
    }
    
    @objc dynamic public var zm_subViewModels: [ZMBaseViewModel] {
        _subViewModels
    }
    
    @objc dynamic public func zm_addSubViewModel(_ viewModel: ZMBaseViewModel) {
        viewModel._superViewModel = self
        _subViewModels.append(viewModel)
    }
    
    @objc dynamic public func zm_addSubViewModels(_ viewModels: [ZMBaseViewModel]) {
        viewModels.forEach { viewModel in
            viewModel._superViewModel = self
        }
        _subViewModels.append(contentsOf: viewModels)
    }
    
    @objc dynamic public func zm_removeFromSuperViewModel() {
        _superViewModel?.zm_removeSubViewModel(self)
    }
    
    @objc dynamic public func zm_removeSubViewModel(_ viewModel: ZMBaseViewModel) {
        _subViewModels.removeAll { model in
            model === viewModel
        }
        viewModel._superViewModel = nil
    }
   
    @objc dynamic public func zm_removeAllSubViewModels() {
        _subViewModels.forEach { model in
            model._superViewModel = nil
        }
        _subViewModels.removeAll()
    }
    
    @objc dynamic public func zm_reloadView() {
        guard let view = zm_view,
              let zm_viewModel = view.zm_viewModel,
              zm_viewModel === self else {
            return
        }
        if let update = view as? ZMBaseViewUpdatable {
            update.zm_fillWithData(data: self)
        }
    }
    
    @objc dynamic open  func zm_onViewUpdated() {
        
    }

    @objc dynamic open func zm_viewWillAppear() {
        _subViewModels.forEach { $0.zm_viewWillAppear() }
    }
    
    @objc dynamic open func zm_viewDidAppear() {
        _subViewModels.forEach { $0.zm_viewDidAppear() }
    }
    
    @objc dynamic open func zm_viewWillDisappear() {
        _subViewModels.forEach { $0.zm_viewWillDisappear() }
    }
    
    @objc dynamic open func zm_viewDidDisappear() {
        _subViewModels.forEach { $0.zm_viewDidDisappear() }
    }
    
    @objc dynamic open func zm_didReceiveMemoryWarning() {
        _subViewModels.forEach { $0.zm_didReceiveMemoryWarning() }
    }
}

private var subViewModelsKey = 0

// MARK: - UIViewController + ZMBaseViewModelProtocol
extension UIViewController: ZMBaseViewModelProtocol {
   
    @objc dynamic open var zm_ID: String {
        return ""
    }
    
    @objc dynamic open var zm_view: UIView? {
        get {
            view
        }
        set {
            
        }
    }
    
    @objc dynamic open var zm_viewController: UIViewController? {
        self
    }
    
    @objc dynamic open var zm_superViewModel: ZMBaseViewModelProtocol? {
        nil
    }
    
    @objc dynamic public var zm_subViewModels: [ZMBaseViewModel] {
        objc_getAssociatedObject(self, &subViewModelsKey) as? [ZMBaseViewModel] ?? []
    }
    
    @objc dynamic public func zm_addSubViewModel(_ viewModel: ZMBaseViewModel) {
        var subViewModels = self.zm_subViewModels
        viewModel._superViewModel = self
        subViewModels.append(viewModel)
        objc_setAssociatedObject(self, &subViewModelsKey, subViewModels, .OBJC_ASSOCIATION_COPY_NONATOMIC)
    }
    
    @objc dynamic public func zm_addSubViewModels(_ viewModels: [ZMBaseViewModel]) {
        var subViewModels = self.zm_subViewModels
        viewModels.forEach { viewModel in
            viewModel._superViewModel = self
        }
        subViewModels.append(contentsOf: viewModels)
        objc_setAssociatedObject(self, &subViewModelsKey, subViewModels, .OBJC_ASSOCIATION_COPY_NONATOMIC)
    }
    
    @objc dynamic public func zm_removeFromSuperViewModel() {
        // do nothing
    }
    
    @objc dynamic public func zm_removeSubViewModel(_ viewModel: ZMBaseViewModel) {
        var subViewModels = self.zm_subViewModels
        subViewModels.removeAll { model in
            model === viewModel
        }
        objc_setAssociatedObject(self, &subViewModelsKey, subViewModels, .OBJC_ASSOCIATION_COPY_NONATOMIC)
        viewModel._superViewModel = nil
    }
    
    @objc dynamic public func zm_removeAllSubViewModels() {
        var subViewModels = self.zm_subViewModels
        subViewModels.forEach { model in
            if let model = model as? ZMBaseViewModel{
                model._superViewModel = nil
            }
        }
        objc_setAssociatedObject(self, &subViewModelsKey, [], .OBJC_ASSOCIATION_COPY_NONATOMIC)
    }
    
    @objc dynamic open func zm_reloadView() {
        //
    }
    
    @objc dynamic open func zm_onViewUpdated() {
        // 
    }
    
    
    
    @objc dynamic public func zm_viewWillAppear() {
        zm_subViewModels.forEach { $0.zm_viewWillAppear() }
    }
    
    @objc dynamic public func zm_viewDidAppear() {
        zm_subViewModels.forEach { $0.zm_viewDidAppear() }
    }
    
    @objc dynamic public func zm_viewWillDisappear() {
        zm_subViewModels.forEach { $0.zm_viewWillDisappear() }
    }
    
    @objc dynamic public func zm_viewDidDisappear() {
        zm_subViewModels.forEach { $0.zm_viewDidDisappear() }
    }
    
    @objc dynamic public func zm_didReceiveMemoryWarning() {
        zm_subViewModels.forEach { $0.zm_didReceiveMemoryWarning() }
    }
}
