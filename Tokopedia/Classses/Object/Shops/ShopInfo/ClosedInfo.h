//
//  ClosedInfo.h
//  Tokopedia
//
//  Created by IT Tkpd on 9/9/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ClosedInfo: NSObject

@property (nonatomic, strong) NSString *until;
@property (nonatomic, strong) NSString *reason;
@property (nonatomic, strong) NSString *note;

+(RKObjectMapping*)mapping;
@end
