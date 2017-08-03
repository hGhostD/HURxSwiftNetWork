//
//  TableViewCell.swift
//  HURxSwiftNetWork
//
//  Created by 胡佳文 on 2017/7/23.
//  Copyright © 2017年 胡佳文. All rights reserved.
//

import UIKit

class TableViewCell: UITableViewCell {
    let title = UILabel(frame: CGRect(x: 60, y: 10, width: 300, height: 24))
    let detail = UILabel(frame: CGRect(x: 60, y: 30, width: 300, height: 20))
    let headerImage = UIImageView(frame: CGRect(x: 20, y: 10, width: 40, height: 40))

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        if !self.isEqual(nil) {
            setupUI()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupUI () {
        title.font = UIFont(descriptor: .init(), size: 16)
        detail.font = UIFont(descriptor: .init(), size: 14)
        self.contentView.addSubview(headerImage)
        self.contentView.addSubview(title)
        self.contentView.addSubview(detail)
    }

}
