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

class MyDelegateProxy: DelegateProxy<UITableView, UITableViewDelegate> ,UITableViewDelegate ,DelegateProxyType {
    
    public weak private(set) var tableView: UITableView?
    
    public init(tableView: ParentObject) {
        self.tableView = tableView
        super.init(parentObject: tableView, delegateProxy: MyDelegateProxy.self)
    }
    //  如果没有实现这个方法 下面两个方法也不会实现 就会报错！参考了 Rx 中的实现方式实现的
    static func registerKnownImplementations() {
        self.register { MyDelegateProxy(tableView: $0) }
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
    // RxSwift 中对 Selector 绑定的方法已经修改 这里需要使用 methodInvoked 方法实现。
    var rxDidSelectRowAtIndexPath: Observable<(UITableView, IndexPath)> {
        return rxDelegate.methodInvoked(.didSelectRowAtIndexPath).map { a in
            print(a)
            return (a[0] as! UITableView, a[1] as! IndexPath)
        }
    }
}

extension ViewController {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // 视频中说 会先走 Proxy 中的方法，但是实践的时候我发现情况相反。先走原生代理方法，然后再执行 Proxy 中的订阅方法。
        print("\(indexPath)+++====")
    }
}
