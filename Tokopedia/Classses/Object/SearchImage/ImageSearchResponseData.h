//
//  ImageSearchResponseData.h
//  Tokopedia
//
//  Created by Tokopedia on 2/17/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SearchAWSProduct.h"

@interface ImageSearchResponseData : NSObject <TKPObjectMapping>

@property (strong, nonatomic) NSArray *similar_prods;


@end
