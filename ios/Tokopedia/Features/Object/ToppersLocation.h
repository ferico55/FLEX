//
//  ToppersLocation.h
//  Tokopedia
//
//  Created by Tonito Acen on 5/30/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ToppersLocation : NSObject

@property (nonnull, strong) NSString* latitude;
@property (nonnull, strong) NSString* longitude;
@property (nonnull, strong) NSString* source;

+ (RKObjectMapping*)mapping;

@end
