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
import MJRefresh

class ViewController: UIViewController {

    var dataArray = Variable<[Int]>([])

    let bag = DisposeBag.init()
    let tableView = UITableView(frame: CGRect(x: 0, y: 20, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height - 20), style: .plain)

    typealias SectionTableModel = SectionModel<String,Model>
    let dataSource = RxTableViewSectionedReloadDataSource<SectionTableModel>()
    // 顶部刷新
    let header = MJRefreshNormalHeader()
    // 底部刷新
    let footer = MJRefreshAutoNormalFooter()
    override func viewDidLoad() {
        super.viewDidLoad()


        view.addSubview(tableView)
        setupRx()
        
        tableView.register(TableViewCell.self, forCellReuseIdentifier: "Cell")
        upRefresh()
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

        let setCell = {(i: Int,e : Int,c: TableViewCell) in
            c.title.text = String(e)
        }

        dataArray.asObservable().bind(to: self.tableView.rx.items(cellIdentifier: "Cell", cellType: TableViewCell.self))(setCell).addDisposableTo(bag)

        header.setRefreshingTarget(self, refreshingAction: #selector(upRefresh))
        footer.setRefreshingTarget(self, refreshingAction: #selector(downRefresh))
        self.tableView.mj_header = header
        self.tableView.mj_footer = footer
        
    }

    func upRefresh() {
        dataArray.value.removeAll()
        for i in 0...10 {
            dataArray.value.append(i)
        }
        self.tableView.mj_header.endRefreshing()
    }

    func downRefresh() {
        for i in dataArray.value.last!..<dataArray.value.last! + 10 {
            dataArray.value.append(i)
        }
        self.tableView.mj_footer.endRefreshing()
    }

    func displayErrorAlert(error: Error) {
        let alert = UIAlertController(title: "网络错误", message: error.localizedDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}

