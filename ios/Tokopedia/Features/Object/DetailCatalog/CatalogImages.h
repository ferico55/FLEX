//
//  CatalogImages.h
//  Tokopedia
//
//  Created by IT Tkpd on 10/1/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CatalogImages : NSObject<TKPObjectMapping>

@property (nonatomic) NSInteger image_primary;
@property (nonatomic, strong, nonnull) NSString *image_src;
@property (nonatomic, strong, nonnull) NSString *image_src_full;

@end
