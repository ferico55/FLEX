//
//  FilterCells.swift
//  Tokopedia
//
//  Created by Renny Runiawati on 6/6/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import UIKit

@objc enum DirectionArrow : Int {
    case up
    case down
}

class TextFieldCell: UITableViewCell
{
    var textField : UITextField = UITextField()
    var titleLabel : UILabel = UILabel()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String!)
    {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.titleLabel = UILabel(frame: CGRect(x:15, y:10, width: self.frame.size.width, height:15))
        self.textField = UITextField(frame: CGRect(x: 20, y: self.titleLabel.frame.size.height+self.titleLabel.frame.origin.y, width: self.frame.size.width-100, height: 30));
        
        self.textField.font = UIFont.title2Theme()
        
        self.titleLabel.font = UIFont.title2Theme()
        self.titleLabel.textColor = UIColor.gray
        
        self.textField.borderStyle = UITextBorderStyle.none
        self.textField.keyboardType = UIKeyboardType.numberPad
        
        //Add TextField to SubView
        self.addSubview(self.textField)
        self.addSubview(self.titleLabel)
    }
    
    required init(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)!
    }
}

class switchCell: UITableViewCell
{
    var switchView : UISwitch = UISwitch()
    var completionHandler:(Bool)->Void = {(arg:Bool) -> Void in}
    
    init(style: UITableViewCellStyle, reuseIdentifier: String!, isSelected:Bool, onCompletion: @escaping ((Bool) -> Void))
    {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        completionHandler = onCompletion
        
        self.switchView = UISwitch(frame: CGRect.zero)
        self.switchView.isOn = isSelected
        self.switchView.addTarget(self, action: #selector(switchCell.switchChanged(_:)), for: UIControlEvents.valueChanged)
        
        self.accessoryView = self.switchView
        
        self.textLabel?.font = UIFont.title2Theme()
    }
    
    func switchChanged(_ sender:UISwitch) -> Void {
        completionHandler(sender.isOn)
    }
    
    required init(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)!
    }
}

class FilterTableViewCell: UITableViewCell
{
    var selectedImageView : UIImageView = UIImageView()
    var arrowImageView : UIImageView = UIImageView()
    var label : UILabel = UILabel ()
    var disableSelected :Bool = true
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String!)
    {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        label.numberOfLines = 0
        label.font = UIFont.title2Theme()
        arrowImageView.contentMode = .scaleAspectFit
        selectedImageView.contentMode = .scaleAspectFit
        selectedImageView.isHidden = true
        selectedImageView.image = UIImage(named: "icon_circle")
        arrowImageView.image = UIImage(named: "icon_arrow_down")
        
        self.addSubview(selectedImageView)
        self.addSubview(arrowImageView)
        self.addSubview(label)
        
        selectedImageView.snp.makeConstraints { (make) in
            make.top.equalTo(13)
            make.height.width.equalTo(15)
        }
        
        label.snp.makeConstraints { (make) in
            make.top.bottom.equalTo(0)
            make.left.equalTo(self.selectedImageView.snp.right).offset(10)
        }
        
        arrowImageView.snp.makeConstraints { (make) in
            make.rightMargin.equalTo(-15)
            make.top.equalTo(15)
            make.width.height.equalTo(10)
            make.left.equalTo(self.label.snp.right)
        }
    }
    
    func setPading(_ leftPading: CGFloat) {
        selectedImageView.isHidden = disableSelected
        arrowImageView.isHidden = !disableSelected
        
        selectedImageView.snp.remakeConstraints { (make) in
            make.top.equalTo(13)
            make.left.equalTo(leftPading)
            make.height.width.equalTo(self.selectedImageView.isHidden ? 0 : 15)
        }
        
        label.snp.remakeConstraints  { (make) in
            make.top.bottom.equalTo(0)
            make.left.equalTo(self.selectedImageView.snp.right).offset(10)
        }
        
        arrowImageView.snp.remakeConstraints { (make) in
            make.rightMargin.equalTo(-15)
            make.top.equalTo(15)
            make.width.height.equalTo(10)
            make.left.equalTo(self.label.snp.right)
        }
    }
    
    func setArrowDirection(_ direction:DirectionArrow) {
        if (direction == .up) {
            arrowImageView.image = UIImage(named: "icon_arrow_up")
        } else if (direction == .down) {
            arrowImageView.image = UIImage(named: "icon_arrow_down")
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool){
        if (selected) {
            selectedImageView.image = UIImage(named: "icon_check_green")
        } else {
            selectedImageView.image = UIImage(named: "icon_circle")
        }
    }
    
    required init(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)!
    }
}
