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
import RxDataSources

class ViewController: UIViewController {

    var dataArray = Variable<[Int]>([])

    let bag = DisposeBag.init()
    let tableView = UITableView(frame: CGRect(x: 0, y: 20, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height - 20), style: .plain)

    override func viewDidLoad() {
        super.viewDidLoad()


        view.addSubview(tableView)
        setupRx()
        
        tableView.register(TableViewCell.self, forCellReuseIdentifier: "Cell")

        //使用数据初始化cell
//        let items = Observable.just(
//            (0...20).map{ "\($0)" }
//        )
//        items
//            .bind(to: tableView.rx.items(cellIdentifier: "Cell", cellType: UITableViewCell.self)){
//                (row, elememt, cell) in
//                cell.textLabel?.text = "\(elememt) @row \(row)"
//            }.disposed(by: bag)
    }

    func setupRx () {

        for i in 0...40 {
            dataArray.value.append(i)
        }

        let setCell = {(i: Int,e : Int,c: TableViewCell) in
            c.title.text = String(e)
        }

//        dataArray.asObservable().bind(to: self.tableView.rx.items(cellIdentifier: "Cell", cellType: TableViewCell.self))(setCell).addDisposableTo(bag)

//        dataArray.asObservable().bind(to: self.tableView.rx.items(cellIdentifier: "Cell", cellType: TableViewCell.self), curriedArgument: setCell).addDisposableTo(bag)

    }

    func displayErrorAlert(error: Error) {
        let alert = UIAlertController(title: "网络错误", message: error.localizedDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}

