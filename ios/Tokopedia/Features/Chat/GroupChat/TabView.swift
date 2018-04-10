//
//  TabView.swift
//  Tokopedia
//
//  Created by Bondan Eko Prasetyo on 17/03/18.
//  Copyright © 2018 TOKOPEDIA. All rights reserved.
//

import UIKit

internal protocol TabViewDelegate: class {
    func didPressButton(index: Int)
}

internal class TabView: UIView {
    
    private weak var image: UIImage!
    private var labelText: String!
    private let tabButton = UIButton(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
    private let tabLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 70, height: 20))
    internal var tabIndex: Int?
    internal weak var delegate: TabViewDelegate?
    
    internal init(image: UIImage, labelText: String) {
        self.image = image
        self.labelText = labelText
        super.init(frame: CGRect(x: 0, y: 0, width: 70, height: 70))
        setupView()
    }
    
    override internal init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required internal init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private func setupView() {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.heightAnchor.constraint(equalToConstant: 70).isActive = true
        self.widthAnchor.constraint(equalToConstant: 70).isActive = true
        
        self.addSubview(tabButton)
        tabButton.setImage(image, for: .normal)
        tabButton.addTarget(self, action: #selector(self.onPressTab(_:)), for: .touchUpInside)
        tabButton.translatesAutoresizingMaskIntoConstraints =  false
        tabButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        tabButton.widthAnchor.constraint(equalToConstant: 50).isActive = true
        tabButton.centerXAnchor.constraint(equalTo: self.centerXAnchor, constant: 0).isActive = true
        tabButton.topAnchor.constraint(equalTo: self.topAnchor, constant: 0).isActive = true
        
        self.addSubview(tabLabel)
        tabLabel.font = .microTheme()
        tabLabel.textColor = .tpDisabledBlackText()
        tabLabel.text = labelText
        tabLabel.textAlignment = .center
        tabLabel.translatesAutoresizingMaskIntoConstraints = false
        tabLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 0).isActive = true
        tabLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 0).isActive = true
        tabLabel.topAnchor.constraint(equalTo: tabButton.bottomAnchor, constant: 4).isActive = true
    }
    
    @objc private func onPressTab(_ sender: UIButton) {
        if let index = self.tabIndex {
            self.delegate?.didPressButton(index: index)
        }
    }
    
    public func setupActive(isActive: Bool) {
        if isActive {
            tabLabel.textColor = .tpPrimaryBlackText()
            tabButton.layer.shadowColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.25)
            tabButton.layer.shadowOffset = CGSize(width: 0, height: 2)
            tabButton.layer.shadowRadius = 5
            tabButton.layer.shadowOpacity = 1
        } else {
            tabButton.layer.shadowOpacity = 0
            tabLabel.textColor = .tpDisabledBlackText()
        }
    }

}
