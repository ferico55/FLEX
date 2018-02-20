//
//  TokoCashNominalViewController.swift
//  Tokopedia
//
//  Created by Tiara Freddy Andika on 9/12/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import RxCocoa
import RxSwift
import UIKit

public class TokoCashNominalViewController: UIViewController {
    
    @IBOutlet weak private var tableView: UITableView!
    
    private let closeBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "icon_close"), style: .plain, target: self, action: nil)
    public let nominal = PublishSubject<DigitalProduct>()
    
    // view model
    public var viewModel: TokoCashNominalViewModel!
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Nominal"
        self.navigationItem.leftBarButtonItem = closeBarButtonItem
        
        configureTableView()
        configureCloseBarButton()
        bindViewModel()
    }
    
    private func configureTableView() {
        let nib = UINib(nibName: "TokoCashNominalTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "TokoCashNominalTableViewCell")
        tableView.tableFooterView = UIView()
    }
    
    private func configureCloseBarButton() {
        closeBarButtonItem.rx.tap.subscribe(onNext: { [unowned self] in
            self.dismiss(animated: true, completion: nil)
        }).addDisposableTo(rx_disposeBag)
    }
    
    private func bindViewModel() {
        assert(viewModel != nil)
        let viewWillAppear = rx.sentMessage(#selector(UIViewController.viewWillAppear(_:)))
            .mapToVoid()
            .asDriverOnErrorJustComplete()
        let input = TokoCashNominalViewModel.Input(trigger: viewWillAppear,
                                                   selectedItem: tableView.rx.itemSelected.asDriver())
        let output = viewModel.transform(input: input)
        
        //Bind Posts to UITableView
        output.items.drive(tableView.rx.items(cellIdentifier: TokoCashNominalTableViewCell.reuseID, cellType: TokoCashNominalTableViewCell.self)) { tv, viewModel, cell in
            cell.bind(viewModel)
            }.addDisposableTo(rx_disposeBag)
        
        output.selectedItem.drive(onNext: { digitalProduct in
            self.nominal.onNext(digitalProduct)
            self.dismiss(animated: true, completion: nil)
        }).addDisposableTo(rx_disposeBag)
    }
    
}

