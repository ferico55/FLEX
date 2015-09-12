//
//  ContactUsFormPresenter.m
//  Tokopedia
//
//  Created by Tokopedia on 9/7/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "ContactUsFormPresenter.h"
#import "ContactUsActionResultStatus.h"

#import "CameraAlbumListViewController.h"
#import "CameraCollectionViewController.h"

@implementation ContactUsFormPresenter

- (id)init {
    self = [super init];
    if (self) {
        self.dataCollector = [ContactUsFormDataCollector new];
    }
    return self;
}

- (void)showFormWithCategory:(TicketCategory *)category {
    [self.interactor getFormModelForCategory:category];
}

- (void)submitTicketMessage:(NSString *)message
                    invoice:(NSString *)invoice
                attachments:(NSArray *)attachments
             ticketCategory:(TicketCategory *)category {
    [self.interactor createTicketValidationWithMessage:message
                                               invoice:invoice
                                           attachments:attachments
                                        ticketCategory:category
                                              serverId:@""];
}

- (void)showPhotoPickerFromNavigation:(UINavigationController *)navigation {
    [self.wireframe presentPhotoPickerFromNavigation:navigation];
}

#pragma mark - Interactor output

- (void)didReceiveFormModel:(ContactUsActionResponse *)response {
    ContactUsActionResultStatus *status = [response.result.list objectAtIndex:0];
    if ([status.ticket_category_attachment_status boolValue]) {
        [self.userInterface showPhotoPicker];
    }
    if ([status.ticket_category_invoice_status boolValue]) {
        [self.userInterface showInvoiceInputTextField];
    }
}

- (void)didSuccessCreateTicket {
    
}

- (void)didReceiveCreateTicketError:(NSError *)error {
    
}

- (void)didReceivePostKey:(NSString *)postKey {
    [self.interactor createTicketWithPostKey:postKey fileUploaded:@""];
}

- (void)didReceiveTicketValidationError:(NSArray *)errorMessages {
    [self.userInterface showErrorMessages:errorMessages];
}

- (void)didAddStatistic {
    
}

#pragma mark - Camera Delegate

-(void)didDismissController:(CameraCollectionViewController *)controller withUserInfo:(NSDictionary *)photosData
{
    NSArray *selectedPhotos = [self.dataCollector getPhotosFromPhotoPickerData:photosData];
    [self.userInterface showSelectedPhotos:selectedPhotos];
}


@end