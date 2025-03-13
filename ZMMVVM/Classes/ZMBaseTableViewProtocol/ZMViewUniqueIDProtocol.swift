//
//  ZMViewUniqueIDProtocol.swift
//  ZMMVVM
//
//  Created by 朱猛 on 2024/10/24.
//

import Foundation

// MARK: - ZMBaseCellUniqueIDProtocol
public protocol ZMBaseCellUniqueIDProtocol {
    var zm_ID: String { get }
}

public extension ZMBaseCellUniqueIDProtocol where Self: Equatable {
    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.zm_ID == rhs.zm_ID
    }
}

// MARK: - ZMBaseSectionUniqueIDProtocol 标识
public protocol ZMBaseSectionUniqueIDProtocol  {
    var zm_ID: String { get }
}

public extension ZMBaseSectionUniqueIDProtocol where Self: Equatable {
    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.zm_ID == rhs.zm_ID
    }
}

//// MARK: - ZMBaseSectionUniqueIDProtocol + ZMBaseSectionUniqueIDProtocol 才标识一个View
//public extension (any ZMBaseSectionUniqueIDProtocol,any ZMBaseSectionUniqueIDProtocol): ZMBaseViewUniqueIDProtocol {
//    var zm_ID: String { $0.zm_ID + "_" + $1.zm_ID }
//}

// MARK: - String
extension String: ZMBaseCellUniqueIDProtocol,ZMBaseSectionUniqueIDProtocol, Equatable {
    public var zm_ID: String {
        return self
    }
}

