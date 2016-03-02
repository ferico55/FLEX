//
//  SwipeViewDataSource.swift
//  Tokopedia
//
//  Created by Tonito Acen on 2/11/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import Foundation


@objc class DigitalGoodsDataSource: NSObject, SwipeViewDataSource {
    var _goods: Array<MiniSlide>!
    var _swipeView: SwipeView!
    let _imageWidth:CGFloat = (UI_USER_INTERFACE_IDIOM() == .Pad) ? 320 : 200
    let _imageHeight:CGFloat = 100
    
    init(goods: Array<MiniSlide>, swipeView: SwipeView) {
        super.init()
        
        _goods = goods
        _swipeView = swipeView
        _swipeView.dataSource = self
    }
    
    func numberOfItemsInSwipeView(swipeView: SwipeView!) -> Int {
        return _goods.count
    }
    
    func swipeView(swipeView: SwipeView!, viewForItemAtIndex index: Int, reusingView view: UIView!) -> UIView! {
        let imageView = UIImageView(frame: CGRect(x: 10,y: 10,width: _imageWidth,height: _imageHeight))
        let good = _goods[index]
        
        imageView.setImageWithUrl(NSURL(string: good.image_url)!, placeHolderImage: nil)
        imageView.layer.cornerRadius = 5.0;
        imageView.layer.masksToBounds = true;
        
        let view = UIView(frame: CGRect(x: 0, y: 0, width: imageView.frame.size.width + imageView.frame.origin.x, height: _swipeView.frame.size.height))
        view.addSubview(imageView)
    
        return view
    }
    
    
    func goodsAtIndex(index: Int) -> MiniSlide {
        return _goods[index]
    }

}