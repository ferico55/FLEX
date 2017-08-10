//
//  MyReviewDetailHeaderComponent.h
//  Tokopedia
//
//  Created by Kenneth Vincent on 2/25/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import <ComponentKit/ComponentKit.h>
#import "DetailMyInboxReputation.h"
#import "MyReviewDetailHeader.h"

@interface MyReviewDetailHeaderComponent : CKCompositeComponent

+ (instancetype)newWithInbox:(DetailMyInboxReputation*)inbox
                     context:(MyReviewDetailContext*)context;

- (void)didTapBuyerReputation:(id)sender;
- (void)didTapSellerReputation:(id)sender;

@end
