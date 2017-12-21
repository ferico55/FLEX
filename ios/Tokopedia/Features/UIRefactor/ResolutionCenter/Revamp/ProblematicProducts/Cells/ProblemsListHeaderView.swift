//
//  ProblemsListHeaderView.swift
//  Tokopedia
//
//  Created by Vishun Dayal on 12/10/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import UIKit

class ProblemsListHeaderView: UITableViewHeaderFooterView {
    var titleLabel: UILabel?
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        self.createTitleLabel()
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        self.addConstraints()
    }
    func createTitleLabel() {
        self.titleLabel = UILabel(frame: self.bounds)
        if let label = self.titleLabel {
            label.font = UIFont.mediumSystemFont(ofSize: 16.0)
            label.textColor = UIColor(white: 0.0, alpha: 0.54)
            self.contentView.addSubview(label)
        }
    }
    private func addConstraints() {
        if let label = self.titleLabel {
            label.translatesAutoresizingMaskIntoConstraints = false
            let margins = self.layoutMarginsGuide
            label.leadingAnchor.constraint(equalTo: margins.leadingAnchor , constant: 0.0).isActive = true
            label.trailingAnchor.constraint(equalTo: margins.trailingAnchor , constant: 0.0).isActive = true
            label.bottomAnchor.constraint(equalTo: margins.bottomAnchor, constant: 0.0).isActive = true
            label.heightAnchor.constraint(equalToConstant: 29.0).isActive = true
        }
    }
}
