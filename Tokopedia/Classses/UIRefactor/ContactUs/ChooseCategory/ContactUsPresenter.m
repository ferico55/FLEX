//
//  ContactUsPresenter.m
//  Tokopedia
//
//  Created by Tokopedia on 9/2/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "ContactUsPresenter.h"
#import "ContactUsWireframe.h"
#import "ContactUsDataCollector.h"

@implementation ContactUsPresenter

- (id)init {
    self = [super init];
    if (self) {
        self.dataCollector = [ContactUsDataCollector new];
    }
    return self;
}

#pragma mark - Input

- (void)updateView {
    [self.interactor loadTicketCategory];
}

- (void)didTapProblem {
    [self.interactor loadProblem];
}

- (void)didTapContactUsButtonWithType:(TicketCategory *)type
                      selectedProblem:(TicketCategory *)selectedProblem
                selectedDetailProblem:(TicketCategory *)selectedDetailProblem
                       fromNavigation:(UINavigationController *)navigation {
    self.dataCollector.selectedType = type;
    self.dataCollector.selectedProblem = selectedProblem;
    self.dataCollector.selectedDetailProblem = selectedDetailProblem;
    [self.wireframe pushContactUsFormViewFromNavigation:navigation];
}

- (void)didSelectContactUsType:(TicketCategory *)type
               selectedProblem:(TicketCategory *)selectedProblem
                fromNavigation:(UINavigationController *)navigation {
    self.dataCollector.selectedType = type;
    self.dataCollector.selectedProblem = selectedProblem;
    [self.wireframe pushContactUsProblemFromNavigation:navigation];
}

- (void)didSelectProblem:(TicketCategory *)problem
   selectedDetailProblem:(TicketCategory *)detailProblem
          fromNavigation:(UINavigationController *)navigation {
    self.dataCollector.selectedProblem = problem;
    self.dataCollector.selectedDetailProblem = detailProblem;
    [self.wireframe pushContactUsProblemDetailFromNavigation:navigation];
}

#pragma mark - Output

- (void)didReceiveTicketCategoryResponse:(ContactUsResponse *)response {
    [self.userInterface showContactUsFormData:response.result.list];
}

- (void)didReceiveProblem:(id)problem {

}

#pragma mark - General table delegate

- (void)didSelectObject:(id)object senderIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            TicketCategory *ticketCategory = [self.dataCollector selectedProblemWithName:object];
            [self.userInterface setSelectedProblem:ticketCategory];
        } else if (indexPath.row == 1) {
            TicketCategory *detailTicketCategory = [self.dataCollector selectedDetailProblemWithName:object];
            [self.userInterface setSelectedDetailProblem:detailTicketCategory];
        }
    }
}

@end
