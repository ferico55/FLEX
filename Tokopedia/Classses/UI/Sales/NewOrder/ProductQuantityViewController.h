//
//  ProductQuantityViewController.h
//  Tokopedia
//
//  Created by Tokopedia PT on 1/21/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ProductQuantityDelegate <NSObject>

- (void)didUpdateProductQuantity:(NSArray *)productQuantity explanation:(NSString *)explanation;

@end

@interface ProductQuantityViewController : UIViewController

@property (strong, nonatomic) NSArray *products;
@property (strong, nonatomic) id<ProductQuantityDelegate> delegate;

@end
