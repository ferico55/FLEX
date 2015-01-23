//
//  HotlistList.m
//  Tokopedia
//
//  Created by IT Tkpd on 8/29/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "string_home.h"
#import "HotlistList.h"

@implementation HotlistList

- (void) encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:_price_start forKey:kTKPDHOME_APISTARTERPRICEKEY];
    [encoder encodeObject:_url forKey:kTKPDHOME_APIURLKEY];
    [encoder encodeObject:_image_url forKey:kTKPDHOME_APITHUMBURLKEY];
    [encoder encodeObject:_title forKey:kTKPDHOME_APITITLEKEY];
    
}

- (id)initWithCoder:(NSCoder *)decoder
{
    if (self = [super init]) {
        _price_start = [decoder decodeObjectForKey:kTKPDHOME_APISTARTERPRICEKEY];
        _url = [decoder decodeObjectForKey:kTKPDHOME_APIURLKEY];
        _image_url = [decoder decodeObjectForKey:kTKPDHOME_APITHUMBURLKEY];
        _title = [decoder decodeObjectForKey:kTKPDHOME_APITITLEKEY];
    }
    return self;
}

@end
