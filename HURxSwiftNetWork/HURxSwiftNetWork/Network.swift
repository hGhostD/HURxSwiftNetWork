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


class Network {

    // sigleton
    static let `default`: Network = {
        return Network()
    }()

    let baseUrl = "https://api.douban.com/v2/movie/in_theaters"

    let apikey = "0b2bdeda43b5688921839c8ecb20399b"
    let city = "沈阳".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
    let client = ""
    let udid = ""


    func searchDouBan(start: String, count: String) -> Observable<[Model]> {
        return Observable.create({ (oberver: AnyObserver<[Model]>) -> Disposable in
            let parameter: [String: Any] = ["apikey":self.apikey,"city":self.city!,"client":self.client,"udid":self.udid,"start":start,"count":count]

            let request = Alamofire.request(self.baseUrl, method: .post, parameters: parameter, encoding: URLEncoding.default, headers: nil).responseJSON { (response) in

                switch response.result {
                case .failure(let error):
                    print(error)
                    oberver.onError(error)
                case .success(let json):
                    let modelArr = self.changeJsonToModel(json: JSON(json))
                    oberver.onNext(modelArr)
                    oberver.onCompleted()
                }
            }
            return Disposables.create {
                request.cancel()
            }
        })
    }
}

extension Network {
    fileprivate func changeJsonToModel(json: JSON) -> Array<Model> {
        let array: [Model] = json["subjects"].arrayValue.map {
            return Model($0)
        }
        return array
    }
}
