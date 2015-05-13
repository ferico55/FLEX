//
//  NotificationRequest.m
//  Tokopedia
//
//  Created by Tokopedia PT on 12/17/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "NotificationRequest.h"
#import "NotificationResult.h"
#import "GeneralAction.h"
#import "string_notification.h"

#import "URLCacheController.h"
#import "UserAuthentificationManager.h"

#import "TokopediaNetworkManager.h"

@interface NotificationRequest () <TokopediaNetworkManagerDelegate>
{
    
    __weak RKObjectManager *_objectManager;
    __weak RKManagedObjectRequestOperation *_request;
    NSInteger _requestCount;
    NSOperationQueue *_operationQueue;
    
    __weak RKObjectManager *_objectresetNotification;
    __weak RKManagedObjectRequestOperation *_requestResetNotification;
    NSInteger _requestResetNotificationCount;
    NSOperationQueue *_operationresetNotificationQueue;
    
    Notification *_notification;
    URLCacheController *_cachecontroller;
    URLCacheConnection *_cacheconnection;
    NSString *_cachepath;
    NSTimeInterval _timeinterval;
    UserAuthentificationManager *_userManager;
    
    TokopediaNetworkManager *_networkManager;
}

@end

@implementation NotificationRequest

- (id)init
{
    self = [super init];
    if (self) {
        _requestCount = 0;
        _operationQueue = [[NSOperationQueue alloc] init];
        
        _requestResetNotificationCount = 0;
        _operationresetNotificationQueue = [[NSOperationQueue alloc] init];
        
        _cacheconnection = [URLCacheConnection new];
        _cachecontroller = [URLCacheController new];
        _userManager = [UserAuthentificationManager new];
        
        _networkManager = [TokopediaNetworkManager new];
    }
    return self;
}

- (void)loadNotification
{
    _networkManager.delegate = self;

    [self initCache];
    
    NSData *data = [NSData dataWithContentsOfFile:_cachepath];
    
    if(data) {
        [self loadDataFromCache];
    }
    [_networkManager doRequest];
    
    
}

- (void)initCache
{
    NSString *path = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject]stringByAppendingPathComponent:@"notification-cache"];
    
    _cachepath = [path stringByAppendingPathComponent:@"notification"];
    _cachecontroller.filePath = _cachepath;
    _cachecontroller.URLCacheInterval = 86400.0;
    [_cachecontroller initCacheWithDocumentPath:path];
}

//TODO::delete cache process
- (void)deleteCache
{
    _cachecontroller.URLCacheInterval = 0;
    NSData *data = [NSData dataWithContentsOfFile:_cachepath];
    if(data) {
        [_cachecontroller clearCache];
    }
}

-(id)getObjectManager:(int)tag
{
    return [self objectManagerNotification];
}

-(NSDictionary *)getParameter:(int)tag
{
    NSDictionary *param = @{API_NOTIFICATION_ACTION : API_NOTIFICATION_GET_DETAIL};
    return param;
}

-(NSString *)getPath:(int)tag
{
    return API_NOTIFICATION_PATH;
}

-(NSString *)getRequestStatus:(id)result withTag:(int)tag
{
    NSDictionary *resultDict = ((RKMappingResult*)result).dictionary;
    if (result) {
        _notification = [resultDict objectForKey:@""];
        return _notification.status;
    }
    return nil;
}

-(void)actionBeforeRequest:(int)tag
{
    
}

-(void)actionAfterRequest:(id)successResult withOperation:(RKObjectRequestOperation *)operation withTag:(int)tag
{
    [self requestSuccess:successResult withOperation:operation];
}

-(void)actionFailAfterRequest:(id)errorResult withTag:(int)tag
{
    
}

-(void)actionAfterFailRequestMaxTries:(int)tag
{

}

-(RKObjectManager *)objectManagerNotification
{
    // initialize RestKit
    RKObjectManager *objectManager =  [RKObjectManager sharedClient];
    
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
                                                                                                      method:RKRequestMethodGET
                                                                                                 pathPattern:API_NOTIFICATION_PATH
                                                                                                     keyPath:@""
                                                                                                 statusCodes:kTkpdIndexSetStatusCodeOK];
    
    [objectManager addResponseDescriptor:notificationDescriptorStatus];

    return objectManager;
}

-(void)loadDataFromCache {
    [_cachecontroller getFileModificationDate];
    _timeinterval = fabs([_cachecontroller.fileDate timeIntervalSinceNow]);
    
    
    NSError* error;
    NSData *data = [NSData dataWithContentsOfFile:_cachepath];
    
    if(data.length) {
        id parsedData = [RKMIMETypeSerialization objectFromData:data
                                                       MIMEType:RKMIMETypeJSON
                                                          error:&error];
        if (parsedData == nil && error) {
            NSLog(@"parser error");
        }
        
        NSMutableDictionary *mappingsDictionary = [[NSMutableDictionary alloc] init];
        for (RKResponseDescriptor *descriptor in _objectManager.responseDescriptors) {
            [mappingsDictionary setObject:descriptor.mapping forKey:descriptor.keyPath];
        }
        
        RKMapperOperation *mapper = [[RKMapperOperation alloc] initWithRepresentation:parsedData
                                                                   mappingsDictionary:mappingsDictionary];
        NSError *mappingError = nil;
        BOOL isMapped = [mapper execute:&mappingError];
        if (isMapped && !mappingError) {
            RKMappingResult *mappingresult = [mapper mappingResult];
            //            _isrefreshview = YES;
            //            _isNeedToInsertCache = NO;
            [self requestSuccess:mappingresult withOperation:nil];
        }
    }
}

-(void)requestSuccess:(id)object withOperation:(RKObjectRequestOperation *)operation
{
    NSDictionary *result = ((RKMappingResult*)object).dictionary;
    if (result) {
        _notification = [result objectForKey:@""];
        
        //        TODO::here
        [[NSNotificationCenter defaultCenter] postNotificationName:@"setUnreadNotification" object:nil userInfo:@{@"increment_notif" : _notification.result.incr_notif?:@"0"}];
        
        [self.delegate didReceiveNotification:_notification];
        
        [_cacheconnection connection:operation.HTTPRequestOperation.request
                  didReceiveResponse:operation.HTTPRequestOperation.response];
        [_cachecontroller connectionDidFinish:_cacheconnection];
        
        [operation.HTTPRequestOperation.responseData writeToFile:_cachepath atomically:YES];
    }
}

- (void)requestFailure:(NSError *)error
{
    
}

#pragma mark - Read Notification Request
- (void)resetNotification {
    [self configureResetNotificationRestkit];
    [self doresetNotification];
}

- (void) configureResetNotificationRestkit {
    _objectresetNotification =  [RKObjectManager sharedClient];
    
    // setup object mappings
    RKObjectMapping *statusMapping = [RKObjectMapping mappingForClass:[GeneralAction class]];
    [statusMapping addAttributeMappingsFromDictionary:@{kTKPD_APISTATUSKEY:kTKPD_APISTATUSKEY,
                                                        kTKPD_APIERRORMESSAGEKEY:kTKPD_APIERRORMESSAGEKEY,
                                                        kTKPD_APISERVERPROCESSTIMEKEY:kTKPD_APISERVERPROCESSTIMEKEY}];
    
    RKObjectMapping *resultMapping = [RKObjectMapping mappingForClass:[GeneralActionResult class]];
    [resultMapping addAttributeMappingsFromDictionary:@{kTKPD_APIISSUCCESSKEY:kTKPD_APIISSUCCESSKEY}];
    
    //relation
    RKRelationshipMapping *resulRel = [RKRelationshipMapping relationshipMappingFromKeyPath:kTKPD_APIRESULTKEY toKeyPath:kTKPD_APIRESULTKEY withMapping:resultMapping];
    [statusMapping addPropertyMapping:resulRel];
    
    
    //register mappings with the provider using a response descriptor
    RKResponseDescriptor *responseDescriptorStatus = [RKResponseDescriptor responseDescriptorWithMapping:statusMapping method:RKRequestMethodGET pathPattern:API_NOTIFICATION_PATH keyPath:@"" statusCodes:kTkpdIndexSetStatusCodeOK];
    
    [_objectresetNotification addResponseDescriptor:responseDescriptorStatus];
}

- (void)doresetNotification {
    if (_requestResetNotification.isExecuting) return;
    
    _requestResetNotificationCount++;
    
    NSDictionary *param = [@{API_NOTIFICATION_ACTION : API_NOTIFICATION_RESET} encrypt];
    _requestResetNotification = [_objectManager appropriateObjectRequestOperationWithObject:self
                                                                                     method:RKRequestMethodPOST
                                                                                       path:API_NOTIFICATION_PATH
                                                                                 parameters:param];
    
    [_requestResetNotification setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        [self requestResetSuccess:mappingResult withOperation:operation];
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        [self requestResetFailure:error];
    }];
    
    [_operationresetNotificationQueue addOperation:_requestResetNotification];
}

- (void)requestResetSuccess:(id)object withOperation:(RKObjectRequestOperation *)operation {
    NSDictionary *result = ((RKMappingResult*)object).dictionary;
}

- (void)requestResetFailure:(id)error {
    
    
}

-(void)dealloc
{
    [_networkManager requestCancel];
    _networkManager.delegate = nil;
}

@end
