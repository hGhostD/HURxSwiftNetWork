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

class ViewController: UIViewController, UITableViewDelegate{

    var dataArray = Variable<[SectionModel<String, Model>]>([])
//    var data = Variable<[Model]>([])
    var page = 0
    let bag = DisposeBag()
    let tableView = UITableView(frame: CGRect(x: 0, y: 20, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height - 20), style: .plain)
    
    let dataSource = RxTableViewSectionedReloadDataSource<SectionModel<String, Model>>(configureCell:{ (source, tableview, index, model) -> UITableViewCell in
        let cell = tableview.dequeueReusableCell(withIdentifier: "Cell", for: index) as! TableViewCell
        cell.setupWithModel(model)
        return cell
    })
    let setCell = {(i: Int,e : Model,c: TableViewCell) in
        c.setupWithModel(e)
    }
    // 顶部刷新
    let header = MJRefreshNormalHeader()
    // 底部刷新
    let footer = MJRefreshAutoNormalFooter()
    override func viewDidLoad() {
        super.viewDidLoad()
    
        view.addSubview(tableView)
        tableView.rowHeight = 60
        tableView.register(TableViewCell.self, forCellReuseIdentifier: "Cell")
        // 注意: 委托代理一定要在绑定数据前执行，否则会造成崩溃！
        tableView.rx.setDelegate(self).disposed(by: bag)
        setupRx()

        upRefresh()
    }

    func setupRx () {

        dataSource.titleForHeaderInSection = { ds, ind in
            return ds.sectionModels[ind].items[0].title
        }
        
        dataArray.asObservable().bind(to: self.tableView.rx.items(dataSource: dataSource)).disposed(by: bag)
        
        tableView.rxDidSelectRowAtIndexPath.subscribe(onNext: { a, b in
            print(b)
        }).disposed(by: bag)

        header.setRefreshingTarget(self, refreshingAction: #selector(upRefresh))
        footer.setRefreshingTarget(self, refreshingAction: #selector(downRefresh))
        self.tableView.mj_header = header
        self.tableView.mj_footer = footer
    }

    @objc func upRefresh() {
        dataArray.value.removeAll()
        page = 1
        Network.default.searchDouBan(start: String(page), count: "10").subscribe(onNext:{
            self.tableView.mj_header.endRefreshing()

            let sec = SectionModel(model: "header", items: $0)
            self.dataArray.value.append(sec)
            
        }).disposed(by: bag)
    }

    @objc func downRefresh() {
        page += 1
        Network.default.searchDouBan(start: String(page), count: "10").subscribe(onNext:{
            self.tableView.mj_footer.endRefreshing()

            let sec = SectionModel(model: "header", items: $0)
            self.dataArray.value.append(sec)
            
        }).disposed(by: bag)
    }
}
