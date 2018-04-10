//
//  OnDemandInfoView.swift
//  Tokopedia
//
//  Created by Dhio Etanasti on 6/8/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import Foundation
import Render

class OnDemandInfoView: UIView {
    init(rateProduct: RateProduct, rect: CGRect) {
        super.init(frame: rect)
        for view in self.subviews {
            view.removeFromSuperview()
        }
        
        let onDemandInfoComponent = OnDemandInfoComponentView(rateProduct: rateProduct)
        self.addSubview(onDemandInfoComponent)
        onDemandInfoComponent.render(in: self.frame.size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

struct OnDemandInfoState: StateType {
    var rateProduct: RateProduct?
}

class OnDemandInfoComponentView: ComponentView<OnDemandInfoState> {
    
    override init() {
        super.init()
    }
    
    convenience init(rateProduct: RateProduct) {
        self.init()
        let theState = OnDemandInfoState(rateProduct: rateProduct)
        self.state = theState
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func construct(state: OnDemandInfoState?, size: CGSize) -> NodeType {
        guard let state = state,
            let theInfo = state.rateProduct,
            theInfo.is_show_map == 1,
            theInfo.max_hours_id != nil && theInfo.max_hours_id != ""
        else {
            return Node<UIView>()
        }
        
        func border() -> NodeType {
            return Node<UIView> {
                view, layout, _ in
                view.backgroundColor = .fromHexString("cde4c3")
                layout.height = 1
                layout.width = size.width
            }
        }
        
        let mainView = Node<UIView> {
            view, layout, _ in
            view.backgroundColor = .fromHexString("f3fef3")
            layout.height = size.height - 2
            layout.width = size.width
            layout.alignItems = .center
            layout.justifyContent = .center
        }
        
        let middleImageWrapper = Node<UIView> {
            _, layout, _ in
            layout.flexDirection = .row
            layout.marginBottom = 15
            layout.alignItems = .flexEnd
            layout.justifyContent = .center
        }
        
        let originImageView = Node<UIImageView> {
            view, layout, _ in
            view.image = UIImage(named: "box-1")
            layout.height = 41
            layout.width = 76
        }
        
        let maxHoursWrapper = Node<UIImageView> {
            view, layout, _ in
            view.image = UIImage(named: "arrow")
            layout.height = 21
            layout.width = 124
            layout.marginHorizontal = 6
            layout.marginBottom = 2
            layout.justifyContent = .center
        }
        
        let maxHoursLabel = Node<UILabel> {
            view, layout, _ in
            view.text = theInfo.max_hours_id
            view.textColor = .tpGreen()
            view.numberOfLines = 1
            view.adjustsFontSizeToFitWidth = true
            view.font = UIFont.microThemeSemibold()
            layout.marginLeft = 31
            layout.marginRight = 36
        }
        
        maxHoursWrapper.add(child: maxHoursLabel)
        
        let destinationImageView = Node<UIImageView> {
            view, layout, _ in
            view.image = UIImage(named: "deliver-2")
            layout.height = 41
            layout.width = 67
        }
        
        middleImageWrapper.add(children: [
            originImageView,
            maxHoursWrapper,
            destinationImageView
        ])
        
        let bottomInfoLabel = Node<UILabel> {
            view, layout, _ in
            view.textColor = .tpSecondaryBlackText()
            view.font = UIFont.microTheme()
            view.text = theInfo.desc_hours_id
            view.numberOfLines = 0
            view.textAlignment = .center
            layout.marginHorizontal = 36
        }
        
        return Node<UIView>().add(children: [
            border(),
            mainView.add(children: [
                middleImageWrapper,
                bottomInfoLabel
            ]),
            border()
        ])
        
    }
    
}
