//
//  RejectReason.h
//  Tokopedia
//
//  Created by Johanes Effendi on 6/6/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RejectReason : NSObject
@property(strong, nonatomic) NSString* reason_code;
@property(strong, nonatomic) NSString* reason_text;

+(RKObjectMapping*)mapping;
@end
