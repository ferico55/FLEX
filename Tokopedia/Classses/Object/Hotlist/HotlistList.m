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

-(HotlistViewModel *)viewModel
{
    if(_viewModel == nil) {
        
        HotlistViewModel *viewModel = [[HotlistViewModel alloc] init];
        [viewModel setPrice_start:_price_start];
        [viewModel setUrl:_url];
        [viewModel setImage_url:_image_url];
        [viewModel setImage_url_600:_image_url_600];
        [viewModel setTitle:_title];
        
        _viewModel = viewModel;
    }
    
    return _viewModel;
}

+ (RKObjectMapping *)mapping {
    RKObjectMapping* mapping = [RKObjectMapping mappingForClass:self];
    [mapping addAttributeMappingsFromArray:@[@"image_url", @"image_url_600", @"price_start", @"url", @"title"]];
    
    return mapping;
}

@end
