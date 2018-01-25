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

    var dataArray = Variable<[SectionModel<String, Model>]>([])
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

//        dataArray.asObservable().bind(to: self.tableView.rx.items(cellIdentifier: "Cell", cellType: TableViewCell.self))(setCell).disposed(by: bag)
//        let closer = tableView.rx.items(dataSource: dataSource)
        dataSource.titleForHeaderInSection = { ds, ii in
            return ds.sectionModels[ii].model
        }
        dataArray.asObservable().bind(to: self.tableView.rx.items(dataSource: dataSource)).disposed(by: bag)
        
        header.setRefreshingTarget(self, refreshingAction: #selector(upRefresh))
        footer.setRefreshingTarget(self, refreshingAction: #selector(downRefresh))
        self.tableView.mj_header = header
        self.tableView.mj_footer = footer
        
        tableView.rx.itemSelected.subscribe(onNext: {
            self.tableView.cellForRow(at: $0)?.isSelected = false
            print("点击",$0)
        }).disposed(by: bag)
        
        tableView.rx.modelSelected(Model.self).subscribe(onNext: { (model) in
            print(model)
        }).disposed(by: bag)
    }

    @objc func upRefresh() {
        dataArray.value.removeAll()
        page = 1
        Network.default.searchDouBan(start: String(page), count: "10").subscribe(onNext:{
            self.tableView.mj_header.endRefreshing()

            let sec = SectionModel(model: "header", items: $0)
            self.dataArray.value.append(sec)
            
//            _ = $0.map { model in
//                let sec = SectionModel(model: "header", items: [model])
//                self.dataArray.value.append(sec)
//                self.dataArray.value.append(model)
//            }
        }).disposed(by: bag)
    }

    @objc func downRefresh() {
        page += 1
        Network.default.searchDouBan(start: String(page), count: "10").subscribe(onNext:{
            self.tableView.mj_footer.endRefreshing()

            let sec = SectionModel(model: "header", items: $0)
            self.dataArray.value.append(sec)
            
//            self.dataArray.value.append(sec)
//            _ = $0.map { model in
//                self.dataArray.value.append(model)
//            }
        }).disposed(by: bag)
    }
}
