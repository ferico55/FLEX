//
//  ShopPaymentViewController.h
//  Tokopedia
//
//  Created by Tokopedia on 4/21/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ShipmentShopData.h"
#import "ShipmentDistrictData.h"
#import "ShipmentProvinceData.h"
#import "RequestObject.h"
#import "GeneratedHost.h"

@interface ShopPaymentViewController : UITableViewController

@property BOOL openShop;

@property (strong, nonatomic) NSString *shopLogo;
@property (strong, nonatomic) NSString *postKey;
@property (strong, nonatomic) NSString *fileUploaded;

@property (strong, nonatomic) NSDictionary *parameters;

@property (strong, nonatomic) NSDictionary *loc;
@property (strong, nonatomic) NSArray *paymentOptions;

@property (strong, nonatomic) GeneratedHost *generatedHost;

@end
