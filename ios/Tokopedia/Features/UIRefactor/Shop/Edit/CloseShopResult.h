//
//  CloseShopResult.h
//  Tokopedia
//
//  Created by Johanes Effendi on 5/17/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CloseShopResult : NSObject
@property (strong, nonatomic) NSString* is_success;

+(RKObjectMapping*)mapping;
@end
