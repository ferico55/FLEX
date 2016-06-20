//
//  NotificationRequest.m
//  Tokopedia
//
//  Created by Tokopedia PT on 12/17/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "NotificationRequest.h"
#import "GeneralAction.h"
#import "URLCacheController.h"
#import "UserAuthentificationManager.h"

@interface NotificationRequest ()

@property (strong, nonatomic) Notification *notification;

@property (strong, nonatomic) URLCacheController *cacheController;
@property (strong, nonatomic) URLCacheConnection *cacheConnection;
@property (strong, nonatomic) NSString *cachePath;
@property NSTimeInterval timeInterval;

@property (strong, nonatomic) UserAuthentificationManager *userManager;
@property (strong, nonatomic) TokopediaNetworkManager *networkManager;

@end

@implementation NotificationRequest

- (id)init {
    self = [super init];
    if (self) {
        self.cacheConnection = [URLCacheConnection new];
        self.cacheController = [URLCacheController new];
        self.userManager = [UserAuthentificationManager new];
        self.networkManager = [TokopediaNetworkManager new];
        self.networkManager.isUsingHmac = YES;
    }
    return self;
}

- (void)loadNotification {
    [self initCache];
    NSData *data = [NSData dataWithContentsOfFile:_cachePath];
    if(data) {
        [self loadDataFromCache];
    }
    [self loadData];    
}

- (void)initCache {
    NSString *path = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject]stringByAppendingPathComponent:@"notification-cache"];
    self.cachePath = [path stringByAppendingPathComponent:@"notification"];
    self.cacheController.filePath = _cachePath;
    self.cacheController.URLCacheInterval = 86400.0;
    [self.cacheController initCacheWithDocumentPath:path];
}

//TODO::delete cache process

- (void)deleteCache {
    self.cacheController.URLCacheInterval = 0;
    NSData *data = [NSData dataWithContentsOfFile:_cachePath];
    if(data) {
        [self.cacheController clearCache];
    }
}

- (void)loadData {
    [self.networkManager requestWithBaseUrl:[NSString v4Url]
                                       path:@"/v4/notification/get_notification.pl"
                                     method:RKRequestMethodGET
                                  parameter:@{}
                                    mapping:[Notification mapping]
                                  onSuccess:^(RKMappingResult *mappingResult,
                                              RKObjectRequestOperation *operation) {
                                      [self requestSuccess:mappingResult withOperation:operation];
                                  } onFailure:nil];
}

- (void)loadDataFromCache {
    [self.cacheController getFileModificationDate];
    
    self.timeInterval = fabs([self.cacheController.fileDate timeIntervalSinceNow]);
    
    NSError *error;
    
    NSData *data = [NSData dataWithContentsOfFile:_cachePath];
    
    if(data.length) {
        id parsedData = [RKMIMETypeSerialization objectFromData:data
                                                       MIMEType:RKMIMETypeJSON
                                                          error:&error];
        if (parsedData == nil && error) {
            NSLog(@"parser error");
        }
        
        NSMutableDictionary *mappingsDictionary = [[NSMutableDictionary alloc] init];
        RKObjectManager *objectManager = [RKObjectManager sharedManager];
        for (RKResponseDescriptor *descriptor in objectManager.responseDescriptors) {
            [mappingsDictionary setObject:descriptor.mapping forKey:descriptor.keyPath];
        }
        
        RKMapperOperation *mapper = [[RKMapperOperation alloc] initWithRepresentation:parsedData
                                                                   mappingsDictionary:mappingsDictionary];
        NSError *mappingError = nil;
        BOOL isMapped = [mapper execute:&mappingError];
        if (isMapped && !mappingError) {
            RKMappingResult *mappingresult = [mapper mappingResult];
            [self requestSuccess:mappingresult withOperation:nil];
        }
    }
}

-(void)requestSuccess:(id)object withOperation:(RKObjectRequestOperation *)operation {
    NSDictionary *result = ((RKMappingResult*)object).dictionary;
    if (result) {
        self.notification = [result objectForKey:@""];
        
        //        TODO::here
        NSDictionary *userInfo = @{@"increment_notif": _notification.result.incr_notif?:@"0"};
        [[NSNotificationCenter defaultCenter] postNotificationName:@"setUnreadNotification"
                                                            object:nil
                                                          userInfo:userInfo];
        
        [self.delegate didReceiveNotification:_notification];
        
        [self.cacheConnection connection:operation.HTTPRequestOperation.request
                      didReceiveResponse:operation.HTTPRequestOperation.response];
        [self.cacheController connectionDidFinish:_cacheConnection];
        
        [operation.HTTPRequestOperation.responseData writeToFile:_cachePath atomically:YES];
    }
}

#pragma mark - Read Notification Request

- (void)resetNotification {
    [self.networkManager requestWithBaseUrl:[NSString v4Url]
                                       path:@"/v4/notification/reset_notification.pl"
                                     method:RKRequestMethodGET
                                  parameter:@{}
                                    mapping:[GeneralAction mapping]
                                  onSuccess:nil
                                  onFailure:nil];
}

@end