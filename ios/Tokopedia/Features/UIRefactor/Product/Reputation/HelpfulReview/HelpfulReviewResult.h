//
//  HelpfulReviewResult.h
//  Tokopedia
//
//  Created by Johanes Effendi on 1/12/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HelpfulReviewResult : NSObject

@property (nonatomic, strong) NSArray *list;
@property (nonatomic, strong) NSArray *helpful_reviews;
@property (nonatomic, strong) NSString *helpful_reviews_total;

+ (RKObjectMapping*)mapping;

@end
