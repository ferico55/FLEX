//
//  ContactUsFormViewInterface.h
//  Tokopedia
//
//  Created by Tokopedia on 9/9/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ContactUsFormViewInterface <NSObject>

- (void)showInvoiceInputTextField;
- (void)showPhotoPicker;
- (void)showErrorMessages:(NSArray *)errorMessages;
- (void)showSelectedPhotos:(NSArray *)photos;
- (void)redirectToInboxTicketDetail;
- (void)showUploadedPhoto:(UIImage *)image;
- (void)removeFailUploadPhoto:(UIImage *)image;

@end
