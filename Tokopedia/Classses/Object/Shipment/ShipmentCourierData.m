//
//  ShipmentCourierData.m
//  Tokopedia
//
//  Created by Tokopedia on 3/15/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import "ShipmentCourierData.h"

@implementation ShipmentCourierData

@synthesize showsAdditionalOptions = _showsAdditionalOptions;
@synthesize showsNote = _showsNote;
@synthesize showsWeightPolicy = _showsWeightPolicy;

+ (RKObjectMapping *)mapping {
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:self];
    NSDictionary *mappings = @{
        @"name" : @"name",
        @"id": @"courierId",
        @"logo" : @"logo",
        @"weight" : @"weight",
        @"weight_policy": @"weightPolicy",
        @"available" : @"available",
        @"by_zip_code" : @"byZipCode",
        @"url_additional_option" : @"URLAdditionalOption",
    };
    [mapping addAttributeMappingsFromDictionary:mappings];
    
    RKRelationshipMapping *productRelationship = [RKRelationshipMapping relationshipMappingFromKeyPath:@"services" toKeyPath:@"services" withMapping:[ShipmentServiceData mapping]];
    [mapping addPropertyMapping:productRelationship];
    
    return mapping;
}

- (void)setShowsAdditionalOptions:(BOOL)showsAdditionalOptions {
    _showsAdditionalOptions = showsAdditionalOptions;
}

- (BOOL)showsAdditionalOptions {
    if ([_URLAdditionalOption isEqualToString:@""]) {
        return NO;
    } else {
        return YES;
    }
}

- (void)setShowsNote:(BOOL)showsNote {
    _showsNote = showsNote;
}

- (BOOL)showsNote {
    if ([_note isEqualToString:@""]) {
        return NO;
    } else {
        return YES;
    }
}

- (void)setShowsWeightPolicy:(BOOL)showsWeightPolicy {
    _showsWeightPolicy = showsWeightPolicy;
}

- (BOOL)showsWeightPolicy {
    if ([_available boolValue]) {
        if ([_weightPolicy isEqualToString:@""]) {
            return NO;
        } else {
            return YES;
        }
    } else {
        return NO;
    }
}

- (BOOL)hasActiveServices {
    for (ShipmentServiceData *service in self.services) {
        if ([service.active boolValue]) {
            return YES;
        }
    }
    return NO;
}

- (NSString *)activeServiceIds {
    NSString *ids = @"";
    for (ShipmentServiceData *service in self.services) {
        if ([service.active boolValue]) {
            ids = [ids stringByAppendingString:[NSString stringWithFormat:@"%@,", service.productId]];
        }
    }
    return ids;
}

@end
