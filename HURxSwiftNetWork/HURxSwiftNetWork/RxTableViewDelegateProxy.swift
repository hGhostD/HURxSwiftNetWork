//
//  RxTableViewDelegateProxy.swift
//  HURxSwiftNetWork
//
//  Created by hu on 2018/1/25.
//  Copyright © 2018年 胡佳文. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class MyDelegateProxy: DelegateProxy<UITableView, UITableViewDelegate>, UITableViewDelegate, DelegateProxyType {
    static func registerKnownImplementations() {
        
    }
    
    static func setCurrentDelegate(_ delegate: UITableViewDelegate?, to object: UITableView) {
        object.delegate = delegate
    }
    
    static func currentDelegate(for object: UITableView) -> UITableViewDelegate? {
        return object.delegate
    }
}

private extension Selector {
    static let didSelectRowAtIndexPath = #selector(UITableViewDelegate.tableView(_:didSelectRowAt:))
}

extension UITableView {
    var rxDelegate: MyDelegateProxy {
        return MyDelegateProxy.proxy(for: self)
    }
    
    var rxDidSelectRowAtIndexPath: Observable<(UITableView, IndexPath)> {
        
        let r = rxDelegate.observe(#selector(UITableViewDelegate.tableView(_:didSelectRowAt:)), changeHandler: <#(MyDelegateProxy, NSKeyValueObservedChange<Value>) -> Void#>)

        
    }
}
