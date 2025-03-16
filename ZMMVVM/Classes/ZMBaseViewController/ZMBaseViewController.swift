//
//  ZMViewController.swift
//  ZMMVVM
//
//  Created by 朱猛 on 2024/10/24.
//

import Foundation
import UIKit

open class ZMBaseViewController: UIViewController {
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        zm_viewWillAppear()
    }
    
    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        zm_viewDidAppear()
    }
    
    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        zm_viewWillDisappear()
    }
    
    open override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        zm_viewDidDisappear()
    }
    
    open override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        zm_didReceiveMemoryWarning()
    }
}
