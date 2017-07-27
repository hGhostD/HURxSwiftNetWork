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

//    var dataArray = Variable<[]>

    let bag = DisposeBag.init()
    let textField = UITextField()
    let tableView = UITableView(frame: CGRect(x: 0, y: 60, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height - 60), style: .plain)
    let dataSource = RxTableViewSectionedReloadDataSource<SectionModel<String,Model>>()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        textField.frame = CGRect(x: 20, y: 20, width: self.view.frame.size.width - 40, height: 40)
        textField.layer.borderColor = UIColor.gray.cgColor
        textField.layer.borderWidth = 1
        self.view.addSubview(textField)

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
        typealias O = Observable<[Model]>
        typealias CC = (Int,Model,TableViewCell) -> Void

//        let binder : (O) -> (CC) -> (Void) -> Disposable = self.tableView.rx.items(cellIdentifier: "cell", cellType: TableViewCell())

        textField.rx.text.filter{
                ($0?.characters.count)! > 4
            }.throttle(1, scheduler: MainScheduler.instance)
            .flatMap {
                Network.default.searchForGithub(name: $0!)
            }.subscribe(onNext:{
                self.tableView.dataSource = nil
                let model = $0

                print(model)

                Observable.just($0).bind(to: self.tableView.rx.items(cellIdentifier: "Cell", cellType: TableViewCell.self)){
                    (row, elememt, cell: TableViewCell) in
                    cell.title.text = elememt.full_name
                    cell.detail.text = elememt.description
                    }.disposed(by: self.bag)
                

            },onError:{
                self.displayErrorAlert(error: $0)
        }).addDisposableTo(self.bag)
        

    }

    func displayErrorAlert(error: Error) {
        let alert = UIAlertController(title: "网络错误", message: error.localizedDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}

