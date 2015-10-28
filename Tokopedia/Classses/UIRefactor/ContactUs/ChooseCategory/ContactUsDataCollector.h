//
//  ContactUsDataCollector.h
//  Tokopedia
//
//  Created by Tokopedia on 9/4/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TicketCategory.h"

@protocol ContactUsDataCollectorDelegate <NSObject>

- (void)didReceiveSelectedType:(TicketCategory *)category;
- (void)didReceiveSelectedProblem:(TicketCategory *)category;
- (void)didReceiveSelectedDetailProblem:(TicketCategory *)category;

@end

@interface ContactUsDataCollector : NSObject

@property (nonatomic, strong) TicketCategory *mainCategory;
@property (nonatomic, strong) TicketCategory *selectedCategory;
@property (nonatomic, strong) NSArray *subCategories;
@property (nonatomic, strong) NSIndexPath *senderIndexPath;
@property (nonatomic, weak) id<ContactUsDataCollectorDelegate> presenter;

- (NSArray *)categoryTitles;
- (TicketCategory *)categoryWithCategoryName:(NSString *)categoryName;

@end
