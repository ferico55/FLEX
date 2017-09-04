//
//  EmptyStateView.swift
//  Tokopedia
//
//  Created by Renny Runiawati on 8/24/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import UIKit
import Lottie
import RxSwift

@objc(EmptyStateView) class EmptyStateView: UIView {
    
    @IBOutlet private var animationView: UIView!
    @IBOutlet private var actionButton: UIButton!
    @IBOutlet private var descriptionLabel: UILabel!
    @IBOutlet private var titleLabel: UILabel!
    
    @IBOutlet private var buttonHeight: NSLayoutConstraint!
    
    var onTapButton: (()->Void)?
    
    private func viewFromNib()-> UIView {
        guard let views = Bundle.main.loadNibNamed("EmptyStateView", owner: self, options: nil) else {
            fatalError("Empty State View XIB not found")
        }
        guard let view = views.first as? UIView else {
            fatalError("views is empty")
        }
        
        return view
    }
    
    init(frame : CGRect, animationName: String? = "FeedEmptyState", title: String, description: String, buttonTitle: String? = "") {
        super.init(frame: frame)
        
        let view = self.viewFromNib()
        self.addSubview(view)
        view.snp.makeConstraints { make in
            make.edges.equalTo(self)
        }
        
        let animation = LOTAnimationView(name: animationName!)
        animation.frame.size = self.animationView.frame.size
        animation.loopAnimation = true
        animation.contentMode = .scaleAspectFill
        animation.play(completion: nil)
        
        self.animationView.addSubview(animation)

        self.frame = bounds
        self.titleLabel.text = title
        self.descriptionLabel.text = description
        
        guard buttonTitle != "" else {
            self.actionButton.isHidden = true
            buttonHeight.constant = 0
            return
        }
        self.actionButton.setTitle(buttonTitle, for: .normal)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    @IBAction private func didTapActionButton(_ sender: Any) {
        onTapButton?()
    }

}
