//
//  RequestObject.m
//  Tokopedia
//
//  Created by Renny Runiawati on 11/18/15.
//  Copyright © 2015 TOKOPEDIA. All rights reserved.
//

#import "RequestObject.h"

@implementation RequestObjectGetAddress

+(NSDictionary *)attributeMappingDictionary
{
    NSArray *keys = @[@"action",
                        @"page",
                        @"per_page",
                        @"user_id",
                        @"query",
                        @"product_id"];
    return [NSDictionary dictionaryWithObjects:keys forKeys:keys];
}

+(RKObjectMapping*)mapping
{
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:self];
    [mapping addAttributeMappingsFromDictionary:[self attributeMappingDictionary]];
    return mapping;
}

@end


@implementation RequestObjectEditAddress

+(NSDictionary *)attributeMappingDictionary
{
    NSArray *keys = @[@"action",
                      @"address_id",
                      @"city",
                      @"receiver_name",
                      @"address_name",
                      @"receiver_phone",
                      @"province",
                      @"postal_code",
                      @"address_street",
                      @"user_password",
                      @"district",
                      @"longitude",
                      @"latitude",
                      @"is_from_cart"];
    return [NSDictionary dictionaryWithObjects:keys forKeys:keys];
}

+(RKObjectMapping*)mapping
{
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:self];
    [mapping addAttributeMappingsFromDictionary:[self attributeMappingDictionary]];
    return mapping;
}

@end

@implementation RequestObjectUploadImage

+ (NSDictionary*)attributeMappingDictionary {
    NSDictionary *dictionary = @{@"id"          : @"image_id",
                                 @"token"       : @"token",
                                 @"user_id"     : @"user_id",
                                 @"payment_id"  : @"payment_id",
                                 @"action"      : @"action",
                                 @"web_service" : @"web_service",
                                 @"new_add"     : @"add_new",
                                 @"product_id"  :@"product_id"
                                 };
    
    return dictionary;
}

+ (RKObjectMapping*)mapping {
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:self];
    [mapping addAttributeMappingsFromDictionary:[self attributeMappingDictionary]];
    
    return mapping;
}

@end