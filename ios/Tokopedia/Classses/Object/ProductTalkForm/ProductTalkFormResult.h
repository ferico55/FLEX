//
//  ProductTalkFormResult.h
//  Tokopedia
//
//  Created by IT Tkpd on 9/29/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ProductTalkFormResult : NSObject

@property (nonatomic, strong) NSString *is_success;
@property (nonatomic, strong) NSString *talk_id;

+ (RKRelationshipMapping *)mapping;
@end
