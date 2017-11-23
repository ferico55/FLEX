//
//  CCAuthenticationViewController.swift
//  Tokopedia
//
//  Created by Renny Runiawati on 02/11/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import UIKit
import Foundation
import RxSwift
import RxCocoa
import RxDataSources
import SwiftOverlays

class CCAuthenticationViewController: UIViewController {

    @IBOutlet private var tableView: UITableView!

    let refreshControl = UIRefreshControl()
    lazy var viewModel: CCAuthenticationViewModel = {
        CCAuthenticationViewModel(doRefresh: self.refreshControl.rx.controlEvent(.valueChanged).map { _ in () })
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Pengaturan Autentikasi"

        configureUI()
        configureTableview()
        configureDataSource()
        configureErrorStateView()
    }

    private func configureErrorStateView() {
        viewModel.showErrorState.asObservable().subscribe(onNext: { [weak self] error in
            if error.showError {
                self?.showErrorServerView(error: error)
            }
        }).disposed(by: rx_disposeBag)
    }

    private func showErrorServerView(error: ErrorState) {
        tableView.isHidden = true
        let emptyView = EmptyStateView(
            frame: view.frame,
            title: error.title,
            description: error.description,
            buttonTitle: error.buttonTitle,
            buttonColor: error.buttonColor)
        view.addSubview(emptyView)
        emptyView.snp.makeConstraints({ make in
            make.height.equalTo(280)
            make.center.equalTo(self.view)
        })
        emptyView.onTapButton = { [weak self] _ in
            guard let `self` = self else { return }
            emptyView.removeFromSuperview()
            self.errorButtonAction(error.action)
        }
    }

    private func errorButtonAction(_ action: ErrorState.Action) {
        switch action {
        case .dismiss:
            navigationController?.popViewController(animated: true)
        case .refresh:
            refreshData()
            tableView.isHidden = false
        }
    }

    private func configureUI() {
        viewModel.statusActivityIndicator.asObservable()
            .bindTo(refreshControl.rx.isRefreshing)
            .addDisposableTo(rx_disposeBag)

        viewModel.actionActivityIndicator.asObservable()
            .subscribe(onNext: { [weak self] isLoading in
                guard let `self` = self else { return }
                if isLoading {
                    SwiftOverlays.showCenteredWaitOverlay(self.view)
                } else {
                    SwiftOverlays.removeAllOverlaysFromView(self.view)
                }
            }).disposed(by: rx_disposeBag)
    }

    private func configureTableview() {
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.addSubview(refreshControl)

        tableView.rx.modelSelected(CCItemState.self)
            .subscribe(onNext: { [weak self] item in
                guard let `self` = self else { return }
                self.viewModel.selectedItem.value = item
            }).disposed(by: rx_disposeBag)
    }

    private func configureDataSource() {
        let dataSource = RxTableViewSectionedReloadDataSource<SectionModel<String, CCItemState>>()

        viewModel.items?
            .catchError({ _ in
                .empty()
            })
            .bindTo(tableView.rx.items(dataSource: dataSource))
            .disposed(by: rx_disposeBag)

        dataSource.configureCell = { _, tableView, indexPath, item in
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as UITableViewCell
            cell.textLabel?.text = item.name
            cell.textLabel?.font = UIFont.largeTheme()
            cell.textLabel?.textColor = UIColor.tpPrimaryBlackText()
            cell.selectionStyle = .none
            cell.tintColor = UIColor.tpGreen()

            if item.isSelected {
                cell.accessoryType = .checkmark
            } else {
                cell.accessoryType = .none
            }
            return cell
        }

        dataSource.titleForHeaderInSection = { [weak self] _, index in
            self?.viewModel.headerTitles[index]
        }

        dataSource.titleForFooterInSection = { [weak self]  _, index in
            self?.viewModel.footerTitles[index]
        }
    }

    private func refreshData() {
        self.tableView.setContentOffset(CGPoint(x: 0, y: -self.refreshControl.frame.size.height), animated: true)
        self.refreshControl.beginRefreshing()
        self.refreshControl.sendActions(for: .valueChanged)
    }
}
