//
//  Network.swift
//  HURxSwiftNetWork
//
//  Created by 胡佳文 on 2017/7/18.
//  Copyright © 2017年 胡佳文. All rights reserved.
//

import UIKit
import RxSwift
import Alamofire
import SwiftyJSON
import RxAlamofire

extension String {
    /// 国际化
    /// refer: https://medium.com/@dcordero/a-different-way-to-deal-with-localized-strings-in-swift-3ea0da4cd143#.zemh2p2u3
    var localized: String {
        //🖕Fuck the translators team, they don’t deserve comments
        return NSLocalizedString(self, comment: "")
    }
}

enum ErrorCode: Int {
    case `default` = -11110
    case json = -11111
    case parameter = -11112
}

enum ErrorMessage: String {
    case `default` = "网络状态不佳，请稍候再试!"
    case json = "服务器数据解析错误!"
    case parameter = "参数错误，请稍候再试!"
}

extension NSError {
    class func network(reason: String, code: Int) -> NSError {
        let userInfo = [NSLocalizedDescriptionKey: reason.localized,
                        NSLocalizedFailureReasonErrorKey: reason.localized]
        return NSError(domain: "com.tlive.networkerror", code: code, userInfo: userInfo)
    }
}

extension Observable {
    /// 创建参数类型错误的Observable
    ///
    /// - Returns: Observable<E>
    class func parameterError() -> Observable<E> {
        return Observable.create { (observer) -> Disposable in
            observer.onError(NSError.network(reason: ErrorMessage.parameter.rawValue, code: ErrorCode.parameter.rawValue))
            return Disposables.create()
        }
    }
}

class Network {

    // sigleton
    static let `default`: Network = {
        return Network()
    }()

    // domain
    let baseUrl = "https://api.tuchong.com"

    // For JSON
    static let ok = "SUCCESS"
    static let statusKey = "result"
    static let messageKey = "message"
    static let dataKey = "data"


    func commonParameters(parameters: [String: Any]?) -> [String: Any] {
        var newParameters: [String: Any] = [:]
        if parameters != nil {
            newParameters = parameters!
        }
        newParameters["os_api"] = "22"
        newParameters["device_type"] = "android"
        newParameters["os_version"] = "5.8.1"
        newParameters["ssmix"] = "a"
        newParameters["manifest_version_code"] = "232"
        newParameters["dpi"] = "400"
        newParameters["abflag"] = "0"
        newParameters["openudid"] = "65143269dafd1f3a5"
        newParameters["app_name"] = "tuchong"
        newParameters["uuid"] = "651384659521356"

        return newParameters
    }

    /// 统一的API请求入口
    func rx_json(_ method: Alamofire.HTTPMethod,
                 _ url: URLConvertible,
                 parameters: [String: Any]? = nil,
                 encoding: ParameterEncoding = URLEncoding.default,
                 headers: [String: String]? = nil)
        -> Observable<JSON> {

            return string(
                method,
                url,
                parameters: commonParameters(parameters: parameters),
                encoding: encoding,
                headers: headers
                )
                .common()
    }
}

/// Swift暂时不支持直接限制Element的类型，通过这种方式绕过
/// 参考：http://www.marisibrothers.com/2016/03/extending-swift-generic-types.html

protocol StringProtocol {}
extension String : StringProtocol {}

extension Observable where Element: StringProtocol {
    func common() -> Observable<JSON> {
        return self
            .catchError({ (error) -> Observable<Element> in
                /// 统一的错误处理逻辑
                /// 1. http://stackoverflow.com/questions/36059483/what-is-the-analog-of-rxjava-onerrorresumenext-operator-in-rxswift
                /// 2. http://reactivex.io/documentation/operators/catch.html
                return Observable<Element>.create({ (observer) -> Disposable in
                    observer.on(.error(NSError.network(reason: ErrorMessage.default.rawValue, code: ErrorCode.default.rawValue)))
                    return Disposables.create()
                })
            })
            .flatMap { (element) -> Observable<JSON> in
                let string = element as! String
                // 参考RxJava的compose()方法，但是在iOS中，我们可以直接基于Swift构建扩展或者类似现在的实现
                // http://blog.danlew.net/2015/03/02/dont-break-the-chain/
                return Observable<JSON>.create({ (observer) -> Disposable in
                    let json = JSON.parse(string)
                    if let code = json[Network.statusKey].string, code == Network.ok {
                        observer.on(.next(json))
                        observer.on(.completed)
                    } else {
                        var reason = ErrorMessage.default.rawValue
                        if let message = json[Network.messageKey].string {
                            reason = message
                        }
                        observer.on(.error(NSError.network(reason: reason, code: ErrorCode.default.rawValue)))
                    }
                    return Disposables.create()
                })
            }
            .observeOn(MainScheduler.instance)
    }
}

protocol JSONProtocol {}
extension JSON: JSONProtocol{}

extension Observable where Element: JSONProtocol {
    /// 如果返回数据是列表信息，使用这个方法解析列表数据并模型化为数据数组
//    typealias ListType<T> = ([T], Bool)
//    func list<T: BaseMappable>(dataKey: String = "data", callback: ((T) -> Void)? = nil) -> Observable<ListType<T>> {
//        return self.flatMap{ (element) -> Observable<ListType<T>> in
//            let json = element as! JSON
//            return Observable<ListType<T>>.create { (observer) -> Disposable in
//                if let data = json[dataKey].arrayObject, let array = Mapper<T>().mapArray(JSONObject: data), let hasMore = json["more"].bool {
//                    observer.on(.next((array, hasMore)))
//                    observer.on(.completed)
//                } else {
//                    observer.on(.error(NSError.network(reason: ErrorMessage.json.rawValue, code: ErrorCode.json.rawValue)))
//                }
//                return Disposables.create()
//            }
//        }
//    }
//
//    /// 如果服务器返回的数据中，data包含的是某个具体的数据对象，使用这个方法模型化
//    func data<T: BaseMappable>(callback: ((T) -> Void)? = nil) -> Observable<T> {
//        return self.flatMap { (element) -> Observable<T> in
//            let json = element as! JSON
//            return Observable<T>.create { (observer) -> Disposable in
//                if let data = json[Network.dataKey].dictionaryObject, let object = Mapper<T>().map(JSON: data) {
//                    if let callback = callback {
//                        callback(object)
//                    }
//                    observer.on(.next(object))
//                    observer.on(.completed)
//                } else {
//                    observer.on(.error(NSError.network(reason: ErrorMessage.json.rawValue, code: ErrorCode.json.rawValue)))
//                }
//                return Disposables.create()
//            }
//        }
//    }
//
//    /// 针对只处理状态码的返回数据，使用这个bool()方法处理，返回的bool值只有true，其他情况都是失败
//    func bool(callback: (() -> Void)? = nil) -> Observable<Bool> {
//        return self.flatMap { (element) -> Observable<Bool> in
//            return Observable<Bool>.create { (observer) -> Disposable in
//                if let callback = callback {
//                    callback()
//                }
//                observer.on(.next(true))
//                observer.on(.completed)
//                return Disposables.create()
//            }
//        }
//    }
}
