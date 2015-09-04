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

- (void)didSelectContactUsType:(TicketCategory *)type
               selectedProblem:(TicketCategory *)selectedProblem
                fromNavigation:(UINavigationController *)navigation;

- (void)didSelectProblem:(TicketCategory *)problem
   selectedDetailProblem:(TicketCategory *)selectedDetailProblem
          fromNavigation:(UINavigationController *)navigation;


- (void)didTapContactUsButton;

@end