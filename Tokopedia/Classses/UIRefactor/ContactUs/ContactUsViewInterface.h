//
//  ContactUsView.h
//  Tokopedia
//
//  Created by Tokopedia on 9/2/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TicketCategory.h"

@protocol ContactUsViewInterface <NSObject>

- (void)showContactUsFormData:(NSArray *)data;
- (void)setErrorView;
- (void)setRetryView;

- (void)setSelectedProblem:(TicketCategory *)problem;
- (void)setSelectedDetailProblem:(TicketCategory *)detailProblem;

@end