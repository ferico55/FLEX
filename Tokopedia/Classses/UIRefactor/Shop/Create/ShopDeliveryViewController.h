//
//  ShopDeliveryViewController.h
//  Tokopedia
//
//  Created by Tokopedia on 4/16/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AddressViewController.h"
@class CreateShopViewController;

@interface ShopDeliveryViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, SettingAddressLocationViewDelegate, UIGestureRecognizerDelegate>
{
    IBOutlet UITableView *tblShopDelivery;
}
@property (nonatomic, unsafe_unretained) CreateShopViewController *createShopViewController;
@end
