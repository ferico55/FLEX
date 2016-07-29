//
//  PulsaView.swift
//  Tokopedia
//
//  Created by Tonito Acen on 7/28/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import UIKit
import Foundation

class PulsaView: UIView {
    
    var pulsaCategoryControl: UISegmentedControl!
    var numberField: UITextField!
    var numberErrorLabel: UILabel!
    var productButton: UIButton!
    var buyButton: UIButton!
    var buttonsPlaceholder: UIView!
    var onPrefixEntered: (((String) -> Void)?)
    
    var prefixes: Dictionary<String, Dictionary<String, String>>!
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(categories: [PulsaCategory]) {
        super.init(frame: CGRectZero)
        
        pulsaCategoryControl = UISegmentedControl(frame: CGRectZero)
        categories.enumerate().forEach { index, category in
            pulsaCategoryControl.insertSegmentWithTitle(category.attributes.name, atIndex: index, animated: true)
        }
        
        self.addSubview(pulsaCategoryControl)
        pulsaCategoryControl.mas_makeConstraints { make in
            make.height.equalTo()(44)
            make.top.equalTo()(0)
            make.left.equalTo()(self.mas_left)
            make.right.equalTo()(self.mas_right)
        }
        
        pulsaCategoryControl .bk_addEventHandler({[unowned self] control in
            self.buildAllView(categories[control.selectedSegmentIndex])
        }, forControlEvents: .ValueChanged)

        self.buildAllView(categories[0])
    }
    
    func buildAllView(category: PulsaCategory) {
        self.subviews.enumerate().forEach { index, subview in
            if(index > 0) {
                subview.removeFromSuperview()
            }
        }

        //field creation
        numberField = UITextField(frame: CGRectZero)
        
        numberField.placeholder = category.attributes.client_number.placeholder
        numberField.borderStyle = .RoundedRect
        numberField.rightViewMode = .Always
        numberField.keyboardType = .NumberPad
        numberField.bk_addEventHandler ({[unowned self] number in
            let inputtedPrefix = self.numberField.text
            let characterCount = inputtedPrefix!.characters.count
            
            if(characterCount == 4) {
                if(self.prefixes.count == 0) { return }
                
                let prefix = self.prefixes[inputtedPrefix!]
                if(prefix != nil) {
                    let prefixImage = UIImageView.init(frame: CGRectMake(0, 0, 70, 35))
                    prefixImage.setImageWithURL((NSURL.init(string: prefix!["image"]!)))
                    self.numberField.rightView = prefixImage
                    self.numberField.rightViewMode = .Always
                    
                    self.onPrefixEntered!(self.numberField.text!)
                } else {
                    self.numberField.rightView = nil
                }
            }
            
            if(characterCount < 4) {
                self.numberField.rightView = nil
            }
        }, forControlEvents: .EditingChanged)
        
        self.addSubview(numberField)
        numberField.mas_makeConstraints { make in
            make.height.equalTo()(44)
            make.top.equalTo()(self.pulsaCategoryControl.mas_bottom).offset()(10)
            make.left.equalTo()(self.mas_left)
            make.right.equalTo()(self.mas_right)
        }
        
        
        numberErrorLabel = UILabel(frame: CGRectZero)
        numberErrorLabel.text = "Error"
        numberErrorLabel.textColor = UIColor.redColor()
        self.addSubview(numberErrorLabel)
        
        numberErrorLabel.mas_makeConstraints { make in
            make.height.equalTo()(0)
            make.top.equalTo()(self.numberField.mas_bottom).offset()(3)
            make.left.equalTo()(self.mas_left)
            make.right.equalTo()(self.mas_right)
        }
        
        //buttons creation
        buttonsPlaceholder = UIView(frame: CGRectZero)
        self.addSubview(buttonsPlaceholder)
        
        buttonsPlaceholder.mas_makeConstraints { make in
            make.top.equalTo()(self.numberErrorLabel.mas_bottom)
            make.left.equalTo()(self.mas_left)
            make.right.equalTo()(self.mas_right)
        }
        
        productButton = UIButton(frame: CGRectZero)
        productButton.setTitle("Pilih Nominal", forState: .Normal)
        productButton.layer.cornerRadius = 3
        productButton.layer.borderColor = UIColor.greenColor().CGColor
        productButton.layer.borderWidth = 1
        productButton.setTitleColor(UIColor.greenColor(), forState: .Normal)
        productButton.hidden = true
        
        buttonsPlaceholder.addSubview(productButton)
        
        productButton.mas_makeConstraints { make in
            make.height.equalTo()(0)
            make.top.equalTo()(self.buttonsPlaceholder.mas_top).offset()(10)
            make.left.equalTo()(self.mas_left)
            make.width.equalTo()(150)
            make.bottom.equalTo()(self.mas_bottom)
        }
        
        
        buyButton = UIButton(frame: CGRectZero)
        buyButton.setTitle("Beli", forState: .Normal)
        buyButton.layer.cornerRadius = 3
        buyButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        buyButton.backgroundColor = UIColor.orangeColor()
        buyButton.hidden = true
        
        buttonsPlaceholder.addSubview(buyButton)
        
        buyButton.mas_makeConstraints { make in
            make.height.equalTo()(0)
            make.top.equalTo()(self.productButton.mas_top)
            make.left.equalTo()(self.productButton.mas_right).offset()(10)
            make.right.equalTo()(self.buttonsPlaceholder.mas_right)
        }
        
        self.recalibrateView()
    }
    
    func buildBuyButton(products: [PulsaProduct]) {
        productButton.mas_updateConstraints { make in
            make.height.equalTo()(44)
        }
        
        buyButton.mas_updateConstraints { make in
            make.height.equalTo()(44)
        }
        
        productButton.hidden = false
        buyButton.hidden = false
    }
    
    func recalibrateView() {
        self.subviews.enumerate().forEach { index, subview in
            subview.mas_makeConstraints { make in
                if(index == 0) {
                    make.top.equalTo()(subview.superview!).with().offset()(0)
                } else {
                    make.top.equalTo()(self.subviews[index-1].mas_bottom).offset()(10)
                }
            }
        }
        
        self.subviews.last?.mas_makeConstraints { make in
            make.bottom.equalTo()(self.mas_bottom)
        }
    }
    
    
    func attachToView(container: UIView) {
        container.addSubview(self)
        
        self.mas_makeConstraints {make in
            make.left.equalTo()(container.mas_left)
            make.top.equalTo()(container.mas_top)
            make.right.equalTo()(container.mas_right)
            make.bottom.equalTo()(container.mas_bottom)
        }

    }

}
