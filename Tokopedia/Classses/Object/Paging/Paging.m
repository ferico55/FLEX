//
//  Paging.m
//  Tokopedia
//
//  Created by IT Tkpd on 9/1/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "Paging.h"

@implementation Paging

- (void) encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:_uri_next forKey:kTKPD_APIURINEXTKEY];
}

- (id)initWithCoder:(NSCoder *)decoder
{
    if (self = [super init]) {
        _uri_next = [decoder decodeObjectForKey:kTKPD_APIURINEXTKEY];
    }
    return self;
}

@end
