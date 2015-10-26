//
//  TrackOrderDetail.m
//  Tokopedia
//
//  Created by Feizal Badri Asmoro on 2/6/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "TrackOrderDetail.h"

@implementation TrackOrderDetail

- (NSString *)receiver_name {
    return [_receiver_name kv_decodeHTMLCharacterEntities];
}

- (NSString *)shipper_name {
    return [_shipper_name kv_decodeHTMLCharacterEntities];
}


@end
