//
//  Model.swift
//  HURxSwiftNetWork
//
//  Created by 胡佳文 on 2017/7/24.
//  Copyright © 2017年 胡佳文. All rights reserved.
//

import UIKit
import SwiftyJSON

struct Model {
    let title: String
    let images: Dictionary<String,JSON>
    let genres: Array<JSON>

    static func initWithModel(json: JSON) -> Model {
        let title = json["title"].stringValue
        let images = json["images"].dictionaryValue
        let genres = json["genres"].arrayValue
        let model = Model(title: title, images: images, genres: genres)
        return model

    }
}
