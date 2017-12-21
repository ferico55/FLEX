//
//  ProblemsListViewController.swift
//  Tokopedia
//
//  Created by Vishun Dayal on 12/10/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import UIKit

class ProblemsListViewController: UIViewController {
    //    MARK:- IBoutlets
    @IBOutlet private weak var saveButton: UIButton!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    //    MARK:- Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Pilih Barang & Masalah"
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.updateSaveButton()
    }

    //    MARK:- Action
    @IBAction private func saveButtonTapped(sender: UIButton) {
        if self.isProblemItemAdded() {
            self.navigationController?.popViewController(animated: true)
        }
    }
    //    MARK:- Update UI
    private func updateSaveButton(isDisabled: Bool) {
        if isDisabled {
            self.saveButton.backgroundColor = UIColor(white: 0.0, alpha: 0.12)
            self.saveButton.setTitleColor(UIColor(white: 0.0, alpha: 0.38), for: .normal)
        } else {
            self.saveButton.backgroundColor = UIColor.tpGreen()
            self.saveButton.setTitleColor(UIColor.white, for: .normal)
        }
    }
    func makeActivityIndicator(toShow: Bool) {
        if toShow {
            self.activityIndicator.startAnimating()
        } else {
            self.activityIndicator.stopAnimating()
        }
    }
//    MARK:- 
    func updateSaveButton() {
        self.updateSaveButton(isDisabled: !self.isProblemItemAdded())
    }
    private func isProblemItemAdded()->Bool {
        guard let data = RCManager.shared.rcCreateStep1Data else {return false}
        return data.selectedProblemItem.count > 0
    }
}
