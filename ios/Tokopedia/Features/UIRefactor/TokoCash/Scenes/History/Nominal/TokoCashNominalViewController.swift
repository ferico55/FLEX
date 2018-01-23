//
//  TokoCashNominalViewController.swift
//  Tokopedia
//
//  Created by Tiara Freddy Andika on 9/12/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

protocol TokoCashNominalDelegate {
    func getNominal(_ nominal: DigitalProduct)
}

class TokoCashNominalViewController: UIViewController {
    
    @IBOutlet weak var closeBarButtonItem: UIBarButtonItem!
    @IBOutlet weak var tableView: UITableView!
    
    var delegate: TokoCashNominalDelegate?
    
    // view model
    var viewModel: TokoCashNominalViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTableView()
        configureCloseBarButton()
        bindViewModel()
    }
    
    private func configureTableView() {
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
            self.delegate?.getNominal(digitalProduct)
            self.dismiss(animated: true, completion: nil)
        }).addDisposableTo(rx_disposeBag)
    }
    
}

