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

+ (RKObjectMapping *)mapping {
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:self];
    NSDictionary *mappings = @{
        @"name" : @"name",
        @"id" : @"courierId",
        @"logo" : @"logo",
        @"weight" : @"weight",
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
    if (![_URLAdditionalOption isEqualToString:@""]) {
        return YES;
    } else {
        return NO;
    }
}

- (void)setShowsNote:(BOOL)showsNote {
    _showsNote = showsNote;
}

- (BOOL)showsNote {
    if (![_note isEqualToString:@""]) {
        return YES;
    } else {
        return NO;
    }
}

@end
