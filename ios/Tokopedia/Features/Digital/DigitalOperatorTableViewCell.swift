//
//  DigitalOperatorTableViewCell.swift
//  Tokopedia
//
//  Created by Ronald Budianto on 11/20/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import Foundation

class DigitalOperatorTableViewCell: UITableViewCell {
    let cellImage = UIImageView()
    let cellLabel = UILabel()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        cellImage.contentMode = .scaleAspectFill
        cellLabel.font = .largeTheme()
        contentView.addSubview(cellImage)
        contentView.addSubview(cellLabel)
        
        cellImage.snp.makeConstraints({ (make) in
            make.centerY.equalTo(self.contentView.snp.centerY)
            make.left.equalTo(self.contentView.snp.left).offset(16)
            make.height.equalTo(28)
            make.width.equalTo(50)
        })
        
        cellLabel.snp.makeConstraints({ (make) in
            make.centerY.equalTo(self.contentView.snp.centerY)
            make.left.equalTo(self.cellImage.snp.right).offset(16)
        })
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
