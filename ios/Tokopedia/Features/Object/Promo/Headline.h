//
//  Headline.h
//  Tokopedia
//
//  Created by Billion Goenawan on 29/12/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HeadlineImage.h"

@class ProductBadge;

@interface Headline : NSObject

@property (nonatomic, strong) NSString* templateId;
@property (nonatomic, strong) NSString* name;
@property (nonatomic, strong) HeadlineImage* headlineImage;
@property (nonatomic, strong) NSArray<ProductBadge*>* badges;
@property (nonatomic, strong) NSString* promotedText;
@property (nonatomic, strong) NSString* headlineDescription;
@property (nonatomic, strong) NSString* buttonText;

+ (RKObjectMapping *)mapping;

@end
