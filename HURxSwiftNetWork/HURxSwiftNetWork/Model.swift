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

    init(_ json: JSON) {
        self.title = json["title"].stringValue
        self.images = json["images"].dictionaryValue
        self.genres = json["genres"].arrayValue
    }
}

