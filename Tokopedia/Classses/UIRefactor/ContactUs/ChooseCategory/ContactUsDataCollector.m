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

- (void)didSelectObject:(id)object senderIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            
        } else if (indexPath.row == 1) {
            
        }
    }
}

- (NSArray *)selectedProblemTitles {
    NSMutableArray *titles = [NSMutableArray new];
    for (TicketCategory *category in _selectedType.ticket_category_child) {
        [titles addObject:category.ticket_category_name];
    }
    return titles;
}

- (NSArray *)selectedProblemDetailTitles {
    NSMutableArray *titles = [NSMutableArray new];
    for (TicketCategory *category in _selectedProblem.ticket_category_child) {
        [titles addObject:category.ticket_category_name];
    }
    return titles;
}

- (TicketCategory *)selectedProblemWithName:(NSString *)categoryName {
    TicketCategory *selectedCategory;
    for (TicketCategory *category in self.selectedType.ticket_category_child) {
        if ([category.ticket_category_name isEqualToString:categoryName]) {
            selectedCategory = category;
            self.selectedProblem = category;
        }
    }
    return selectedCategory;
}

- (TicketCategory *)selectedDetailProblemWithName:(NSString *)categoryName {
    TicketCategory *selectedCategory;
    for (TicketCategory *category in self.selectedProblem.ticket_category_child) {
        if ([category.ticket_category_name isEqualToString:categoryName]) {
            selectedCategory = category;
            self.selectedDetailProblem = category;
        }
    }
    return selectedCategory;
}

@end
