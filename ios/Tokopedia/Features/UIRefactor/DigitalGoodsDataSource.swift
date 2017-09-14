//
//  SwipeViewDataSource.swift
//  Tokopedia
//
//  Created by Tonito Acen on 2/11/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import Foundation

@objc class DigitalGoodsDataSource: NSObject, SwipeViewDataSource, SwipeViewDelegate {
    var _goods : Array<MiniSlide>!
    var _swipeView : SwipeView!
    var delegate: UIViewController!
    let imageWidth : CGFloat = (UI_USER_INTERFACE_IDIOM() == .pad) ? 120 : 72
    let imageHeight : CGFloat = (UI_USER_INTERFACE_IDIOM() == .pad) ? 120 : 72
    
    init(goods: Array<MiniSlide>, swipeView: SwipeView) {
        super.init()
        
        _goods = goods
        _swipeView = swipeView
        _swipeView.dataSource = self
    }
    
    func numberOfItems(in swipeView: SwipeView!) -> Int {
        return _goods.count
    }
    
    func swipeView(_ swipeView: SwipeView!, viewForItemAt index: Int, reusing view: UIView!) -> UIView! {
        let imageView = UIImageView(frame: CGRect(x: 5,y: 10,width: imageWidth,height: imageHeight))
        let good = _goods[index]
        
        imageView.setImageWithUrl(URL(string: good.image_url)!, placeHolderImage: nil)
        
        imageView.layer.cornerRadius = 5.0;
        imageView.layer.masksToBounds = true;
        
        let view = UIView(frame: CGRect(x: 0, y: 0, width: imageView.frame.size.width + imageView.frame.origin.x, height: _swipeView.frame.size.height))
        view.addSubview(imageView)
    
        return view
    }
    
    func goodsAtIndex(_ index: Int) -> MiniSlide {
        return _goods[index]
    }
    
    func swipeView(_ swipeView: SwipeView!, didSelectItemAt index: Int) {
        let controller = WebViewController()
        controller.strURL = _goods[index].redirect_url
        controller.hidesBottomBarWhenPushed = true
        
        self.delegate.navigationController?.pushViewController(controller, animated: true)
    }

}
