//
//  TicketCategory.h
//  Tokopedia
//
//  Created by Tokopedia on 8/19/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TicketCategory : NSObject

@property (strong, nonatomic) NSArray *ticket_category_child;
@property (strong, nonatomic) NSString *ticket_category_name;
@property (strong, nonatomic) NSString *ticket_category_tree_no;
@property (strong, nonatomic) NSString *ticket_category_description;
@property (strong, nonatomic) NSString *ticket_category_id;

@end
