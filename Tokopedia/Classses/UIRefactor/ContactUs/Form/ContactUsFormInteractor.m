//
//  ContactUsFormInteractor.m
//  Tokopedia
//
//  Created by Tokopedia on 9/7/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "ContactUsFormInteractor.h"
#import "ContactUsFormDataManager.h"
#import "ContactUsQuery.h"

#import "GenerateHost.h"
#import "RequestGenerateHost.h"

#import "RequestUploadImage.h"

#import "camera.h"

@interface ContactUsFormInteractor () <GenerateHostDelegate, RequestUploadImageDelegate>

@property (nonatomic, strong) ContactUsFormDataManager *dataManager;
@property (nonatomic, strong) RequestGenerateHost *requestHost;

@end

@implementation ContactUsFormInteractor

- (id)init {
    self = [super init];
    if (self) {
        self.dataManager = [ContactUsFormDataManager new];
        self.requestHost = [RequestGenerateHost new];
        self.requestHost.delegate = self;
    }
    return self;
}

- (void)getFormModelForCategory:(TicketCategory *)category {
    __weak typeof(self) welf = self;
    ContactUsQuery *query = [ContactUsQuery new];
    query.action = @"get_form_model_contact_us";
    query.ticketCategoryId = category.ticket_category_id;
    [self.dataManager requestFormModelWithQuery:query
                                       response:^(ContactUsActionResponse *response) {
                                           [welf.output didReceiveFormModel:response];
                                       } errorMessages:^(NSArray *errorMessages) {
                                           
                                       }];
}

- (void)createTicketValidation {
    __weak typeof(self) welf = self;
    ContactUsQuery *query = [ContactUsQuery new];
    query.action = @"create_ticket_validation";
    query.messageCategory = self.dataCollector.ticketCategory.ticket_category_id;
    query.messageBody = self.dataCollector.message;
    query.attachmentString = self.dataCollector.attachmentString;
    query.invNumber = self.dataCollector.invoice;
    query.serverId = self.dataCollector.generateHost.result.generated_host.server_id;
    [self.dataManager requestTicketValidationWithQuery:query
                                              response:^(ContactUsActionResponse *response) {
        BOOL isSuccess = [response.result.is_success boolValue];
        NSString *ticketId = response.result.ticket_inbox_id;
        if (self.dataCollector.uploadedPhotosURL.count > 0 && response.result.post_key) {
            [welf.output didReceivePostKey:response.result.post_key];
        } else if (isSuccess || ticketId) {
            [welf.output didSuccessCreateTicket:ticketId];
        } else {
            NSArray *errorMessage = response.message_error;
            if (errorMessage) {
                [welf.output didReceiveCreateTicketError:errorMessage];
            }            
        }
    } errorMessages:^(NSArray *errorMessages) {
        [welf.output didReceiveCreateTicketError:errorMessages];
    }];
}

- (void)replyTicketPictures {
    __weak typeof(self) welf = self;
    ContactUsQuery *query = [ContactUsQuery new];
    query.action = @"reply_ticket_picture";
    query.messageCategory = self.dataCollector.ticketCategory.ticket_category_id;
    query.messageBody = self.dataCollector.message;
    query.attachmentString = self.dataCollector.attachmentString;
    query.invNumber = self.dataCollector.invoice;
    query.serverId = self.dataCollector.generateHost.result.generated_host.server_id;
    GenerateHost *host = self.dataCollector.generateHost;
    [self.dataManager replyTicketPictureWithQuery:query
                                             host:host
                                         response:^(ReplyInboxTicket *response) {
                                             if (response.result.file_uploaded) {
                                                 [welf.output didReceiveFileUploaded:response.result.file_uploaded];
                                             }
    } errorMessages:^(NSArray *errorMessages) {
        [welf.output didReceiveCreateTicketError:errorMessages];
    }];
}

- (void)createTicketWithPostKey:(NSString *)postKey
                   fileUploaded:(NSString *)fileUploaded {
    __weak typeof(self) welf = self;
    ContactUsQuery *query = [ContactUsQuery new];
    query.action = @"create_ticket";
    query.postKey = postKey;
    query.fileUploaded = fileUploaded;
    query.ticketCategoryId = self.dataCollector.ticketCategory.ticket_category_id;
    [self.dataManager requestCreateTicketWithQuery:query
                                          response:^(ContactUsActionResponse *response) {
                                              if ([response.result.is_success boolValue]) {
                                                  NSString *ticketId = response.result.ticket_inbox_id;
                                                  [welf.output didSuccessCreateTicket:ticketId];
                                              } else if (response.message_error) {
                                                  [welf.output didReceiveCreateTicketError:response.message_error];
                                              }
    } errorMessages:^(NSArray *errorMessages) {
        [welf.output didReceiveCreateTicketError:errorMessages];
    }];
}

- (void)addTicketCategoryStatistic {
    
}

- (void)uploadContactImages {
    if (self.dataCollector.generateHost) {
        for (NSDictionary *photoData in self.dataCollector.selectedImagesCameraController) {
            [self uploadImage:@{DATA_SELECTED_PHOTO_KEY : photoData} host:self.dataCollector.generateHost];
        }
    } else {
        [self.requestHost requestGenerateHost];
    }
}

#pragma mark Request Generate Host

- (void)successGenerateHost:(GenerateHost *)generateHost
{
    self.dataCollector.generateHost = generateHost;
    for (NSDictionary *photoData in self.dataCollector.selectedImagesCameraController) {
        [self uploadImage:@{DATA_SELECTED_PHOTO_KEY : photoData} host:generateHost];
    }
}

- (void)failedGenerateHost:(NSArray *)errorMessages {
    [self.output didReceiveCreateTicketError:errorMessages];
}

#pragma mark - Upload image delegate

- (void)uploadImage:(NSDictionary *)imageData host:(GenerateHost *)host {
    RequestUploadImage *uploadImage = [RequestUploadImage new];
    [uploadImage requestActionUploadObject:imageData
                             generatedHost:host.result.generated_host
                                    action:@"upload_contact_image"
                                    newAdd:1
                                 productID:@""
                                 paymentID:@""
                                 fieldName:@"fileToUpload"
                                   success:^(id imageObject, UploadImage *image) {
                                       [self successUploadObject:imageObject withMappingResult:image];
    } failure:^(id imageObject, NSError *error) {
        [self failedUploadObject:imageObject];
    }];
}

- (void)successUploadObject:(id)object withMappingResult:(UploadImage *)uploadImage {
    NSDictionary *data = [object objectForKey:DATA_SELECTED_PHOTO_KEY];
    NSDictionary *photo = [data objectForKey:kTKPDCAMERA_DATAPHOTOKEY];
    UIImage *image = [photo objectForKey:@"photo"];
    [self.output didReceiveUploadedPhoto:image urlPath:uploadImage.result.file_path];
}

- (void)failedUploadObject:(id)object {
    NSDictionary *data = [object objectForKey:DATA_SELECTED_PHOTO_KEY];
    NSDictionary *photo = [data objectForKey:kTKPDCAMERA_DATAPHOTOKEY];
    UIImage *image = [photo objectForKey:@"photo"];
    NSInteger index = [self.dataCollector.selectedImagesCameraController indexOfObject:data];
    if (index) {
        if (self.dataCollector.selectedImagesCameraController.count > index) {
            [self.dataCollector.selectedImagesCameraController removeObjectAtIndex:index];
        }
        if (self.dataCollector.selectedIndexPathCameraController.count > index) {
            [self.dataCollector.selectedIndexPathCameraController removeObjectAtIndex:index];
        }
    }
    [self.output didFailedUploadPhoto:image];
}

@end
