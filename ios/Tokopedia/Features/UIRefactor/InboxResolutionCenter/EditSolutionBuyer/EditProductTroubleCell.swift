//
//  EditProductTroubleCell.swift
//  Tokopedia
//
//  Created by Renny Runiawati on 9/2/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import UIKit
import DownPicker

class EditProductTroubleCell: UITableViewCell, UITextViewDelegate, UITextFieldDelegate {
    @IBOutlet weak var productImageView: UIImageView!
    @IBOutlet weak var productNameLabel: UILabel!
    @IBOutlet weak var freeReturnViewHeight: NSLayoutConstraint!
    @IBOutlet weak var probleDetailViewHeight: NSLayoutConstraint!
    @IBOutlet weak var problemTextView: TKPDTextView!
    @IBOutlet weak var troublePicker: UITextField!
    @IBOutlet weak var selectedImageView: UIImageView!
    
    @IBOutlet weak var quantityTextField: UITextField!
    @IBOutlet weak var quantityStepper: UIStepper!
    
    fileprivate var startEditTextView : (() -> Void)?
    
    var troubleDownPicker : DownPicker!
    
    var productTrouble : ProductTrouble = ProductTrouble()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        problemTextView.placeholder = "Detail masalah pada barang"
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func setViewModel(_ viewModel:ProductResolutionViewModel, product:ProductTrouble) {
        self.productTrouble = product
        
        productImageView.setImageWithUrl(URL(string: viewModel.productImageURLString)!, placeHolderImage: UIImage(named: "icon_toped_loading_grey-01.png"))
        
        troublePicker.text = viewModel.productTrouble
        problemTextView.text = viewModel.productTroubleDescription
        productNameLabel.text = viewModel.productName
        quantityTextField.text = viewModel.productQuantity
        
        if viewModel.isFreeReturn {
            freeReturnViewHeight.constant = 20
        } else {
            freeReturnViewHeight.constant = 0
        }
        
        if viewModel.isSelected {
            selectedImageView.image = UIImage(named: "icon_check_green")
        } else {
            selectedImageView.image = UIImage(named: "icon_circle.png")
        }
        self.troubleDownPicker = DownPicker(textField: self.troublePicker, withData: viewModel.troubleTypeList.map{$0.trouble_text})
        troubleDownPicker.shouldDisplayCancelButton = false
        
        troubleDownPicker.addTarget(self, action: #selector(EditProductTroubleCell.troubleDownPickerSelected(_:)), for: .valueChanged)
        
        quantityStepper.maximumValue = Double(viewModel.maxQuantity)!
        quantityStepper.value = Double(viewModel.productQuantity)!
        
    }
    
    func troubleDownPickerSelected(_ sender : DownPicker){
        productTrouble.pt_trouble_id = productTrouble.pt_trouble_list[sender.selectedIndex].trouble_id
        productTrouble.pt_trouble_name = productTrouble.pt_trouble_list[sender.selectedIndex].trouble_text
    }
    
    @IBAction func onChangeQuantityStepper(_ sender: UIStepper) {
        let quantity : String = String(format:"%.0f", sender.value)
        productTrouble.pt_last_selected_quantity = quantity
        quantityTextField.text = quantity
    }
    
    func startEditTextView(_ completion: @escaping ()->Void){
        self.startEditTextView = completion
    }
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        self.startEditTextView!()
        return true
    }
    
    func textViewDidChange(_ textView: UITextView) {
        problemTextView.placeholderLabel.isHidden = !textView.text.isEmpty
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        productTrouble.pt_solution_remark = problemTextView.text
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        self.startEditTextView!()
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if  string == "" { return true }
        
        var txtAfterUpdate:NSString = textField.text! as NSString
        txtAfterUpdate = txtAfterUpdate.replacingCharacters(in: range, with: string) as NSString
        return Int(txtAfterUpdate as String)! <= Int(quantityStepper.maximumValue)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        productTrouble.pt_last_selected_quantity = quantityTextField.text!
    }
}
