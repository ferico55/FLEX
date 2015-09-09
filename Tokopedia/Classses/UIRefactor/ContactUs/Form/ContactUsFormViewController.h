//
//  ContactUsFormViewController.h
//  Tokopedia
//
//  Created by Tokopedia on 8/13/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TicketCategory.h"

@interface ContactUsFormViewController : UIViewController

@property (nonatomic, strong) TicketCategory *contactUsType;
@property (nonatomic, strong) TicketCategory *problem;
@property (nonatomic, strong) TicketCategory *detailProblem;

@end
