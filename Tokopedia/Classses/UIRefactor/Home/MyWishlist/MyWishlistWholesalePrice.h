//
//  MyWishlistWholesalePrice.h
//  Tokopedia
//
//  Created by Billion Goenawan on 9/23/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MyWishlistWholesalePrice : NSObject <TKPObjectMapping>
@property (nonatomic) NSInteger minimum;
@property (nonatomic) NSInteger maximum;
@property (nonatomic) CGFloat price;

@end
