//
//  DigitalFavouriteNumberViewController.swift
//  Tokopedia
//
//  Created by Ronald Budianto on 10/12/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import MMNumberKeyboard
import UIKit

internal protocol DigitalFavouriteNumberProtocol {
    func selectedFavouriteNumber(favourite:DigitalFavourite)
}

internal class DigitalFavouriteNumberViewController: UIViewController, UITableViewDataSource, UITextFieldDelegate {

    @IBOutlet fileprivate var searchTextField: UITextField!
    @IBOutlet fileprivate var tableView: UITableView!
    internal var delegate:DigitalFavouriteNumberProtocol?
    fileprivate var favourites:[DigitalFavourite] = []
    fileprivate var data:[DigitalFavourite] = []
    fileprivate var number = ""
    fileprivate var categoryID = ""
    fileprivate var operatorID = ""
    fileprivate var productID = ""
    fileprivate var inputType:DigitalTextInputType = .text
    
    internal convenience init(favourites: [DigitalFavourite], categoryID:String, operatorID:String, productID:String, number:String, inputType:DigitalTextInputType) {
        self.init()
        self.favourites = favourites
        self.data = favourites
        self.categoryID = categoryID
        self.operatorID = operatorID
        self.productID = productID
        self.number = number
        self.inputType = inputType
    }
    
    internal override func viewDidLoad() {
        super.viewDidLoad()
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: self.searchTextField.frame.size.height))
        self.searchTextField.leftView = paddingView
        self.searchTextField.leftViewMode = .always
        self.searchTextField.delegate = self
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.register(UINib(nibName: "DigitalFavouriteNumberCell", bundle: nil), forCellReuseIdentifier: "DigitalFavouriteNumberCell")
        self.tableView.tableFooterView = UIView()
        if inputType == .number || inputType == .phone {
            let keyboard = MMNumberKeyboard()
            keyboard.allowsDecimalPoint = false
            keyboard.delegate = self
            
            self.searchTextField.inputView = keyboard
        }
        self.searchTextField.text = self.number
        self.searchTextField.becomeFirstResponder()
    }
    
    internal override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        AnalyticsManager.trackScreenName("Recharge Favourite Number Page")
    }
    
    internal override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.tableView.sizeToFit()
    }

    @IBAction private func textFieldChange(_ sender: UITextField) {
        guard let text = sender.text else { return }
        if !text.isEmpty {
            self.data = self.favourites.filter {
                if let clientNumber = $0.clientNumber {
                    return clientNumber.contains(text)
                } else {
                    return false
                }
            }
        } else {
            self.data = self.favourites
        }
        if self.data.first?.clientNumber != text && !text.isEmpty {
            self.data.insert(DigitalFavourite(categoryID: self.categoryID, operatorID: self.operatorID, productID: self.productID, clientNumber: text, name: ""), at: 0)
        }
        self.tableView.reloadData()
        // update table height
        var frame = self.tableView.frame
        frame.size.height = self.tableView.contentSize.height
        self.tableView.frame = frame

    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let favourite = DigitalFavourite(categoryID: self.categoryID, operatorID: self.operatorID, productID: self.productID, clientNumber: textField.text, name: nil)
        delegate?.selectedFavouriteNumber(favourite: favourite)
        self.navigationController?.popViewController(animated: true)
        return true
    }
}

extension DigitalFavouriteNumberViewController:MMNumberKeyboardDelegate {
    func numberKeyboardShouldReturn(_ numberKeyboard: MMNumberKeyboard!) -> Bool {
        let favourite = DigitalFavourite(categoryID: self.categoryID, operatorID: self.operatorID, productID: self.productID, clientNumber: self.searchTextField.text, name: nil)
        delegate?.selectedFavouriteNumber(favourite: favourite)
        self.navigationController?.popViewController(animated: true)
        return true
    }
}

extension DigitalFavouriteNumberViewController:UITableViewDelegate {
    internal func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "DigitalFavouriteNumberCell") as? DigitalFavouriteNumberCell else { fatalError("The dequeued cell is not an instance of DigitalFavouriteNumberCell") }
        cell.numberLabel.text = data[indexPath.row].clientNumber
        cell.nameLabel.text = data[indexPath.row].name
        return cell
    }
    
    internal func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let favourite = self.data[indexPath.row]
        delegate?.selectedFavouriteNumber(favourite: favourite)
        self.navigationController?.popViewController(animated: true)
    }
    
    internal func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.data.count
    }
    
    internal func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
}
