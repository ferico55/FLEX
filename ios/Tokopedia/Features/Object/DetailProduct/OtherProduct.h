//
//  OtherProduct.h
//  Tokopedia
//
//  Created by IT Tkpd on 9/8/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OtherProduct : NSObject <TKPObjectMapping>

@property (nonatomic, strong, nonnull) NSString *product_price;
@property (nonatomic, strong, nonnull) NSNumber *product_id;
@property (nonatomic, strong, nonnull) NSString *product_image;
@property (nonatomic, strong, nonnull) NSString *product_name;

+ (RKObjectMapping *_Nonnull)mapping;

@end
