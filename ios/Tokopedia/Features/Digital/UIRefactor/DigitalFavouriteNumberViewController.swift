//
//  DigitalFavouriteNumberViewController.swift
//  Tokopedia
//
//  Created by Ronald Budianto on 10/12/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import UIKit
import MMNumberKeyboard

protocol DigitalFavouriteNumberProtocol {
    func selectedFavouriteNumber(favourite:DigitalFavourite)
}

class DigitalFavouriteNumberViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet var searchTextField: UITextField!
    @IBOutlet var tableView: UITableView!
    var favourites:[DigitalFavourite] = []
    var data:[DigitalFavourite] = []
    var delegate:DigitalFavouriteNumberProtocol?
    var number = ""
    var categoryID = ""
    var operatorID = ""
    var productID = ""
    var inputType:DigitalTextInputType = .text
    
    convenience init(favourites: [DigitalFavourite], categoryID:String, operatorID:String, productID:String, number:String, inputType:DigitalTextInputType) {
        self.init()
        self.favourites = favourites
        self.data = favourites
        self.categoryID = categoryID
        self.operatorID = operatorID
        self.productID = productID
        self.number = number
        self.inputType = inputType
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: self.searchTextField.frame.size.height))
        self.searchTextField.leftView = paddingView
        self.searchTextField.leftViewMode = .always
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.register(UINib(nibName: "DigitalFavouriteNumberCell", bundle: nil), forCellReuseIdentifier: "DigitalFavouriteNumberCell")
        self.tableView.tableFooterView = UIView()
        if inputType == .number || inputType == .phone {
            let keyboard = MMNumberKeyboard()
            keyboard.allowsDecimalPoint = false
            
            self.searchTextField.inputView = keyboard
        }
        self.searchTextField.text = self.number
        self.searchTextField.becomeFirstResponder()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.tableView.sizeToFit()
    }

    @IBAction func textFieldChange(_ sender: UITextField) {
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
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "DigitalFavouriteNumberCell") as? DigitalFavouriteNumberCell else { fatalError("The dequeued cell is not an instance of DigitalFavouriteNumberCell") }
        cell.numberLabel.text = data[indexPath.row].clientNumber
        cell.nameLabel.text = data[indexPath.row].name
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let favourite = self.data[indexPath.row]
        delegate?.selectedFavouriteNumber(favourite: favourite)
        self.navigationController?.popViewController(animated: true)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.data.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}
