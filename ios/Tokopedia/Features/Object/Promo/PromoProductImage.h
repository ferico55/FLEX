//
//  PromoProductImage.h
//  Tokopedia
//
//  Created by Tokopedia on 7/29/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PromoProductImage : NSObject

@property (strong, nonatomic) NSString *m_url;
@property (strong, nonatomic) NSString *s_url;
@property (strong, nonatomic) NSString *xs_url;
@property (strong, nonatomic) NSString *m_ecs;
@property (strong, nonatomic) NSString *s_ecs;
@property (strong, nonatomic) NSString *xs_ecs;

+ (RKObjectMapping*)mapping;

@end
