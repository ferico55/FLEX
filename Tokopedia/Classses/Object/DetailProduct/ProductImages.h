//
//  ProductImages.h
//  Tokopedia
//
//  Created by IT Tkpd on 9/8/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ProductImages : NSObject <TKPObjectMapping>

@property (nonatomic) NSInteger image_id;
@property (nonatomic) NSInteger image_status;
@property (nonatomic, strong) NSString *image_description;
@property (nonatomic) NSInteger image_primary;
@property (nonatomic, strong) NSString *image_src;

+ (RKObjectMapping*)mapping;

@end
