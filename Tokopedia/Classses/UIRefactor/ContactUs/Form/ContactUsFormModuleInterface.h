//
//  ContactUsFormModuleInterface.h
//  Tokopedia
//
//  Created by Tokopedia on 9/7/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "TicketCategory.h"

@protocol ContactUsFormModuleInterface <NSObject>

- (void)showFormWithCategory:(TicketCategory *)category;

- (void)resetData;

- (void)submitTicketMessage:(NSString *)message
                    invoice:(NSString *)invoice
                attachments:(NSArray *)attachments
             ticketCategory:(TicketCategory *)category;

- (void)showPhotoPickerFromNavigation:(UINavigationController *)navigation;

- (void)showInboxTicketDetailFromNavigation:(UINavigationController *)navigation;

- (void)showInboxTicketFromNavigation:(UINavigationController *)navigation;

@end