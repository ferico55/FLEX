//
//  ContactUsDataCollector.m
//  Tokopedia
//
//  Created by Tokopedia on 9/4/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "ContactUsDataCollector.h"
#import "GeneralTableViewController.h"

@interface ContactUsDataCollector () <GeneralTableViewControllerDelegate>

@end

@implementation ContactUsDataCollector

- (NSArray *)categoryTitles {
    NSMutableArray *titles = [NSMutableArray new];
    for (TicketCategory *childCategory in _subCategories) {
        [titles addObject:childCategory.ticket_category_name];
    }
    return titles;
}

- (TicketCategory *)categoryWithCategoryName:(NSString *)categoryName {
    TicketCategory *selectedCategory;
    for (TicketCategory *category in _subCategories) {
        if ([category.ticket_category_name isEqualToString:categoryName]) {
            selectedCategory = category;
        }
    }
    return selectedCategory;
}

@end
