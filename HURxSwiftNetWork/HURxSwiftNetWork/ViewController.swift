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

    var dataArray = Variable<[Model]>([])

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

        tableView.rowHeight = 60
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

        let setCell = {(i: Int,e : Model,c: TableViewCell) in
            c.title.text = e.title
            c.detail.text = e.genres.first?.stringValue
            let url = e.images["large"]?.stringValue
            let data = try? Data.init(contentsOf: URL(string: url!)!)
            c.headerImage.image = UIImage(data: data!)
        }

        dataArray.asObservable().bind(to: self.tableView.rx.items(cellIdentifier: "Cell", cellType: TableViewCell.self))(setCell).addDisposableTo(bag)

        header.setRefreshingTarget(self, refreshingAction: #selector(upRefresh))
        footer.setRefreshingTarget(self, refreshingAction: #selector(downRefresh))
        self.tableView.mj_header = header
        self.tableView.mj_footer = footer
        
    }

    func upRefresh() {

        self.tableView.mj_header.endRefreshing()
        Network.default.searchDouBan(start: "0", count: "20").subscribe(onNext:{
            self.dataArray.value.removeAll()

            _ = $0.map { model in
                self.dataArray.value.append(model)
            }
        }).addDisposableTo(bag)
    }

    func downRefresh() {

        self.tableView.mj_footer.endRefreshing()
        Network.default.searchDouBan(start: "1", count: "20").subscribe(onNext:{
            print($0)
            _ = $0.map { model in
                self.dataArray.value.append(model)
            }
        }).addDisposableTo(bag)
    }

}

