//
//  TableViewDelegate.swift
//  HURxSwiftNetWork
//
//  Created by 胡佳文 on 2017/7/23.
//  Copyright © 2017年 胡佳文. All rights reserved.
//

import UIKit

extension ViewController : UITableViewDelegate {

}

extension ViewController : UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 40
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:TableViewCell = tableView.dequeueReusableCell(withIdentifier: "cell") as! TableViewCell
        cell.title.text = String(indexPath.row)
        cell.detail.text = String(indexPath.row)
        return cell
    }
}
