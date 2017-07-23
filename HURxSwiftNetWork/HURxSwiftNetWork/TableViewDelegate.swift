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
        return 10
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        cell?.textLabel?.text = String(indexPath.row)
        return cell!
    }
}
