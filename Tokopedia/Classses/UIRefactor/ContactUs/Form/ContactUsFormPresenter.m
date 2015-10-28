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

- (void)showFormWithCategory:(TicketCategory *)category {
    [self.interactor getFormModelForCategory:category];
}

- (void)submitTicketMessage:(NSString *)message
                    invoice:(NSString *)invoice
                attachments:(NSArray *)attachments
             ticketCategory:(TicketCategory *)category {
    [self.userInterface showLoadingBar];
    self.dataCollector.message = message;
    self.dataCollector.invoice = invoice;
    self.dataCollector.attachments = attachments;
    self.dataCollector.ticketCategory = category;
    if (attachments.count > 0) {
        [self.interactor uploadContactImages];
    } else {
        [self.interactor createTicketValidation];
    }
}

- (void)resetData {
    [self.dataCollector.selectedImagesCameraController removeAllObjects];
    [self.dataCollector.selectedIndexPathCameraController removeAllObjects];
    [self.dataCollector.uploadedPhotos removeAllObjects];
    [self.dataCollector.uploadedPhotosURL removeAllObjects];
}

- (void)showPhotoPickerFromNavigation:(UINavigationController *)navigation {
    [self.wireframe presentPhotoPickerFromNavigation:navigation];
}

- (void)deletePhotoAtIndex:(NSInteger)index {
    [self.dataCollector.selectedImagesCameraController removeObjectAtIndex:index];
    [self.dataCollector.selectedIndexPathCameraController removeObjectAtIndex:index];
}

- (void)showInboxTicketDetailFromNavigation:(UINavigationController *)navigation {
    [self.wireframe pushToInboxDetailFromNavigation:navigation];
}

- (void)showInboxTicketFromNavigation:(UINavigationController *)navigation {
    [self.wireframe pushToInboxTicketFromNavigation:navigation];
}

#pragma mark - Interactor output

- (void)didReceiveFormModel:(ContactUsActionResponse *)response {
    ContactUsActionResultStatus *status = [response.result.list objectAtIndex:0];
    [self.userInterface showLoadingBar];
    if ([status.ticket_category_attachment_status boolValue]) {
        [self.userInterface showPhotoPicker];
    }
    if ([status.ticket_category_invoice_status boolValue]) {
        [self.userInterface showInvoiceInputTextField];
    }
    [self.userInterface showSubmitButton];
}

- (void)didSuccessCreateTicket:(NSString *)ticketCategoryId {
    self.dataCollector.inboxTicketId = ticketCategoryId;
    [self.userInterface redirectToInboxTicketDetail];
    [self.userInterface showSubmitButton];

    [[NSNotificationCenter defaultCenter] postNotificationName:@"ResetContactUsForm" object:nil];
}

- (void)didReceiveCreateTicketError:(NSArray *)error {
    [self.userInterface showSubmitButton];
    [self.userInterface showErrorMessages:error];
}

- (void)didReceivePostKey:(NSString *)postKey {
    NSString *fileUploaded = self.dataCollector.fileUploaded;
    [self.interactor createTicketWithPostKey:postKey fileUploaded:fileUploaded];
}

- (void)didAddStatistic {
    
}

- (void)didReceiveUploadedPhoto:(UIImage *)photo urlPath:(NSString *)urlPath {
    [self.userInterface showUploadedPhoto:photo];
    [self.dataCollector addUploadedPhoto:photo photoURL:urlPath];
    if ([self.dataCollector allPhotosUploaded]) {
        [self.interactor replyTicketPictures];
    }
}

- (void)didFailedUploadPhoto:(UIImage *)photo {
    [self.userInterface removeFailUploadPhoto:photo];
}

- (void)didReceiveFileUploaded:(NSString *)fileUploaded {
    self.dataCollector.failPhotoUpload = YES;
    self.dataCollector.fileUploaded = fileUploaded;
    [self.interactor createTicketValidation];
}

#pragma mark - Camera Delegate

-(void)didDismissController:(CameraCollectionViewController *)controller withUserInfo:(NSDictionary *)photosData {
    NSMutableArray *selectedImages = [NSMutableArray arrayWithArray:[photosData objectForKey:@"selected_images"]];
    NSMutableArray *selectedIndexPaths = [NSMutableArray arrayWithArray:[photosData objectForKey:@"selected_indexpath"]];
    
    for (NSDictionary *imageData in selectedImages) {
        [self.dataCollector addImageFromImageController:imageData];
    }
    
    for (NSDictionary *indexPath in selectedIndexPaths) {
        [self.dataCollector addIndexPathFromImageController:indexPath];
    }
        
    NSArray *selectedPhotos = [self.dataCollector getPhotosFromPhotoPickerData:photosData];
    [self.userInterface showSelectedPhotos:selectedPhotos];    
}


@end