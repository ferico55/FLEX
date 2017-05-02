//
//  CatalogReview.h
//  Tokopedia
//
//  Created by IT Tkpd on 10/1/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CatalogReview : NSObject<TKPObjectMapping>

@property (nonatomic, strong) NSString *review_from_image;
@property (nonatomic, strong) NSString *review_rating;
@property (nonatomic, strong) NSString *review_url;
@property (nonatomic, strong) NSString *review_from_url;
@property (nonatomic, strong) NSString *review_from;
@property (nonatomic, strong) NSString *catalog_id;
@property (nonatomic, strong) NSString *review_description;

@end
