//
//  ShopInfoResult.m
//  Tokopedia
//
//  Created by Tokopedia on 3/18/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import "ShopInfoResult.h"

@implementation ShopInfoResult

@synthesize isOpen = _isOpen;
@synthesize isClosed = _isClosed;

+ (RKObjectMapping *)mapping {
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:self];
    [mapping addAttributeMappingsFromArray:@[@"is_allow"]];
    
    RKRelationshipMapping *infoRelationship = [RKRelationshipMapping relationshipMappingFromKeyPath:@"info" toKeyPath:@"info" withMapping:[ShopEditInfo mapping]];
    [mapping addPropertyMapping:infoRelationship];
    
    RKRelationshipMapping *closedDetailRelationship = [RKRelationshipMapping relationshipMappingFromKeyPath:@"closed_detail" toKeyPath:@"closed_detail" withMapping:[ShopCloseDetail mapping]];
    [mapping addPropertyMapping:closedDetailRelationship];

    RKRelationshipMapping *imageRelationship = [RKRelationshipMapping relationshipMappingFromKeyPath:@"image" toKeyPath:@"image" withMapping:[ShopInfoImage mapping]];
    [mapping addPropertyMapping:imageRelationship];
    
    RKRelationshipMapping *scheduleRelationship = [RKRelationshipMapping relationshipMappingFromKeyPath:@"closed_schedule_detail" toKeyPath:@"closed_schedule_detail" withMapping:[ClosedScheduleDetail mapping]];
    [mapping addPropertyMapping:scheduleRelationship];

    return mapping;
}

- (void)setIsClosed:(BOOL)isClosed {
    _isClosed = isClosed;
}

- (BOOL)isClosed {
    if ([self.closed_detail.until isEqualToString:@""]) {
        return NO;
    } else {
        return YES;
    }
}

- (void)setIsOpen:(BOOL)isOpen {
    _isOpen = isOpen;
}

- (BOOL)isOpen {
    return self.isClosed?NO:YES;
}

@end
