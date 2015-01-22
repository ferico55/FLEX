//
//  NotificationRequest.m
//  Tokopedia
//
//  Created by Tokopedia PT on 12/17/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "NotificationRequest.h"
#import "NotificationResult.h"
#import "string_notification.h"

@interface NotificationRequest () {

    __weak RKObjectManager *_objectManager;
    __weak RKManagedObjectRequestOperation *_request;
    
    NSInteger _requestCount;
    
    NSOperationQueue *_operationQueue;
    
    Notification *_notification;
    
}

@end

@implementation NotificationRequest

- (id)init
{
    self = [super init];
    if (self) {
        _requestCount = 0;
        _operationQueue = [[NSOperationQueue alloc] init];
    }
    return self;
}

- (void)loadNotification
{
    [self configureReskit];
    [self loadData];
}

- (void)configureReskit
{
    // initialize RestKit
    _objectManager =  [RKObjectManager sharedClient];
    
    // setup object mappings
    RKObjectMapping *notificationStatusMapping = [RKObjectMapping mappingForClass:[Notification class]];
    [notificationStatusMapping addAttributeMappingsFromDictionary:@{kTKPD_APISTATUSKEY:kTKPD_APISTATUSKEY,
                                                                    kTKPD_APISERVERPROCESSTIMEKEY:kTKPD_APISERVERPROCESSTIMEKEY
                                                                    }];
    
    RKObjectMapping *notificationResultMapping = [RKObjectMapping mappingForClass:[NotificationResult class]];
    [notificationResultMapping addAttributeMappingsFromArray:@[API_NOTIFICATION_TOTAL_CART,
                                                               API_NOTIFICATION_RESOLUTION,
                                                               API_NOTIFICATION_INCR_NOTIF,
                                                               API_NOTIFICATION_TOTAL_NOTIF]];
    
    [notificationStatusMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:kTKPD_APIRESULTKEY
                                                                                              toKeyPath:kTKPD_APIRESULTKEY
                                                                                            withMapping:notificationResultMapping]];
    
    
    RKObjectMapping *notificationSalesMapping = [RKObjectMapping mappingForClass:[NotificationSales class]];
    [notificationSalesMapping addAttributeMappingsFromDictionary:@{API_SALES_NEW_ORDER : API_SALES_NEW_ORDER,
                                                                   API_SALES_SHIPPING_CONFIRM : API_SALES_SHIPPING_CONFIRM,
                                                                   API_SALES_SHIPPING_STATUS : API_SALES_SHIPPING_STATUS}];
    
    [notificationResultMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:API_NOTIFICATION_SALES
                                                                                              toKeyPath:API_NOTIFICATION_SALES
                                                                                            withMapping:notificationSalesMapping]];
    
    
    RKObjectMapping *notificationPurchaseMapping = [RKObjectMapping mappingForClass:[NotificationPurchase class]];
    [notificationPurchaseMapping addAttributeMappingsFromDictionary:@{API_PURCHASE_REORDER : API_PURCHASE_REORDER,
                                                                      API_PURCHASE_DELIVERY_CONFIRM : API_PURCHASE_DELIVERY_CONFIRM,
                                                                      API_PURCHASE_PAYMENT_CONF : API_PURCHASE_PAYMENT_CONF,
                                                                      API_PURCHASE_PAYMENT_CONFIRM : API_PURCHASE_PAYMENT_CONFIRM,
                                                                      API_PURCHASE_ORDER_STATUS : API_PURCHASE_ORDER_STATUS, }];
    
    [notificationResultMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:API_NOTIFICATION_PURCHASE
                                                                                              toKeyPath:API_NOTIFICATION_PURCHASE
                                                                                            withMapping:notificationPurchaseMapping]];
    
    
    RKObjectMapping *notificationInboxMapping = [RKObjectMapping mappingForClass:[NotificationInbox class]];
    [notificationInboxMapping addAttributeMappingsFromDictionary:@{API_INBOX_FRIEND : API_INBOX_FRIEND,
                                                                   API_INBOX_MESSAGE : API_INBOX_MESSAGE,
                                                                   API_INBOX_REVIEW : API_INBOX_REVIEW,
                                                                   API_INBOX_TALK : API_INBOX_TALK,
                                                                   API_INBOX_WHISHLIST : API_INBOX_WHISHLIST,
                                                                   API_INBOX_TICKET : API_INBOX_TICKET, }];
    
    [notificationResultMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:API_NOTIFICATION_INBOX
                                                                                              toKeyPath:API_NOTIFICATION_INBOX
                                                                                            withMapping:notificationInboxMapping]];
    
    
    RKResponseDescriptor *notificationDescriptorStatus = [RKResponseDescriptor responseDescriptorWithMapping:notificationStatusMapping
                                                                                                      method:RKRequestMethodPOST
                                                                                                 pathPattern:API_NOTIFICATION_PATH
                                                                                                     keyPath:@""
                                                                                                 statusCodes:kTkpdIndexSetStatusCodeOK];
    
    [_objectManager addResponseDescriptor:notificationDescriptorStatus];
}

- (void)loadData
{
    if (_request.isExecuting) return;
    
    _requestCount++;
    
    NSDictionary *param = @{API_NOTIFICATION_ACTION : API_NOTIFICATION_GET_DETAIL};
    
    _request = [_objectManager appropriateObjectRequestOperationWithObject:self
                                                                    method:RKRequestMethodPOST
                                                                      path:API_NOTIFICATION_PATH
                                                                parameters:[param encrypt]];
    
    [_request setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        [self requestSuccess:mappingResult withOperation:operation];
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        [self requestFailure:error];
    }];
    
    [_operationQueue addOperation:_request];
}

-(void)requestSuccess:(id)object withOperation:(RKObjectRequestOperation *)operation
{
    NSDictionary *result = ((RKMappingResult*)object).dictionary;
    if (result) {
        _notification = [result objectForKey:@""];
        [self.delegate didReceiveNotification:_notification];
    }
}

- (void)requestFailure:(NSError *)error
{
    
}

@end
