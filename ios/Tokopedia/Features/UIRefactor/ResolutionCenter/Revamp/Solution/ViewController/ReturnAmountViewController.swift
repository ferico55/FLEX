//
//  ReturnAmountViewController.swift
//  Tokopedia
//
//  Created by Vishun Dayal on 22/11/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import UIKit

class ReturnAmountViewController: UIViewController {
    @IBOutlet private weak var maxAmountLabel: UILabel!
    @IBOutlet private weak var textfield: UITextField!
    @IBOutlet private weak var continueButton: UIButton!
    var solution: RCCreateSolution!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
    }
    private func setupUI() {
        self.title = "Masukan Jumlah Uang"
        if let max = self.solution.amount?.idr {
            self.maxAmountLabel.text = "Maksimal \(max)"
        }
        if let amount = self.solution.returnExpected {
            let formatter = NumberFormatter.idr()
            self.textfield.text = formatter?.string(from: amount)
        }
        self.updateSaveButton()
    }
    func validate()->Bool {
        if let expected = self.solution.returnExpected, let max = self.solution.amount?.integer {
            if expected.intValue > max {
                self.maxAmountLabel.textColor = UIColor.tpRed()
            } else {
                self.maxAmountLabel.textColor = UIColor(white: 0, alpha: 0.7)
            }
            return (expected.intValue <= max && expected.intValue > 0)
        }
        return false
    }
    @IBAction private func continueTapped(sender: UIButton) {
        guard self.validate() else {return}
        RCManager.shared.rcCreateStep1Data?.solutionData?.selectedSolution = self.solution
        if var controllers = self.navigationController?.viewControllers {
            controllers.removeLast()
            controllers.removeLast()
            self.navigationController?.setViewControllers(controllers, animated:true)
        }
    }
    @IBAction private func endEditing(sender: UITapGestureRecognizer) {
        self.textfield.resignFirstResponder()
    }
    private func updateSaveButton() {
        if self.validate() {
            self.continueButton.backgroundColor = UIColor.tpGreen()
            self.continueButton.setTitleColor(UIColor.white, for: .normal)
        } else {
            self.continueButton.backgroundColor = UIColor(white: 0.0, alpha: 0.12)
            self.continueButton.setTitleColor(UIColor(white: 0.0, alpha: 0.38), for: .normal)
        }
    }
//    MARK:- UITextFieldDelegate
    func textFieldDidEndEditing(_ textField: UITextField) {
        var text = textField.text?.replacingOccurrences(of: "?", with: "")
        text = text?.replacingOccurrences(of: " ", with: "")
        text = text?.replacingOccurrences(of: ".", with: "")
        text = text?.replacingOccurrences(of: "Rp", with: "")
        let formatter = NumberFormatter.idr()
        if let text = text, let intValue = Int(text) {
            let number = NSNumber(value:intValue)
            self.solution.returnExpected = number
            textField.text = formatter?.string(from: number)
        }
        self.updateSaveButton()
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
