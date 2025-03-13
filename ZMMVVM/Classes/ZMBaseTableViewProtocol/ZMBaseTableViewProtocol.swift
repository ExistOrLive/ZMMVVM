//
//  ZMBaseTableView.swift
//
//  Created by admin on 3/13/23.
//

import Foundation
import UIKit

public protocol ZMBaseTableViewCellDataProtocol {
    
    /// cell唯一id
    // hotfix_ignore
    var zm_cellID: any ZMBaseCellUniqueIDProtocol { get }
    /// cell 复用id
    var zm_cellReuseIdentifier: String { get }
    /// cell 高度
    var zm_cellHeight: CGFloat { get }
    /// cell 的 indexPath
    var zm_indexPath: IndexPath { get set }
    ///  tableView的section 数量
    var zm_sectionNumber: Int { get set }
    ///  cell所在section的row数量
    var zm_rowNumberOfCurrentSection: Int { get set }
    /// sectionData
    var zm_sectionData: ZMBaseTableViewSectionData? { get set }
    
    /// 点击cell调用
    func zm_onCellSingleTap()
    /// 清空缓存
    func zm_clearCache()
    
//    /// cell曝光
//    func zm_exposureCell(cellEventTrackIDs: [String])
//    /// cell 曝光用的Ids，绝大部分情况应与与 zm_cellID 一致
//    var zm_cellEventTrackIDs: [String] { get }
}

@objc open class ZMBaseTableViewCellViewModel: ZMBaseViewModel, ZMBaseTableViewCellDataProtocol {

    open dynamic var zm_cellID: any ZMBaseCellUniqueIDProtocol {
        return ""
    }
    
    @objc dynamic open override var zm_ID: String {
        get { zm_cellID.zm_ID }
        set { }
        
    }
    
    @objc open dynamic var zm_cellReuseIdentifier: String {
        return ""
    }
    
    @objc open dynamic var zm_cellHeight: CGFloat {
        UITableView.automaticDimension
    }
    
    @objc open dynamic var zm_indexPath: IndexPath = IndexPath(row: 0, section: 0)
    
    @objc open dynamic var zm_sectionNumber: Int = 0
    
    @objc open dynamic var zm_rowNumberOfCurrentSection: Int = 0
    
    @objc open dynamic weak var zm_sectionData: ZMBaseTableViewSectionData?
   
    @objc open dynamic func zm_onCellSingleTap() {}
    
    @objc open dynamic func zm_clearCache() {}
    
//    @objc open dynamic func zm_exposureCell(cellEventTrackIDs: [String]) {}
//
//    
//    @objc open dynamic var zm_cellEventTrackIDs: [String] {
//        return [zm_cellID.zm_cellIDStr]
//    }
}

// MARK: - ZMBaseReuseViewModel
// hotfix_ignore
public protocol ZMBaseTableViewReuseViewDataProtocol {

    /// section id
    // hotfix_ignore
    var zm_sectionID: any ZMBaseSectionUniqueIDProtocol { get }
    /// cell 复用id
    var zm_viewReuseIdentifier: String { get }
    /// 是否为header
    var zm_isHeader: Bool { set get }
    /// view 高度
    var zm_viewHeight: CGFloat { get }
    /// section
    var zm_section: Int { get set }
    ///  tableView的section 数量
    var zm_sectionNumber: Int { get set }
    ///  section的row数量
    var zm_rowNumberOfCurrentSection: Int { get set }
    /// sectionData
    var zm_sectionData: ZMBaseTableViewSectionData? { get set }

    /// 清空缓存
    func zm_clearCache()

//    /// view曝光
//    func zm_exposureView(viewEventTrackIDs: [String])
//    /// view 曝光用的Ids，绝大部分情况应与与 zm_cellID 一致
//    var zm_viewEventTrackIDs: [String] { get }
}

@objc open class ZMBaseTableViewReuseViewModel: ZMBaseViewModel, ZMBaseTableViewReuseViewDataProtocol {
   
    // hotfix_ignore
    open dynamic var zm_sectionID: any ZMBaseSectionUniqueIDProtocol {
        return ""
    }

    @objc dynamic open override var zm_ID: String {
        get { zm_sectionID.zm_ID + (zm_isHeader ? "_header" : "_footer") }
        set { }
    }

    @objc open dynamic var zm_viewReuseIdentifier: String {
        return ""
    }

    @objc open dynamic var zm_viewHeight: CGFloat {
        CGFloat.leastNonzeroMagnitude
    }

    @objc open dynamic var zm_section: Int = 0

    @objc open dynamic var zm_isHeader: Bool = true

    @objc open dynamic var zm_sectionNumber: Int = 0

    @objc open dynamic var zm_rowNumberOfCurrentSection: Int = 0
    
    @objc open dynamic weak var zm_sectionData: ZMBaseTableViewSectionData?

    @objc open dynamic func zm_clearCache() {}

//    @objc open dynamic func zm_exposureView(viewEventTrackIDs: [String]) {}
//
//    @objc open dynamic var zm_viewEventTrackIDs: [String] {
//        return [zm_sectionID.zm_sectionIDStr]
//    }
}


// MARK: - ZMBaseTableViewSectionData

@objc open class ZMBaseTableViewSectionData: NSObject {
    
    open dynamic var zm_sectionID: any ZMBaseSectionUniqueIDProtocol = ""
    @objc dynamic open var cellDatas: [ZMBaseTableViewCellViewModel] = []
    @objc dynamic open var headerData: ZMBaseTableViewReuseViewModel?
    @objc dynamic open var footerData: ZMBaseTableViewReuseViewModel?
    
    public init(zm_sectionID: any ZMBaseSectionUniqueIDProtocol = "",
                cellDatas: [ZMBaseTableViewCellViewModel] = [],
                headerData:ZMBaseTableViewReuseViewModel? = nil,
                footerData:ZMBaseTableViewReuseViewModel? = nil) {
        super.init()
        self.zm_sectionID = zm_sectionID
        self.cellDatas = cellDatas
        self.headerData = headerData
        self.footerData = footerData
    }
    
    @objc dynamic open func zm_removeFromSuperViewModel() {
        cellDatas.forEach { $0.zm_removeFromSuperViewModel() }
        headerData?.zm_removeFromSuperViewModel()
        footerData?.zm_removeFromSuperViewModel()
    }
    
    @objc dynamic open func zm_addSuperViewModel(_ viewModel: any ZMBaseViewModelProtocol) {
        viewModel.zm_addSubViewModels(cellDatas)
        if let headerData { viewModel.zm_addSubViewModel(headerData) }
        if let footerData { viewModel.zm_addSubViewModel(footerData) }
    }
}
