//
//  CatalogModelView.h
//  Tokopedia
//
//  Created by Tonito Acen on 7/9/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CatalogModelView : NSObject

@property (strong, nonatomic) NSString *catalogName;
@property (strong, nonatomic) NSString *catalogPrice;
@property (strong, nonatomic) NSString *catalogSeller;
@property (strong, nonatomic) NSString *catalogThumbUrl;

@property (strong, nonatomic) NSString *luckyMerchantImageURL;

@end
