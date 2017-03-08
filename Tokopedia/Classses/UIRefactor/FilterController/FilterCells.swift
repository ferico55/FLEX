//
//  FilterCells.swift
//  Tokopedia
//
//  Created by Renny Runiawati on 6/6/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import UIKit

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
    var leftPading : CGFloat = 0.0
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
    }
    
    func setPading(_ leftPading: CGFloat) {
        selectedImageView.isHidden = disableSelected
        arrowImageView.isHidden = !disableSelected
        
        self.leftPading = leftPading
        arrowImageView.frame = CGRect(origin: CGPoint(x: self.frame.size.width - 25, y: 15), size: CGSize(width: 10, height: 10))
        selectedImageView.frame =  CGRect(origin: CGPoint(x: 0 + leftPading, y: 13), size: CGSize(width: 15, height: 15))
        label.frame = CGRect(x: 0 + selectedImageView.frame.width + leftPading + 10, y: 0, width: self.frame.size.width - ( selectedImageView.frame.origin.x + selectedImageView.frame.size.width + arrowImageView.frame.size.width + 25), height: self.frame.size.height)
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
            selectedImageView.image = UIImage(named: "icon_checkmark_green")
        } else {
            selectedImageView.image = UIImage(named: "icon_circle")
        }
    }
    
    required init(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)!
    }
}
