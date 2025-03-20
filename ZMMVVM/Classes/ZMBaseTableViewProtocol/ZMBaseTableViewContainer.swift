//
//  ZMBaseTableViewController.swift
//
//  Created by admin on 9/12/24.
//

import Foundation
import UIKit

// MARK: - ZMBaseTableViewContainerProtocol
public protocol ZMBaseTableViewContainerProtocol: AnyObject {
    var tableViewProxy: ZMBaseTableViewProxy { get }
}

public extension ZMBaseTableViewContainerProtocol {
    var sectionDataArray: [ZMBaseTableViewSectionData] {
        get {
            tableViewProxy.sectionDataArray
        }
        set {
            tableViewProxy.sectionDataArray = newValue
        }
    }
    
    var tableView: UITableView  {
        tableViewProxy.tableView
    }
}

// MARK: - ZMBaseTableViewProxy
public class ZMBaseTableViewProxy: NSObject, UITableViewDelegate, UITableViewDataSource {

    public var sectionDataArray: [ZMBaseTableViewSectionData] = [] /// 数据源
    
    public var isEmpty: Bool {
        if sectionDataArray.isEmpty {
            return true
        } else if sectionDataArray.count == 1, sectionDataArray.first?.cellDatas.isEmpty ?? true {
            return true
        }
        return false 
    }
    
    public let style: UITableView.Style
    
    public lazy var tableView: UITableView = {
        
        let tableView = UITableView(frame: .zero, style: self.style)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .clear
        if #available(iOS 11, *) {
            tableView.estimatedRowHeight = UITableView.automaticDimension
            tableView.estimatedSectionFooterHeight = UITableView.automaticDimension
            tableView.estimatedSectionHeaderHeight = UITableView.automaticDimension
        } else {
            tableView.estimatedRowHeight = 44
            tableView.estimatedSectionFooterHeight = 44
            tableView.estimatedSectionHeaderHeight = 44
        }
        tableView.separatorStyle = .none
        tableView.rowHeight = UITableView.automaticDimension
        tableView.sectionHeaderHeight = CGFloat.leastNonzeroMagnitude
        tableView.sectionFooterHeight = CGFloat.leastNonzeroMagnitude
        let nRect = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 0.01)
        tableView.tableHeaderView = UIView(frame: nRect)
        tableView.tableFooterView = UIView(frame: nRect)
        tableView.keyboardDismissMode = .onDrag
        tableView.contentInsetAdjustmentBehavior = .automatic
        if #available(iOS 15.0, *) {
            tableView.sectionHeaderTopPadding = 0
        }
        return tableView
    }()
    
    
    public init(style: UITableView.Style) {
        self.style = style
        super.init()
    }
}


// MARK: -  UITableViewDelegate, UITableViewDataSource 默认实现
public extension ZMBaseTableViewProxy {

    // MARK: - UITableView
     func numberOfSections(in tableView: UITableView) -> Int {
         sectionDataArray.count
     }
     
     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
         sectionDataArray[section].cellDatas.count ?? 0
     }
     
     func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
         let sectionModel = sectionDataArray[indexPath.section]
         let cellModel = sectionModel.cellDatas[indexPath.row]
         return cellModel.zm_cellHeight
     }
     
     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
         let sectionModel = sectionDataArray[indexPath.section]
         let cellModel = sectionModel.cellDatas[indexPath.row]
         guard let cell = tableView.dequeueReusableCell(withIdentifier: cellModel.zm_cellReuseIdentifier) else {
             return UITableViewCell()
         }
         cellModel.zm_indexPath = indexPath
         cellModel.zm_sectionNumber = sectionDataArray.count
         cellModel.zm_rowNumberOfCurrentSection = sectionModel.cellDatas.count
         cellModel.zm_sectionData = sectionModel
         if let updatable = cell as? ZMBaseViewUpdatable {
             updatable.zm_fillWithData(data: cellModel)
         }
         return cell
     }
     
     func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
         let sectionModel = sectionDataArray[section]
         guard let headerModel = sectionModel.headerData else {
             return CGFloat.leastNonzeroMagnitude
         }
         return headerModel.zm_viewHeight
     }
     
     func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
         let sectionModel = sectionDataArray[section]
          guard let footerModel = sectionModel.footerData else {
             return CGFloat.leastNonzeroMagnitude
         }
         return footerModel.zm_viewHeight
     }
     
     func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
         let sectionModel = sectionDataArray[section]
         guard let headerModel = sectionModel.headerData,
                   let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: headerModel.zm_viewReuseIdentifier) else {
             return nil
         }
         headerModel.zm_isHeader = true
         headerModel.zm_section = section
         headerModel.zm_sectionNumber = sectionDataArray.count
         headerModel.zm_sectionData = sectionModel
         
         if let updatable = view as? ZMBaseViewUpdatable {
             updatable.zm_fillWithData(data: headerModel)
         }
         return view
     }
     
     func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
         let sectionModel = sectionDataArray[section]
         guard let footerModel = sectionModel.footerData,
               let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: footerModel.zm_viewReuseIdentifier) else {
             return nil
         }
         footerModel.zm_isHeader = false
         footerModel.zm_section = section
         footerModel.zm_sectionNumber = sectionDataArray.count
         footerModel.zm_sectionData = sectionModel
         
         if let updatable = view as? ZMBaseViewUpdatable {
             updatable.zm_fillWithData(data: footerModel)
         }
         return view
     }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let sectionModel = sectionDataArray[indexPath.section]
        let cellModel = sectionModel.cellDatas[indexPath.row]
        cellModel.zm_onCellSingleTap()
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let sectionModel = sectionDataArray[indexPath.section]
        let cellModel = sectionModel.cellDatas[indexPath.row]
        return cellModel.zm_cellSwipeActions
    }
}

// MARK: - 局部刷新安全方法 reload Cell / Section
public extension ZMBaseTableViewProxy {
    
    func reloadData() {
        tableView.reloadData()
    }
    
    /// 直接刷新cell（不调用reloadData 同时刷新高度）
    func batchReloadCellsDirectly(cellIDs: [(any ZMBaseSectionUniqueIDProtocol,
                                             any ZMBaseCellUniqueIDProtocol)],
                                  needReloadHeight: Bool = false,
                                  animated: Bool = false) {
       
        var indexPaths: [IndexPath] = []
        var cellDatas: [ZMBaseTableViewCellViewModel] = []
        let visiableIndexPaths = tableView.indexPathsForVisibleRows
        cellIDs.forEach { tmp in
            let (sectionType,rowId) = tmp
            if let (section,sectionData) = sectionDataArray.enumerated().first(where: {
                let (_, sectionData) = $0
                return sectionData.zm_sectionID.zm_ID == sectionType.zm_ID
            }), let (row, cellData) =  sectionData.cellDatas.enumerated().first(where: {
                let (_, cellData) = $0
                return cellData.zm_cellID.zm_ID == rowId.zm_ID
            }) {
                if tableView.numberOfSections > section,
                   tableView.numberOfRows(inSection: section) > row {
                    let indexPath = IndexPath(row: row, section: section)
                    indexPaths.append(IndexPath(row: row, section: section))
                    
                    if visiableIndexPaths?.contains(indexPath) ?? true {
                        cellDatas.append(cellData)
                    }
                }
            }
        }
        
        guard !indexPaths.isEmpty else { return }
        
        if needReloadHeight {
            if animated {
                tableView.performBatchUpdates {
                    cellDatas.forEach { $0.zm_reloadView()}
                }
            } else {
                UIView.performWithoutAnimation {
                    tableView.performBatchUpdates {
                        cellDatas.forEach { $0.zm_reloadView()}
                    }
                }
            }
        } else {
            cellDatas.forEach { $0.zm_reloadView()}
        }
        
    }
    
   
    /// 刷新cell
    func reloadCells(cellIDs: [(any ZMBaseSectionUniqueIDProtocol,
                                any ZMBaseCellUniqueIDProtocol)],
                     with animation: UITableView.RowAnimation = .none) {
        
        var indexPaths: [IndexPath] = []
        var cellDatas: [ZMBaseTableViewCellViewModel] = []
        let visiableIndexPaths = tableView.indexPathsForVisibleRows
        cellIDs.forEach { tmp in
            let (sectionType,rowId) = tmp
            if let (section,sectionData) = sectionDataArray.enumerated().first(where: {
                let (_, sectionData) = $0
                return sectionData.zm_sectionID.zm_ID == sectionType.zm_ID
            }), let (row, cellData) =  sectionData.cellDatas.enumerated().first(where: {
                let (_, cellData) = $0
                return cellData.zm_cellID.zm_ID == rowId.zm_ID
            }) {
                if tableView.numberOfSections > section,
                   tableView.numberOfRows(inSection: section) > row {
                    let indexPath = IndexPath(row: row, section: section)
                    indexPaths.append(IndexPath(row: row, section: section))
                    
                    if visiableIndexPaths?.contains(indexPath) ?? true {
                        cellDatas.append(cellData)
                    }
                }
            }
        }
        
        guard !indexPaths.isEmpty else { return }
        
        if animation == .none {
            UIView.performWithoutAnimation {
                self.tableView.reloadRows(at: indexPaths, with: .none)
            }
        } else {
            self.tableView.reloadRows(at: indexPaths, with: animation)
        }
        
    }
    
    /// 刷新section
    func reloadSections(sectionTypes: [any ZMBaseSectionUniqueIDProtocol],
                        with animation: UITableView.RowAnimation = .none) {
        
        let sections = sectionDataArray.enumerated().compactMap({ (index,data) in
            if sectionTypes.contains(where: { $0.zm_ID == data.zm_sectionID.zm_ID }),
               tableView.numberOfSections > index {
                return index
            } else {
                return nil
            }
        })
        
        guard !sections.isEmpty else { return }
        
        if animation == .none {
            UIView.performWithoutAnimation {
                self.tableView.reloadSections(IndexSet(sections), with: .none)
            }
        } else {
            self.tableView.reloadSections(IndexSet(sections), with: animation)
        }
    }
    
    /// 同时刷新section和cell
    func reloadSectionsAndCells(cellIDs: [(any ZMBaseSectionUniqueIDProtocol,
                                           any ZMBaseCellUniqueIDProtocol)],
                                sectionTypes: [any ZMBaseSectionUniqueIDProtocol],
                                with animation: UITableView.RowAnimation = .none) {
        
        var indexPaths: [IndexPath] = []
        cellIDs.forEach { tmp in
            let (sectionType,rowId) = tmp
            if let (section,sectionData) = sectionDataArray.enumerated().first(where: {
                let (_, sectionData) = $0
                return sectionData.zm_sectionID.zm_ID == sectionType.zm_ID
            }), let (row, cellData) =  sectionData.cellDatas.enumerated().first(where: {
                let (_, cellData) = $0
                return cellData.zm_cellID.zm_ID == rowId.zm_ID
            }) {
                if tableView.numberOfSections > section,
                   tableView.numberOfRows(inSection: section) > row {
                    let indexPath = IndexPath(row: row, section: section)
                    indexPaths.append(IndexPath(row: row, section: section))
                }
            }
        }
        
        let sections = sectionDataArray.enumerated().compactMap({ (index,data) in
            if sectionTypes.contains(where: { $0.zm_ID == data.zm_sectionID.zm_ID }),
               tableView.numberOfSections > index {
                return index
            } else {
                return nil
            }
        })
        
        guard !sections.isEmpty || !indexPaths.isEmpty else { return }
        
        self.tableView.performBatchUpdates {
            if animation == .none {
                UIView.performWithoutAnimation {
                    self.tableView.reloadSections(IndexSet(sections), with: .none) // swiftlint:disable:this Du_Forbid_TableView_ReloadRows_Rule
                    self.tableView.reloadRows(at: indexPaths, with: .none) // swiftlint:disable:this Du_Forbid_TableView_ReloadRows_Rule
                }
            } else {
                self.tableView.reloadSections(IndexSet(sections), with: animation) // swiftlint:disable:this Du_Forbid_TableView_ReloadRows_Rule
                self.tableView.reloadRows(at: indexPaths, with: animation) // swiftlint:disable:this Du_Forbid_TableView_ReloadRows_Rule
            }
        }
    }
    
    /// 刷新Data
    func reloadTableViewData(cellIds: [(any ZMBaseSectionUniqueIDProtocol,
                                        any ZMBaseCellUniqueIDProtocol)] = [],
                             diffeSectionTypes: [any ZMBaseSectionUniqueIDProtocol] = [] ,
                             sectionTypes: [any ZMBaseSectionUniqueIDProtocol] = [],
                             animated: Bool = false) {
    
        var cellIDArrayForReload = cellIds
        var diffSectionIDArrayForReload = diffeSectionTypes
        var sectionIDArrayForReload = sectionTypes
        var animatedForReload = animated
        
        if tableView.numberOfSections != sectionDataArray.count {
            tableView.reloadData()
            return
        }
        
        diffSectionIDArrayForReload.removeAll { sectionId in
            sectionIDArrayForReload.contains(where: { $0.zm_ID == sectionId.zm_ID })
        }
        
        var updateIndexPaths: Set<IndexPath> = []
        var deleteIndexPaths: Set<IndexPath> = []
        var insertIndexPaths: Set<IndexPath> = []
        var updateSections: Set<Int> = []
       
        cellIDArrayForReload.forEach { tmp in
            let (sectionType,rowId) = tmp
            if let (section,sectionData) = sectionDataArray.enumerated().first(where: {
                let (_, sectionData) = $0
                return sectionData.zm_sectionID.zm_ID == sectionType.zm_ID
            }), let (row, cellData) =  sectionData.cellDatas.enumerated().first(where: {
                let (_, cellData) = $0
                return cellData.zm_cellID.zm_ID == rowId.zm_ID
            }) {
                if tableView.numberOfSections > section,
                   tableView.numberOfRows(inSection: section) > row {
                    let indexPath = IndexPath(row: row, section: section)
                    updateIndexPaths.insert(indexPath)
                }
            }
        }
        
        sectionDataArray.enumerated().forEach { (sectionIndex,data) in
            
            if sectionIDArrayForReload.contains(where: { $0.zm_ID == data.zm_sectionID.zm_ID }),
               tableView.numberOfSections > sectionIndex {  /// section 直接刷新
                updateSections.insert(sectionIndex)
            } else if diffSectionIDArrayForReload.contains(where: { $0.zm_ID == data.zm_sectionID.zm_ID }),
                      tableView.numberOfSections > sectionIndex { /// section 需要diff
                let numOfRowInSection = tableView.numberOfRows(inSection: sectionIndex)
                let realCellDataCount = data.cellDatas.count
                var maxNum = max(numOfRowInSection, realCellDataCount)
                for rowIndex in 0..<maxNum {
                    if rowIndex < numOfRowInSection && rowIndex < realCellDataCount {
                        updateIndexPaths.insert(IndexPath(row: rowIndex, section: sectionIndex))
                    } else if rowIndex < realCellDataCount {
                        insertIndexPaths.insert(IndexPath(row: rowIndex, section: sectionIndex))
                    } else if rowIndex < numOfRowInSection {
                        deleteIndexPaths.insert(IndexPath(row: rowIndex, section: sectionIndex))
                    }
                }
            }
        }
        
   
        guard !updateIndexPaths.isEmpty ||
                !deleteIndexPaths.isEmpty ||
                !insertIndexPaths.isEmpty ||
                !updateSections.isEmpty else { return }

        if animatedForReload {
            self.tableView.performBatchUpdates {
                self.tableView.deleteRows(at: Array(deleteIndexPaths), with: .fade) // swiftlint:disable:this Du_Forbid_TableView_ReloadRows_Rule
                self.tableView.insertRows(at: Array(insertIndexPaths), with: .fade) // swiftlint:disable:this Du_Forbid_TableView_ReloadRows_Rule
                self.tableView.reloadRows(at: Array(updateIndexPaths), with: .none) // swiftlint:disable:this Du_Forbid_TableView_ReloadRows_Rule
                self.tableView.reloadSections(IndexSet(updateSections), with: .none) // swiftlint:disable:this Du_Forbid_TableView_ReloadRows_Rule
            }
        } else {
            UIView.performWithoutAnimation {
                self.tableView.performBatchUpdates {
                    self.tableView.deleteRows(at: Array(deleteIndexPaths), with: .none) // swiftlint:disable:this Du_Forbid_TableView_ReloadRows_Rule
                    self.tableView.insertRows(at: Array(insertIndexPaths), with: .none) // swiftlint:disable:this Du_Forbid_TableView_ReloadRows_Rule
                    self.tableView.reloadRows(at: Array(updateIndexPaths), with: .none) // swiftlint:disable:this Du_Forbid_TableView_ReloadRows_Rule
                    self.tableView.reloadSections(IndexSet(updateSections), with: .none) // swiftlint:disable:this Du_Forbid_TableView_ReloadRows_Rule
                }
            }
        }
    }
    
}

// MARK: - cell Event Track
//extension ZMBaseTableViewContainerProtocol {
    //
    //    struct DuTBaseEventTrackIndex: Equatable {
    //        let sectionIDStr: String
    //        let cellEventTrackIDStr: String
    //    }
    //
    //    @objc dynamic open func trackCellExposure() {
    //
    //        CT().exposureEvent(headerRefresh: self.headerRefresh.asObservable(),
    //                           willEndScroll: Observable.of(self.tableView.rx.willEndScroll, self.someDataChange.asObservable()).merge(),
    //                           didAppear: self.didAppear.asObservable(),
    //                           didDisappear: self.didDisappear.asObservable()) { [weak self] () -> ([DuTBaseEventTrackIndex]?) in
    //
    //            guard let self = self else { return nil }
    //
    //            var ids: [DuTBaseEventTrackIndex] = []
    //            if let indexPaths = self.tableView.indexPathsForVisibleRows {
    //                for indexPath in indexPaths {
    //                    if let sectionData = self.sectionDataArray[safe: indexPath.section],
    //                       let cellData = sectionData.cellDatas[safe: indexPath.row] {
    //                        let eventTrackIndexArray = cellData.dut_cellEventTrackIDs.map {
    //                            DuTBaseEventTrackIndex(sectionIDStr: sectionData.dut_sectionID.dut_sectionIDStr,
    //                                                   cellEventTrackIDStr: $0)
    //                        }
    //                        ids.append(contentsOf: eventTrackIndexArray)
    //                    }
    //                }
    //            }
    //            return ids
    //        }.subscribe(onNext: { [weak self] ids in
    //            guard let self, !ids.isEmpty else { return }
    //            var cellEventTrackIDsGroupBySection: [String:[String]] = [:]
    //            ids.forEach { model in
    //                var cellEventTrackIDs: [String] = []
    //                if var originalCellEventTrackIDs = cellEventTrackIDsGroupBySection[model.sectionIDStr] {
    //                    cellEventTrackIDs = originalCellEventTrackIDs
    //                }
    //                cellEventTrackIDs.append(model.cellEventTrackIDStr)
    //                cellEventTrackIDsGroupBySection[model.sectionIDStr] = cellEventTrackIDs
    //            }
    //
    //            for sectionData in self.sectionDataArray {
    //                guard let cellEventTrackIDs = cellEventTrackIDsGroupBySection[sectionData.dut_sectionID.dut_sectionIDStr],
    //                      !cellEventTrackIDs.isEmpty else {
    //                    continue
    //                }
    //                for cellData in sectionData.cellDatas {
    //                    cellData.dut_exposureCell(cellEventTrackIDs: cellEventTrackIDs)
    //                }
    //            }
    //        }).disposed(by: self.disposeBag)
    //    }
//}




