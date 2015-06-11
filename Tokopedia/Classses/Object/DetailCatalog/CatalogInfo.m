//
//  CatalogInfo.m
//  Tokopedia
//
//  Created by IT Tkpd on 10/1/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "CatalogInfo.h"

@implementation CatalogInfo

- (NSString *)catalog_description
{
    return [NSString convertHTML:[_catalog_description kv_decodeHTMLCharacterEntities]];
}

@end
