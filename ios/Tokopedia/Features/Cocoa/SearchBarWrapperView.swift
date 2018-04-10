//
//  SearchBarWrapperView.swift
//  Tokopedia
//
//  Created by Oscar Yuandinata on 11/6/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//
import UIKit

public class SearchBarWrapperView: UIView {
    
    /*
     // Only override draw() if you perform custom drawing.
     // An empty implementation adversely affects performance during animation.
     override func draw(_ rect: CGRect) {
     // Drawing code
     }
     */
    
    public let searchBar: UISearchBar
    
    public init(customSearchBar: UISearchBar) {
        searchBar = customSearchBar
        super.init(frame: CGRect.zero)
        
        addSubview(searchBar)
    }
    
    override convenience public init(frame: CGRect) {
        self.init(customSearchBar: UISearchBar())
        self.frame = frame
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        searchBar.frame = bounds
    }
}
