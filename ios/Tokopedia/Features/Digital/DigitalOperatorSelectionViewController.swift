//
//  DigitalOperatorSelectionViewController.swift
//  Tokopedia
//
//  Created by Samuel Edwin on 3/8/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

@objc(DigitalOperatorSelectionViewController)
class DigitalOperatorSelectionViewController: UIViewController {

    var onOperatorSelected: Observable<DigitalOperator> {
        return _onOperatorSelected.asObservable()
    }
    
    fileprivate let _onOperatorSelected = PublishSubject<DigitalOperator>()
    
    fileprivate let operators: [DigitalOperator]
    
    init(operators: [DigitalOperator]) {
        self.operators = operators
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let tableView = UITableView()
        
        Observable
            .from(operators)
            .bindTo(tableView.rx.items) { (tableView, row, digitalOperator) in
                let cell = UITableViewCell()
                cell.textLabel?.text = digitalOperator.name
                
                return cell
            }
            .disposed(by: rx_disposeBag)
        
        tableView.rx.itemSelected
            .do(onNext: { [unowned self] _ in
                _ = self.navigationController?.popViewController(animated: true)
            })
            .map { [unowned self] in self.operators[$0.row] }
            .bindTo(_onOperatorSelected)
            .disposed(by: rx_disposeBag)
        
        self.view = tableView
        self.view.backgroundColor = .white
    }
    
    override func viewWillAppear(_ animated: Bool) {
        AnalyticsManager.trackScreenName("Recharge Operator Page")
    }

}
