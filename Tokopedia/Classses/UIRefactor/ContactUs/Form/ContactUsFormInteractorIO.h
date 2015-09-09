//
//  ContactUsFormInteractorIO.h
//  Tokopedia
//
//  Created by Tokopedia on 9/7/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ContactUsResponse.h"

@protocol ContactUsFormInteractorInput <NSObject>

- (void)getFormModelContactUs;
- (void)createTicketValidation;
- (void)createTicket;
- (void)addTicketCategoryStatistic;

@end

@protocol ContactUsFormInteractorOutput <NSObject>

- (void)didReceiveTicketCategoryResponse:(ContactUsResponse *)response;
- (void)didReceiveProblem:(id)problem;

@end