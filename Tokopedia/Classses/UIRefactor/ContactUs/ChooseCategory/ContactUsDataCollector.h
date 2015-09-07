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

@property (nonatomic, strong) TicketCategory *selectedType;
@property (nonatomic, strong) TicketCategory *selectedProblem;
@property (nonatomic, strong) TicketCategory *selectedDetailProblem;
@property (nonatomic, weak) id<ContactUsDataCollectorDelegate> presenter;

- (NSArray *)selectedProblemTitles;
- (NSArray *)selectedProblemDetailTitles;

- (TicketCategory *)selectedProblemWithName:(NSString *)categoryName;
- (TicketCategory *)selectedDetailProblemWithName:(NSString *)categoryName;

@end
