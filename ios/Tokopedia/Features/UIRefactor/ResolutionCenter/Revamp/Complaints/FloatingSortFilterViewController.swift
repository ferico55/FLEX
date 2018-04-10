//
//  FloatingSortFilterViewController.swift
//  Tokopedia
//
//  Created by Oscar Yuandinata on 31/01/18.
//  Copyright © 2018 TOKOPEDIA. All rights reserved.
//

import UIKit

internal protocol FloatingSortFilterViewDelegate: class {
    func btnSortDidTapped()
    func btnFilterDidTapped()
}

internal class FloatingSortFilterViewController: UIViewController {
    
    internal weak var delegate: FloatingSortFilterViewDelegate?

    internal override func viewDidLoad() {
        super.viewDidLoad()

        self.view.translatesAutoresizingMaskIntoConstraints = false
        self.view.layer.shadowOpacity = 1.0
        self.view.layer.shadowColor = UIColor.tpLine().cgColor
        self.view.layer.shadowOffset = CGSize(width: 2.0, height: 2.0)
    }

    internal override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    internal init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    internal required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: actions
    @IBAction private func btnSortDidTapped(_ sender: Any) {
        self.delegate?.btnSortDidTapped()
    }
    
    @IBAction private func btnFilterDidTapped(_ sender: Any) {
        self.delegate?.btnFilterDidTapped()
    }
}
