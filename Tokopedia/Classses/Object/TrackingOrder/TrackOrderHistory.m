//
//  TrackOrderHistory.m
//  Tokopedia
//
//  Created by Feizal Badri Asmoro on 2/8/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "TrackOrderHistory.h"

@implementation TrackOrderHistory

- (NSString *)status {
    return [_status kv_decodeHTMLCharacterEntities];
}

@end