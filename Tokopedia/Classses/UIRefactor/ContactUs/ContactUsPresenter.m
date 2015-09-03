//
//  ContactUsPresenter.m
//  Tokopedia
//
//  Created by Tokopedia on 9/2/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "ContactUsPresenter.h"

@implementation ContactUsPresenter

- (void)updateView {
    [self.interactor loadTicketCategory];
}

- (void)didTapProblem {
    [self.interactor loadProblem];
}

- (void)didReceiveTicketCategoryResponse:(ContactUsResponse *)response {
    [self.userInterface showContactUsFormData:response.result.list];
}

- (void)didReceiveProblem:(id)problem {
}

@end
