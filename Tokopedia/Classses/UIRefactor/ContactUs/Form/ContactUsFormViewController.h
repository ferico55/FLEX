//
//  ContactUsFormViewController.h
//  Tokopedia
//
//  Created by Tokopedia on 8/13/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TicketCategory.h"
#import "ContactUsFormModuleInterface.h"
#import "ContactUsFormViewInterface.h"

@interface ContactUsFormViewController : UIViewController <ContactUsFormViewInterface>

@property (nonatomic, strong) TicketCategory *mainCategory;
@property (nonatomic, strong) NSArray *subCategories;
@property (nonatomic, strong) id<ContactUsFormModuleInterface> eventHandler;

@end
