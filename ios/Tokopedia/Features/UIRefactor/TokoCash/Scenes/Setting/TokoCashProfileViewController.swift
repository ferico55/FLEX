//
//  TokoCashProfileViewController.swift
//  Tokopedia
//
//  Created by Tiara Freddy Andika on 9/7/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import SwiftOverlays

class TokoCashProfileViewController: UIViewController {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var nameActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var emailActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var phoneNumberLabel: UILabel!
    @IBOutlet weak var phoneNumberActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableViewheightConstraint: NSLayoutConstraint!
    
    // view model
    var viewModel: TokoCashProfileViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bindViewModel()
    }
    
    override func viewDidLayoutSubviews() {
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
        let selectedIndex = Variable(0)
        let input = TokoCashProfileViewModel.Input(trigger: viewWillAppear,
                                                   selectedIndex: selectedIndex.asDriver())
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
            .drive(tableView.rx.items(cellIdentifier: TokoCashAccountTableViewCell.reuseID, cellType: TokoCashAccountTableViewCell.self)) { row, viewModel, cell in
                UIView.animate(withDuration: 0.3){
                    cell.bind(viewModel)
                    cell.deleteButton.rx.tap
                        .subscribe(onNext: { [weak self] _ in
                            let alertController = UIAlertController(title: "Hapus Akun", message: "Apakah Anda yakin ingin menghapus akun akses \(viewModel.identifier)?", preferredStyle: .alert)
                            let deleteAction = UIAlertAction(title: "Hapus", style: .default) { _ in
                                selectedIndex.value = row
                            }
                            let cancelAction = UIAlertAction(title: "Batal", style: .cancel) { _ in }
                            alertController.addAction(deleteAction)
                            alertController.addAction(cancelAction)
                            self?.present(alertController, animated: true)
                        })
                        .addDisposableTo(cell.rx_disposeBag)
                }
            }.addDisposableTo(rx_disposeBag)
        
        output.deleteActivityIndicator
            .drive(onNext: { isRequest in
                if isRequest {
                    SwiftOverlays.showCenteredWaitOverlay(self.view)
                }else {
                    SwiftOverlays.removeAllOverlaysFromView(self.view)
                }
            })
            .disposed(by: rx_disposeBag)
        
        output.successMessage.drive(onNext: { message in
            StickyAlertView.showSuccessMessage([message])
        }).addDisposableTo(rx_disposeBag)
        
    }
}
