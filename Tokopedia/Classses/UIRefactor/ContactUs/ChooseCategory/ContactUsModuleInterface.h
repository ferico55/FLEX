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

- (void)didSelectCategoryChoices:(NSArray *)categories
            withSelectedCategory:(TicketCategory *)selectedCategory
                 senderIndexPath:(NSIndexPath *)indexPath
                  fromNavigation:(UINavigationController *)navigation;

- (void)didTapContactUsButtonWithMainCategory:(TicketCategory *)mainCategory
                                subCategories:(NSArray *)subCategories
                               fromNavigation:(UINavigationController *)navigation;

@end