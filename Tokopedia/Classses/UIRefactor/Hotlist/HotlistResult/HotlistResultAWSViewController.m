//
//  HotlistResultAWSViewController.m
//  Tokopedia
//
//  Created by Tonito Acen on 9/15/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "HotlistResultAWSViewController.h"

typedef enum TagRequest {
    BannerTag, 
    HotlistTag
} TagRequest;

@interface HotlistResultAWSViewController () <TokopediaNetworkManagerDelegate>

@end

@implementation HotlistResultAWSViewController {
    TokopediaNetworkManager *_networkManager;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _networkManager = [[TokopediaNetworkManager alloc] init];
    [_networkManager setDelegate:self];
    [_networkManager doRequest];
    [_networkManager setTagRequest:BannerTag];
    [_networkManager doRequest];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];

}

#pragma mark - Network Manager Delegate
- (NSString *)getPath:(int)tag {
    NSString *path = nil;
    if(tag == BannerTag) {
        return @"hotlist.pl";
    }
    
    return path;
}

- (NSDictionary *)getParameter:(int)tag {
    NSDictionary *parameter;
    if(tag == BannerTag) {
        
    }
    
    return parameter;
}

- (id)getObjectManager:(int)tag {
    RKObjectManager *objectManager = nil;
    if(tag == BannerTag) {
        
    }
    
    return objectManager;
}

- (NSString *)getRequestStatus:(id)result withTag:(int)tag {
    NSString *requestStatus = nil;
    if(tag == BannerTag) {
        
    }
    return requestStatus;
}

- (void)actionBeforeRequest:(int)tag {
    if(tag == BannerTag) {
        
    }
}

- (void)actionAfterRequest:(id)successResult withOperation:(RKObjectRequestOperation *)operation withTag:(int)tag {
    if(tag == BannerTag) {
        
    }
}


@end
