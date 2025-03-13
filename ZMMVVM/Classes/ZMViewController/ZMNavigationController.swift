//
//  ZMViewController.swift
//  ZMMVVM
//
//  Created by 朱猛 on 2024/10/24.
//

import Foundation
import UIKit

class ZMNavigationController: UINavigationController {
  
    /**
     * 当不使用系统的返回按钮，右滑手势interactivePopGestureRecognizer将会失效
     * 这里创建UIScreenEdgePanGestureRecognizer 实现右滑 target 和 delegate 均为interactivePopGestureRecognizer.delegate
     **/
    lazy var zmInteractivePopGestureRecognizer: UIScreenEdgePanGestureRecognizer = {
        let recognizer = UIScreenEdgePanGestureRecognizer(target: self, 
                                                          action: NSSelectorFromString("handleNavigationTransition:"))
        recognizer.edges = .left
        recognizer.delegate = self
        self.view.addGestureRecognizer(recognizer)
        self.interactivePopGestureRecognizer?.isEnabled = false
        return recognizer
    }()

    public var forbidGestureBack: Bool = false
}

extension ZMNavigationController: UIGestureRecognizerDelegate {
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if(self.forbidGestureBack){
            return false
        }
        return self.children.count == 1 ? false : true;
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true 
    }
}

