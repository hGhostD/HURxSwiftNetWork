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
    var page = 0
    let bag = DisposeBag()
    let tableView = UITableView(frame: CGRect(x: 0, y: 20, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height - 20), style: .plain)
    let setCell = {(i: Int,e : Model,c: TableViewCell) in
        c.title.text = e.title
        c.detail.text = e.genres.first?.stringValue
        let url = e.images["small"]?.stringValue
        let data = try? Data(contentsOf: URL(string: url!)!)
        c.headerImage.image = UIImage(data: data!)
    }
    typealias SectionTableModel = SectionModel<String,Model>
//    let dataSource = RxTableViewSectionedReloadDataSource<SectionTableModel>(configureCell:configureCell: )
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
    }

    func setupRx () {

        dataArray.asObservable().bind(to: self.tableView.rx.items(cellIdentifier: "Cell", cellType: TableViewCell.self))(setCell).disposed(by: bag)
        
        header.setRefreshingTarget(self, refreshingAction: #selector(upRefresh))
        footer.setRefreshingTarget(self, refreshingAction: #selector(downRefresh))
        self.tableView.mj_header = header
        self.tableView.mj_footer = footer
        
        tableView.rx.itemSelected.subscribe(onNext: {
            self.tableView.cellForRow(at: $0)?.isSelected = false
            print("点击",$0)
        }).disposed(by: bag)
    }

    @objc func upRefresh() {
        dataArray.value.removeAll()
        page = 1
        Network.default.searchDouBan(start: String(page), count: "10").subscribe(onNext:{
            self.tableView.mj_header.endRefreshing()

            _ = $0.map { model in
                self.dataArray.value.append(model)
            }
        }).disposed(by: bag)
    }

    @objc func downRefresh() {
        page += 1
        Network.default.searchDouBan(start: String(page), count: "10").subscribe(onNext:{
            self.tableView.mj_footer.endRefreshing()

            _ = $0.map { model in
                self.dataArray.value.append(model)
            }
        }).disposed(by: bag)
    }
}
