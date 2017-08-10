//
//  LuckyDealWord.h
//  Tokopedia
//
//  Created by Renny Runiawati on 11/24/15.
//  Copyright © 2015 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LuckyDealWord : NSObject <TKPObjectMapping>

@property (nonatomic, strong, nonnull) NSString *notify_buyer;
@property (nonatomic, strong, nonnull) NSString *expiry_time_loyal_buyer;
@property (nonatomic, strong, nonnull) NSString *notify_seller;
@property (nonatomic, strong, nonnull) NSString *expiry_time_loyal_seller;
@property (nonatomic, strong, nonnull) NSString *link;
@property (nonatomic, strong, nonnull) NSString *content_buyer_1;
@property (nonatomic, strong, nonnull) NSString *content_buyer_2;
@property (nonatomic, strong, nonnull) NSString *content_buyer_3;
@property (nonatomic, strong, nonnull) NSString *content_merchant_1;
@property (nonatomic, strong, nonnull) NSString *content_merchant_2;
@property (nonatomic, strong, nonnull) NSString *content_merchant_3;

@end
