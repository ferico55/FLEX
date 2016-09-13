//
//  EditProductTroubleCell.swift
//  Tokopedia
//
//  Created by Renny Runiawati on 9/2/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import UIKit

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
    
    private var startEditTextView : (() -> Void)?
    
    var troubleDownPicker : DownPicker!
    
    var productTrouble : ProductTrouble = ProductTrouble()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        problemTextView.placeholder = "Detail masalah pada barang"
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func setViewModel(viewModel:ProductResolutionViewModel, product:ProductTrouble) {
        self.productTrouble = product
        
        productImageView.setImageWithUrl(NSURL.init(string: viewModel.productImageURLString)!, placeHolderImage: UIImage.init(named: "icon_toped_loading_grey-01.png"))
        
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
            selectedImageView.image = UIImage.init(named: "icon_checkmark_green-01.png")
        } else {
            selectedImageView.image = UIImage.init(named: "icon_circle.png")
        }
        self.troubleDownPicker = DownPicker.init(textField: self.troublePicker, withData: viewModel.troubleTypeList.map{$0.trouble_text})
        troubleDownPicker.shouldDisplayCancelButton = false
        
        troubleDownPicker.addTarget(self, action: #selector(EditProductTroubleCell.troubleDownPickerSelected(_:)), forControlEvents: .ValueChanged)
        
        quantityStepper.value = Double(viewModel.productQuantity)!
        quantityStepper.maximumValue = Double(viewModel.maxQuantity)!
    }
    
    func troubleDownPickerSelected(sender : DownPicker){
        productTrouble.pt_trouble_id = productTrouble.pt_trouble_list[sender.selectedIndex].trouble_id
        productTrouble.pt_trouble_name = productTrouble.pt_trouble_list[sender.selectedIndex].trouble_text
    }
    
    @IBAction func onChangeQuantityStepper(sender: UIStepper) {
        let quantity : String = String(format:"%.0f", sender.value)
        productTrouble.pt_last_selected_quantity = quantity
        quantityTextField.text = quantity
    }
    
    func startEditTextView(completion: ()->Void){
        self.startEditTextView = completion
    }
    
    func textViewShouldBeginEditing(textView: UITextView) -> Bool {
        self.startEditTextView!()
        return true
    }
    
    func textViewDidChange(textView: UITextView) {
        problemTextView.placeholderLabel.hidden = !textView.text.isEmpty
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        productTrouble.pt_solution_remark = problemTextView.text
    }
    
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        self.startEditTextView!()
        return true
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        
        if  string == "" { return true }
        
        var txtAfterUpdate:NSString = textField.text! as NSString
        txtAfterUpdate = txtAfterUpdate.stringByReplacingCharactersInRange(range, withString: string)
        return Int(txtAfterUpdate as String)! <= Int(quantityStepper.maximumValue)
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        productTrouble.pt_last_selected_quantity = quantityTextField.text!
    }
}
