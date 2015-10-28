//
//  ContactUsFormInteractorIO.h
//  Tokopedia
//
//  Created by Tokopedia on 9/7/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ContactUsActionResponse.h"
#import "TicketCategory.h"
#import "GenerateHost.h"

@protocol ContactUsFormInteractorInput <NSObject>

- (void)getFormModelForCategory:(TicketCategory *)category;
- (void)createTicketValidation;
- (void)replyTicketPictures;
- (void)createTicketWithPostKey:(NSString *)postKey fileUploaded:(NSString *)fileUploaded;
- (void)addTicketCategoryStatistic;
- (void)uploadContactImages;

@end

@protocol ContactUsFormInteractorOutput <NSObject>

- (void)didReceiveFormModel:(ContactUsActionResponse *)response;

- (void)didSuccessCreateTicket:(NSString *)ticketCategoryId;
- (void)didReceiveCreateTicketError:(NSArray *)errorMessages;

- (void)didAddStatistic;

- (void)didReceiveUploadedPhoto:(UIImage *)photo urlPath:(NSString *)urlPath;
- (void)didFailedUploadPhoto:(UIImage *)photo;

- (void)didReceiveFileUploaded:(NSString *)fileUploaded;
- (void)didReceivePostKey:(NSString *)postKey;

@end