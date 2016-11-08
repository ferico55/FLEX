//
//  MoreViewController.h
//  Tokopedia
//
//  Created by Tokopedia PT on 12/12/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MoreWrapperViewController.h"

@interface MoreViewController : UITableViewController

- (IBAction)actionCreateShop:(id)sender;
- (void)updateShopInformation;
- (void)updateImageURL;
- (void)updateSaldoTokopedia;

@property(strong, nonatomic) MoreWrapperViewController* wrapperViewController;
@end
