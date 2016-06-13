//
//  CourierInfoViewController.h
//  Tokopedia
//
//  Created by Tokopedia on 3/15/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ShipmentCourierData.h"

@interface CourierInfoViewController : UITableViewController

@property (strong, nonatomic) ShipmentCourierData *courier;

@end
