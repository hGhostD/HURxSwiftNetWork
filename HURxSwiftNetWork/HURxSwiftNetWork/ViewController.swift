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

//    var dataArray = Variable<[]>

    let bag = DisposeBag.init()
    let textField = UITextField()
    let tableView = UITableView(frame: CGRect(x: 0, y: 60, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height - 60), style: .plain)
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view, typically from a nib.
        textField.frame = CGRect(x: 20, y: 20, width: self.view.frame.size.width - 40, height: 40)
        textField.layer.borderColor = UIColor.gray.cgColor
        textField.layer.borderWidth = 1
        self.view.addSubview(textField)

        tableView.register(TableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.delegate = self
        tableView.dataSource = self
        self.view.addSubview(tableView)
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
            },onError:{
                print($0)
        }).addDisposableTo(self.bag)
    }
}

