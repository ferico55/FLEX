//
//  CountRatingResult.h
//  Tokopedia
//
//  Created by Tokopedia on 7/2/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface CountRatingResult : NSObject <TKPObjectMapping>
@property (nonatomic, strong, nonnull) NSString *count_score_good;
@property (nonatomic, strong, nonnull) NSString *count_score_bad;
@property (nonatomic, strong, nonnull) NSString *count_score_neutral;

+ (RKObjectMapping *_Nonnull)mapping;

@end
