//
//  PriceAlertViewController.h
//  Tokopedia
//
//  Created by Tokopedia on 5/22/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ProductDetail, DetailPriceAlert, CatalogInfo;

@interface PriceAlertViewController : UIViewController
{
    IBOutlet UITextField *txtPrice;
    IBOutlet UILabel *lblDesc;
}

@property (nonatomic, unsafe_unretained) CatalogInfo *catalogInfo;
@property (nonatomic, unsafe_unretained) ProductDetail *productDetail;
@property (nonatomic, unsafe_unretained) DetailPriceAlert *detailPriceAlert;
@end
