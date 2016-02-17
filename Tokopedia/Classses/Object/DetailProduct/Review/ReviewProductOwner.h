//
//  ReviewProductOwner.h
//  Tokopedia
//
//  Created by IT Tkpd on 9/25/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ReviewProductOwner : NSObject

@property (nonatomic, strong) NSString *user_id;
@property (nonatomic, strong) NSString *user_image;
@property (nonatomic, strong) NSString *user_name;

+ (RKObjectMapping*) mapping;

@end
