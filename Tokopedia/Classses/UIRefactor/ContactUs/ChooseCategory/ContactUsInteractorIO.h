//
//  ContactUsInteractorIO.h
//  Tokopedia
//
//  Created by Tokopedia on 9/2/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ContactUsResponse.h"

@protocol ContactUsInteractorInput <NSObject>

- (void)loadTicketCategory;

@end

@protocol ContactUsInteractorOutput <NSObject>

- (void)didReceiveTicketCategoryResponse:(ContactUsResponse *)response;
- (void)didReceiveProblem:(id)problem;

@end