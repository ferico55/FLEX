//
//  TicketCategory.h
//  Tokopedia
//
//  Created by Tokopedia on 8/19/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TicketCategory : NSObject

@property (nonatomic, strong, nonnull) NSArray *ticket_category_child;
@property (nonatomic, strong, nonnull) NSString *ticket_category_name;
@property (nonatomic, strong, nonnull) NSString *ticket_category_tree_no;
@property (nonatomic, strong, nonnull) NSString *ticket_category_description;
@property (nonatomic, strong, nonnull) NSString *ticket_category_id;

@end
