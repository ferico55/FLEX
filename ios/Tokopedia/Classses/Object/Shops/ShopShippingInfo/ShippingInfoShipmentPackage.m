//
//  ShippingInfoShipmentPackage.m
//  Tokopedia
//
//  Created by IT Tkpd on 11/19/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "ShippingInfoShipmentPackage.h"

@implementation ShippingInfoShipmentPackage

-(instancetype)initWithPrice:(NSString *)price packageID:(NSString *)packageID name:(NSString *)name {
    self = [super init];
    
    if (self) {
        self.price = price;
        self.sp_id = packageID;
        self.name = name;
    }
    
    return self;
}

-(NSString *)sp_id {
    return _sp_id ?: @"";
}

-(NSString *)name {
    return _name ?: @"";
}

-(NSString *)price {
    return _price ?: @"0";
}

+(NSDictionary *)attributeMappingDictionary
{
    NSArray *keys = @[@"price_total",
                      @"price",
                      @"desc",
                      @"active",
                      @"name",
                      @"sp_id",
                      @"package_available"
                      ];
    return [NSDictionary dictionaryWithObjects:keys forKeys:keys];
}

+(RKObjectMapping*)mapping
{
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:self];
    [mapping addAttributeMappingsFromDictionary:[self attributeMappingDictionary]];

    return mapping;
}

@end
