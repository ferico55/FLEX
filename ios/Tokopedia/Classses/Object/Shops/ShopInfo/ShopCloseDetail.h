//
//  ShopCloseDetail.h
//  Tokopedia
//
//  Created by Tokopedia on 3/18/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ShopCloseDetail : NSObject

@property (strong, nonatomic) NSString *until;
@property (strong, nonatomic) NSString *reason;
@property (strong, nonatomic) NSString *note;

+ (RKObjectMapping *)mapping;

@end
