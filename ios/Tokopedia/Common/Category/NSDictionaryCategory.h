//
//  NSDictionaryCategory.h
//  Tokopedia
//
//  Created by IT Tkpd on 10/29/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary(tkpdcategory)

- (BOOL)isMutable;
- (NSDictionary *)encrypt;
- (NSDictionary<NSString *, id> *)autoParameters;
+ (NSDictionary*)dictionaryFromURLString:(NSString *)URLString;

@end
