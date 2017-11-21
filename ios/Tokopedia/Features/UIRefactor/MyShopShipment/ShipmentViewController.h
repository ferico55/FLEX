//
//  ShipmentViewController.h
//  Tokopedia
//
//  Created by Tokopedia on 3/15/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RequestObject.h"
#import "GeneratedHost.h"

@interface ShipmentViewController : UITableViewController

typedef NS_ENUM(NSInteger, ShipmentType) {
    ShipmentTypeOpenShop,
    ShipmentTypeSettings,
};

@property ShipmentType shipmentType;

@property (strong, nonatomic) NSString *shopName;
@property (strong, nonatomic) NSString *shopLogo;
@property (strong, nonatomic) NSString *shopDomain;
@property (strong, nonatomic) NSString *shopTagline;
@property (strong, nonatomic) NSString *shopShortDescription;

@property (strong, nonatomic) NSString *postKey;
@property (strong, nonatomic) NSString *fileUploaded;

@property (strong, nonatomic) GeneratedHost *generatedHost;

- (id)initWithShipmentType:(ShipmentType)type;

@end
