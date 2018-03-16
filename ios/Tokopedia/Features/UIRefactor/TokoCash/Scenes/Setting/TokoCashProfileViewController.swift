//
//  TokoCashProfileViewController.swift
//  Tokopedia
//
//  Created by Tiara Freddy Andika on 9/7/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import RxCocoa
import RxSwift
import SwiftOverlays
import UIKit

public class TokoCashProfileViewController: UIViewController {
    
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var nameActivityIndicator: UIActivityIndicatorView!
    @IBOutlet private weak var emailLabel: UILabel!
    @IBOutlet private weak var emailActivityIndicator: UIActivityIndicatorView!
    @IBOutlet private weak var phoneNumberLabel: UILabel!
    @IBOutlet private weak var phoneNumberActivityIndicator: UIActivityIndicatorView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var tableViewheightConstraint: NSLayoutConstraint!
    
    private let deleteAccount = PublishSubject<TokoCashAccount>()
    
    // view model
    public var viewModel: TokoCashProfileViewModel!
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Pengaturan Akun"
        
        let nib = UINib(nibName: "TokoCashAccountTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "TokoCashAccountTableViewCell")
        bindViewModel()
    }
    
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.layoutIfNeeded()
        tableViewheightConstraint.constant = tableView.contentSize.height
        view.setNeedsUpdateConstraints()
    }
    
    private func bindViewModel() {
        assert(viewModel != nil)
        let viewWillAppear = rx.sentMessage(#selector(UIViewController.viewWillAppear(_:)))
            .mapToVoid()
            .asDriverOnErrorJustComplete()
        
        let input = TokoCashProfileViewModel.Input(trigger: viewWillAppear,
                                                   selectedIndex: deleteAccount.asDriverOnErrorJustComplete())
        let output = viewModel.transform(input: input)
        
        output.fetching
            .drive(nameActivityIndicator.rx.isAnimating)
            .addDisposableTo(rx_disposeBag)
        
        output.fetching
            .drive(emailActivityIndicator.rx.isAnimating)
            .addDisposableTo(rx_disposeBag)
        
        output.fetching
            .drive(phoneNumberActivityIndicator.rx.isAnimating)
            .addDisposableTo(rx_disposeBag)
        
        output.name
            .drive(nameLabel.rx.text)
            .addDisposableTo(rx_disposeBag)
        
        output.email
            .drive(emailLabel.rx.text)
            .addDisposableTo(rx_disposeBag)
        
        output.phoneNumber
            .drive(phoneNumberLabel.rx.text)
            .addDisposableTo(rx_disposeBag)
        
        output.isHiddenAccount
            .drive(titleLabel.rx.isHidden)
            .addDisposableTo(rx_disposeBag)
        
        output.accounts
            .drive(tableView.rx.items(cellIdentifier: TokoCashAccountTableViewCell.reuseID, cellType: TokoCashAccountTableViewCell.self)) { _, viewModel, cell in
                cell.bind(viewModel)
                cell.account.asDriverOnErrorJustComplete()
                    .drive(onNext: { [weak self] account in
                        self?.showDeleteConfirmationDelete(account)
                    }).addDisposableTo(cell.rx_disposeBag)
                
            }.addDisposableTo(rx_disposeBag)
        
        output.deleteActivityIndicator
            .drive(onNext: { isRequest in
                if isRequest {
                    SwiftOverlays.showCenteredWaitOverlay(self.view)
                } else {
                    SwiftOverlays.removeAllOverlaysFromView(self.view)
                }
            })
            .disposed(by: rx_disposeBag)
        
        output.successMessage.drive(onNext: { message in
            StickyAlertView.showSuccessMessage([message])
        }).addDisposableTo(rx_disposeBag)
        
    }
    
    private func showDeleteConfirmationDelete(_ account: TokoCashAccount) {
        let alertController = UIAlertController(title: "Hapus Akun",
                                                message: "Apakah Anda yakin ingin menghapus akun akses \(account.identifier ?? "")?", preferredStyle: .alert)
        let deleteAction = UIAlertAction(title: "Hapus", style: .default) { _ in
            self.deleteAccount.onNext(account)
        }
        let cancelAction = UIAlertAction(title: "Batal", style: .cancel) { _ in }
        alertController.addAction(deleteAction)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true)
    }
}
