//
//  ContactUsPresenter.m
//  Tokopedia
//
//  Created by Tokopedia on 9/2/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "ContactUsPresenter.h"
#import "ContactUsWireframe.h"

@implementation ContactUsPresenter

#pragma mark - Input

- (void)updateView {
    [self.interactor loadTicketCategory];
}

- (void)didTapProblem {
    [self.interactor loadProblem];
}

- (void)didTapContactUsButton {

}

- (void)didSelectContactUsProblem:(NSArray *)problemChoices {
    [self.wireframe pushContactUsProblemChoicesFromNavigation:self.userInterface.navigationController];
}

- (void)didSelectContactUsProblemDetail:(NSArray *)problemDetailChoices {
    
}

#pragma mark - Output

- (void)didReceiveTicketCategoryResponse:(ContactUsResponse *)response {
    [self.userInterface showContactUsFormData:response.result.list];
}

- (void)didReceiveProblem:(id)problem {

}



@end
