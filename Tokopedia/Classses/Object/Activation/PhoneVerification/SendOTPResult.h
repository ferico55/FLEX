//
//  SendOTPResult.h
//  Tokopedia
//
//  Created by Johanes Effendi on 11/27/15.
//  Copyright © 2015 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SendOTPResult : NSObject <TKPObjectMapping>

@property (strong, nonatomic) NSString *is_success;

+(NSDictionary *) attributeMappingDictionary;
+(RKObjectMapping *) mapping;

@end