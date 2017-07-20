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

    let bag = DisposeBag.init()
    let textField = UITextField()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view, typically from a nib.
        textField.frame = CGRect(x: 20, y: 20, width: self.view.frame.size.width - 40, height: 40)
        textField.layer.borderColor = UIColor.gray.cgColor
        textField.layer.borderWidth = 1
        self.view.addSubview(textField)

        setupRx()
    }

    func setupRx () {
        textField.rx.text.filter{
                ($0?.characters.count)! > 4
            }.throttle(1, scheduler: MainScheduler.instance)
            .flatMap {
                Network.default.searchForGithub(name: $0!)
            }.subscribe(onNext:{
                let count = $0["total_count"]
                let item = $0["item"]
               
        }).addDisposableTo(self.bag)
    }
}

