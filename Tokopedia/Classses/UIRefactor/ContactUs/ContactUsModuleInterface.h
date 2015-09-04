//
//  ContactUsModuleInterface.h
//  Tokopedia
//
//  Created by Tokopedia on 9/2/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TicketCategory.h"

@protocol ContactUsModuleInterface <NSObject>

- (void)updateView;
- (void)didSelectContactUsProblem:(NSArray *)problemChoices;
- (void)didSelectContactUsProblemDetail:(NSArray *)problemDetailChoices;
- (void)didTapContactUsButton;

@end