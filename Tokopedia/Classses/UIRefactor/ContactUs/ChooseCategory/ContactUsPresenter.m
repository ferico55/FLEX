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

- (void)didTapContactUsButtonWithMainCategory:(TicketCategory *)mainCategory
                                subCategories:(NSArray *)subCategories
                               fromNavigation:(UINavigationController *)navigation {
    self.dataCollector.mainCategory = mainCategory;
    self.dataCollector.subCategories = subCategories;
    [self.wireframe pushContactUsFormViewFromNavigation:navigation];
}

- (void)didSelectCategoryChoices:(NSArray *)categories
            withSelectedCategory:(TicketCategory *)selectedCategory
                 senderIndexPath:(NSIndexPath *)senderIndexPath
                  fromNavigation:(UINavigationController *)navigation {
    self.dataCollector.selectedCategory = selectedCategory;
    self.dataCollector.subCategories = categories;
    self.dataCollector.senderIndexPath = senderIndexPath;
    [self.wireframe pushCategoryFromNavigation:navigation];
}

#pragma mark - Output

- (void)didReceiveTicketCategoryResponse:(ContactUsResponse *)response {
    [self.userInterface showContactUsFormData:response.result.list];
}

- (void)didReceiveProblem:(id)problem {

}

#pragma mark - General table delegate

- (void)didSelectObject:(id)object senderIndexPath:(NSIndexPath *)indexPath {
    TicketCategory *category = [self.dataCollector categoryWithCategoryName:object];
    [self.userInterface setCategory:category atIndexPath:indexPath];
}

@end
