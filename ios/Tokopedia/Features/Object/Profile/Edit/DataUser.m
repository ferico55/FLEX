//
//  DataUser.m
//  Tokopedia
//
//  Created by IT Tkpd on 10/31/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "DataUser.h"

@implementation DataUser

- (NSString *)birth_day {
    return _birth_day?:@"";
}

- (NSString *)full_name {
    return _full_name?:@"";
}

- (NSString *)birth_month {
    return _birth_month?:@"";
}

- (NSString *)user_email {
    return _user_email?:@"";
}

- (NSString *)birth_year {
    return _birth_year?:@"";
}

- (NSString *)user_phone {
    return _user_phone?:@"";
}

- (NSString *)gender {
    return _gender?:@"";
}

- (NSString *)user_image {
    return _user_image?:@"";
}

+(NSDictionary *) attributeMappingDictionary{
    NSArray *keys = @[@"birth_day",
                      @"full_name",
                      @"birth_month",
                      @"birth_year",
                      @"gender",
                      @"user_image",
                      @"user_email",
                      @"user_phone",
                      @"user_generated_name"];
    
    return [NSDictionary dictionaryWithObjects:keys forKeys:keys];
}

+(RKObjectMapping *) mapping{
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass: self];
    
    [mapping addAttributeMappingsFromDictionary:[self attributeMappingDictionary]];
    
    return mapping;
}

@end
