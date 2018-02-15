//
//  OTPTextField.swift
//  Tokopedia
//
//  Created by Bondan Eko Prasetyo on 25/01/18.
//  Copyright © 2018 TOKOPEDIA. All rights reserved.
//

import UIKit

public class OTPTextField: UITextField {
    /// Border color info for field
    internal var fieldBorderColor: UIColor = UIColor.black

    /// Border width info for field
    internal var fieldBorderWidth: CGFloat = 2

    internal var shapeLayer: CAShapeLayer!

    weak internal var prevTextfield: OTPTextField?

    internal var isError: Bool?

    override public func awakeFromNib() {
        super.awakeFromNib()
    }

    override public init(frame: CGRect) {
        super.init(frame: frame)
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override public func deleteBackward() {
        super.deleteBackward()
        if let text = self.text?.count, text == 0 {
            self.prevTextfield?.becomeFirstResponder()
            self.prevTextfield?.text = ""
            self.prevTextfield?.shapeLayer.fillColor = fieldBorderColor.cgColor
            self.prevTextfield?.shapeLayer.strokeColor =  fieldBorderColor.cgColor
        }
    }

    public func initalizeUI() {
        self.addBottomView()
        layer.borderColor = UIColor.clear.cgColor
        layer.borderWidth = 0
        autocorrectionType = .no
        textAlignment = .center
    }

    // Helper function to create a underlined bottom view
    fileprivate func addBottomView() {
        let path = UIBezierPath()
        path.move(to: CGPoint(x: 0, y: bounds.size.height - 6))
        path.addLine(to: CGPoint(x: bounds.size.width, y: bounds.size.height - 6))
        path.close()

        shapeLayer = CAShapeLayer()
        shapeLayer.path = path.cgPath
        shapeLayer.lineWidth = fieldBorderWidth
        shapeLayer.fillColor = backgroundColor?.cgColor
        shapeLayer.strokeColor = fieldBorderColor.cgColor

        layer.addSublayer(shapeLayer)
    }
}
