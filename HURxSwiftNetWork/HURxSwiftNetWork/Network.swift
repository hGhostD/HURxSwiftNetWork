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

typealias infoType = Dictionary<String,Any>

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


class Network {

    // sigleton
    static let `default`: Network = {
        return Network()
    }()

    // domain
    let baseUrl = "https://api.tuchong.com/feed-app"

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

    func searchForGithub (name: String) -> Observable<infoType> {
        return Observable.create({ (observer: AnyObserver<infoType>) -> Disposable in
            let url = "https://api.github.com/search/repositories"
            let paramaters = [
                "q": name + " starts:>2000"
            ]

            let request = Alamofire.request(url, method: .get, parameters: paramaters, encoding: URLEncoding.queryString, headers: nil)
            .responseJSON{ (response) in
                switch response.result {
                case .success(let json):
                    observer.onNext(self.parseResponse(response: json))
                    observer.onCompleted()
                case .failure(let error):
                    observer.onError(error)
                }
            }
            return Disposables.create {
                request.cancel()
            }
        })
    }
    
}

extension Network {
    fileprivate func parseResponse(response: Any) -> infoType {
        let json = JSON(response)
        let totalCount = json["total_count"].intValue

        var ret : infoType = [
            "total_count" : totalCount ,
            "items" : []
        ]

        if totalCount != 0 {
            let items = json["items"]
            var info : [infoType] = []

            for (_,subJson) :(String,JSON) in items {
                let fullName = subJson["full_name"].stringValue
                let description = subJson["description"].stringValue

                info.append([
                    "full_name" : fullName,
                    "description" : description
                ])
            }

            ret["items"] = info
        }
        return ret
    }
}
