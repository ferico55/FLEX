//
//  ProductListMyShopViewController.h
//  Tokopedia
//
//  Created by IT Tkpd on 12/8/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ProductListMyShopDelegate <NSObject>

- (void) productSelectedWithURL:(NSString*) url;

@end

@interface ProductListMyShopViewController : GAITrackedViewController

@property (nonatomic, strong) NSDictionary *data;
@property (nonatomic, strong) id<ProductListMyShopDelegate> delegate;

@end
