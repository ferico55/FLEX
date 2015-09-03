//
//  ContactUsInteractor.m
//  Tokopedia
//
//  Created by Tokopedia on 9/2/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "ContactUsInteractor.h"
#import "ContactUsDataManager.h"

@interface ContactUsInteractor ()

@property (nonatomic, strong) ContactUsDataManager *dataManager;

@end

@implementation ContactUsInteractor

- (id)init {
    self = [super init];
    if (self) {
        self.dataManager = [ContactUsDataManager new];
    }
    return self;
}

- (void)loadTicketCategory {
    __weak typeof(self) welf = self;
    [self.dataManager requestTicketCategoriesResponse:^(ContactUsResponse *response) {
        [welf.output didReceiveTicketCategoryResponse:response];
    } error:^(NSError *error) {
        
    }];
}

@end
