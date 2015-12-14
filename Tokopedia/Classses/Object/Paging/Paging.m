//
//  Paging.m
//  Tokopedia
//
//  Created by IT Tkpd on 9/1/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "Paging.h"

@implementation Paging

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:_uri_next forKey:kTKPD_APIURINEXTKEY];
}

- (id)initWithCoder:(NSCoder *)decoder
{
    if (self = [super init]) {
        _uri_next = [decoder decodeObjectForKey:kTKPD_APIURINEXTKEY];
    }
    return self;
}

- (NSString *)uri_next {
    if ([_uri_next isEqualToString:@"0"]) {
        return nil;
    } else {
        return _uri_next;
    }
}


// MARK: TKPRootObjectMapping methods
+ (NSDictionary *)attributeMappingDictionary {
    NSArray *keys = @[@"uri_next",
                      @"uri_previous"];
    return [NSDictionary dictionaryWithObjects:keys forKeys:keys];
}

+ (RKObjectMapping *)mapping {
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:self];
    [mapping addAttributeMappingsFromDictionary:[self attributeMappingDictionary]];
    return mapping;
}

@end
