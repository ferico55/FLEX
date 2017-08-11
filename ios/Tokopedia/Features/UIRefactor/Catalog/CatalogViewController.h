//
//  CatalogViewController.h
//  Tokopedia
//
//  Created by Feizal Badri Asmoro on 3/3/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "List.h"

@interface CatalogViewController : UIViewController

@property (strong, nonatomic) List *list;

@property (strong, nonatomic) NSString *catalogID;
@property (strong, nonatomic) NSString *catalogName;
@property (strong, nonatomic) NSString *catalogPrice;
@property (strong, nonatomic) NSString *catalogImage;

- (void)updatePriceAlert:(NSString *)strPrice;
@end
