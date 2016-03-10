//
//  ImageSearchResponse.h
//  Tokopedia
//
//  Created by Tokopedia on 2/17/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ImageSearchResponseData.h"
#import "ImageSearchProduct.h"

@interface ImageSearchResponse : NSObject

@property (strong, nonatomic) NSString *status;
@property (strong, nonatomic) NSString *config;
@property (strong, nonatomic) ImageSearchResponseData *data;

@end
