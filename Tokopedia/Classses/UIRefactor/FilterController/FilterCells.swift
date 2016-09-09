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
        
        self.titleLabel = UILabel.init(frame: CGRect(x:15, y:10, width: self.frame.size.width, height:15))
        self.textField = UITextField(frame: CGRect(x: 20, y: self.titleLabel.frame.size.height+self.titleLabel.frame.origin.y, width: self.frame.size.width-100, height: 30));
        
        self.textField.font = UIFont.title2Theme()
        
        self.titleLabel.font = UIFont.title2Theme()
        self.titleLabel.textColor = UIColor.grayColor()
        
        self.textField.borderStyle = UITextBorderStyle.None
        self.textField.keyboardType = UIKeyboardType.NumberPad
        
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
    
    init(style: UITableViewCellStyle, reuseIdentifier: String!, isSelected:Bool, onCompletion: ((Bool) -> Void))
    {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        completionHandler = onCompletion
        
        self.switchView = UISwitch.init(frame: CGRectZero)
        self.switchView.on = isSelected
        self.switchView.addTarget(self, action: "switchChanged:", forControlEvents: UIControlEvents.ValueChanged)
        
        self.accessoryView = self.switchView
        
        self.textLabel?.font = UIFont.title2Theme()
    }
    
    func switchChanged(sender:UISwitch) -> Void {
        completionHandler(sender.on)
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
        arrowImageView.contentMode = .ScaleAspectFit
        selectedImageView.contentMode = .ScaleAspectFit
        selectedImageView.hidden = true
        selectedImageView.image = UIImage.init(named: "icon_circle.png")
        arrowImageView.image = UIImage.init(named: "icon_arrow_down.png")
        
        self.addSubview(selectedImageView)
        self.addSubview(arrowImageView)
        self.addSubview(label)
    }
    
    func setPading(leftPading: CGFloat) {
        selectedImageView.hidden = disableSelected
        arrowImageView.hidden = !disableSelected
        
        self.leftPading = leftPading
        arrowImageView.frame = CGRect(origin: CGPoint(x: self.frame.size.width - 25, y: 15), size: CGSize(width: 10, height: 10))
        selectedImageView.frame =  CGRect(origin: CGPoint(x: 0 + leftPading, y: 13), size: CGSize(width: 15, height: 15))
        label.frame = CGRectMake(0 + selectedImageView.frame.width + leftPading + 10, 0, self.frame.size.width - ( selectedImageView.frame.origin.x + selectedImageView.frame.size.width + arrowImageView.frame.size.width + 25), self.frame.size.height)
    }
    
    func setArrowDirection(direction:DirectionArrow) {
        if (direction == .Up) {
            arrowImageView.image = UIImage.init(named: "icon_arrow_up.png")
        } else if (direction == .Down) {
            arrowImageView.image = UIImage.init(named: "icon_arrow_down.png")
        }
    }
    
    override func setSelected(selected: Bool, animated: Bool){
        if (selected) {
            selectedImageView.image = UIImage.init(named: "icon_checkmark_green-01.png")
        } else {
            selectedImageView.image = UIImage.init(named: "icon_circle.png")
        }
    }
    
    required init(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)!
    }
}
