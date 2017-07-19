//
//  ViewController.swift
//  HURxSwiftNetWork
//
//  Created by 胡佳文 on 2017/7/18.
//  Copyright © 2017年 胡佳文. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

class ViewController: UIViewController {


    let button = UIButton(type: .custom)
    let bag = DisposeBag.init()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        button.backgroundColor = UIColor.blue
        button.bounds = CGRect(x: 0, y: 0, width: 120, height: 80)
        button.center = self.view.center
        self.view.addSubview(button)

        setupRx()
    }

    func setupRx() {
        button.rx.tap.subscribe(onNext:{

            Network.default.rx_json(.get, Network.default.baseUrl).subscribe({ (json) in
                print(json)
            }).addDisposableTo(self.bag)
        }).addDisposableTo(self.bag)
    }

}

