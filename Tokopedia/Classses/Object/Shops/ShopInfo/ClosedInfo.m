//
//  ClosedInfo.m
//  Tokopedia
//
//  Created by IT Tkpd on 9/9/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "ClosedInfo.h"

@implementation ClosedInfo

+(RKObjectMapping *)mapping{
    RKObjectMapping* mapping = [RKObjectMapping mappingForClass:[ClosedInfo class]];
    [mapping addAttributeMappingsFromArray:@[@"until", @"reason", @"note"]];
    return mapping;
}

- (NSString *)reason {
    return [_reason kv_decodeHTMLCharacterEntities];
}

- (NSString *)note {
    return [_note kv_decodeHTMLCharacterEntities];
}

@end
