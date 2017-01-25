//
//  TransactionATCViewController.h
//  Tokopedia
//
//  Created by IT Tkpd on 1/7/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TransactionATCViewController : GAITrackedViewController

@property (strong,nonatomic) NSDictionary *data;
@property (strong,nonatomic) NSArray *wholeSales;
@property (strong,nonatomic) NSString *productPrice;
@property (strong,nonatomic) NSString *productID;

@property BOOL isSnapSearchProduct;

@end
