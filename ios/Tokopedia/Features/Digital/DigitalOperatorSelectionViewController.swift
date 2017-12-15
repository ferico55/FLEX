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
import TPKeyboardAvoiding

@objc(DigitalOperatorSelectionViewController)
class DigitalOperatorSelectionViewController: UIViewController {
    
    var onOperatorSelected: Observable<DigitalOperator> {
        return _onOperatorSelected.asObservable()
    }
    
    fileprivate let _onOperatorSelected = PublishSubject<DigitalOperator>()
    fileprivate let operators: [DigitalOperator]
    fileprivate let text : String
    fileprivate let categoryName : String
    fileprivate let tableView: TPKeyboardAvoidingTableView = {
        let tableView = TPKeyboardAvoidingTableView()
        tableView.tableFooterView = UIView()
        tableView.keyboardDismissMode = .onDrag
        return tableView
    }()
    fileprivate let searchTextField: UITextField = {
        let textField = UITextField()
        textField.backgroundColor = .tpBackground()
        textField.clearButtonMode = .whileEditing
        textField.leftViewMode = .always
        textField.cornerRadius = 2
        return textField
    }()
    fileprivate let containerView = UIView()
    fileprivate let imageView:UIImageView = {
        let imageView = UIImageView(image: #imageLiteral(resourceName: "ic_search"))
        imageView.frame = CGRect(x: 0, y: 0, width: imageView.frame.width + 16, height: imageView.frame.height)
        imageView.image = imageView.image?.withRenderingMode(.alwaysTemplate)
        imageView.tintColor = .tpGray()
        imageView.contentMode = .center
        return imageView
    }()
    
    init(operators: [DigitalOperator], title:String, categoryName:String) {
        self.operators = operators
        self.text = title
        self.categoryName = categoryName
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initView()
        let dataSource = Variable<[DigitalOperator]>([])
        searchTextField.rx.text.orEmpty.map { (text) -> [DigitalOperator] in
            guard !text.isEmpty else { return self.operators }
            return self.operators.filter {
                return $0.name.lowercased().contains(text.lowercased())
            }
        }.bindTo(dataSource)
        
        dataSource
            .asObservable()
            .bindTo(tableView.rx.items) { _, _, digitalOperator in
            let cell = DigitalOperatorTableViewCell()
            cell.cellImage.setImageWith(URL(string: digitalOperator.imageUrl))
            cell.cellLabel.text = digitalOperator.name
            cell.preservesSuperviewLayoutMargins = false
            cell.separatorInset = UIEdgeInsets.zero
            cell.layoutMargins = UIEdgeInsets.zero
            return cell
        }.disposed(by: rx_disposeBag)
        
        tableView.rx.itemSelected
            .do(onNext: { [unowned self] _ in
                _ = self.navigationController?.popViewController(animated: true)
            })
            .map { [unowned self] in dataSource.value[$0.row] }
            .bindTo(_onOperatorSelected)
            .disposed(by: rx_disposeBag)
        
        searchTextField.rx.controlEvent(.editingDidBegin).subscribe(onNext: { _ in
            AnalyticsManager.trackRechargeEvent(event: .homepage, category: self.categoryName, action: "Click Search Bar")
        })
        
        containerView.addSubview(searchTextField)
        view.addSubview(containerView)
        view.addSubview(tableView)
        
        if self.operators.count > 10 {
            searchTextField.snp.makeConstraints({ (make) in
                make.top.equalTo(self.containerView.snp.top).offset(10)
                make.left.equalTo(self.containerView.snp.left).offset(10)
                make.right.equalTo(self.containerView.snp.right).offset(-10)
                make.bottom.equalTo(self.containerView.snp.bottom).offset(-10)
            })
            
            containerView.snp.makeConstraints({ (make) in
                make.height.equalTo(70)
                make.top.left.right.equalToSuperview()
            })
        } else {
            searchTextField.snp.makeConstraints({ (make) in
                make.edges.equalTo(self.containerView.snp.edges)
            })
            
            containerView.snp.makeConstraints({ (make) in
                make.height.equalTo(0)
                make.top.left.right.equalToSuperview()
            })
        }
        
        tableView.snp.makeConstraints({ (make) in
            make.left.right.bottom.equalToSuperview()
            make.top.equalTo(self.containerView.snp.bottom)
        })
        
        view.backgroundColor = .white
    }
    
    override func viewWillAppear(_ animated: Bool) {
        AnalyticsManager.trackScreenName("Recharge Operator Page")
    }
    
    private func initView() {
        self.title = "Pilih " + self.text
        self.searchTextField.placeholder = "Cari " + self.text
        self.searchTextField.leftView = self.imageView
    }
}

extension DigitalOperatorSelectionViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
}
