//
//  MyShopAddressEditViewController.h
//  Tokopedia
//
//  Created by IT Tkpd on 11/21/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ShopAddressEditViewControllerDelegate <NSObject>
@optional
- (void)successEditAddress:(Address *)address;
@end

@interface MyShopAddressEditViewController : UIViewController

@property (nonatomic, weak) IBOutlet id<ShopAddressEditViewControllerDelegate> delegate;

@property (nonatomic, strong) NSDictionary *data;

@end
