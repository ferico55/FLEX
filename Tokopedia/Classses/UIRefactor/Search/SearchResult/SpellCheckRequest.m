//
//  SpellCheckRequest.h
//  Tokopedia
//
//  Created by Tokopedia on 10/26/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//


#import "SpellCheckRequest.h"
#import "SpellCheckResponse.h"
#import "TokopediaNetworkManager.h"

typedef NS_ENUM(NSInteger, SpellCheckNetworkManager) {
    SpellCheckNetworkManagerGet,
    SpellCheckNetworkManagerAction,
};


@interface SpellCheckRequest () <TokopediaNetworkManagerDelegate> {
    TokopediaNetworkManager *_networkManager;
    __strong RKObjectManager *_objectManager;
    NSString *_query;
    NSString *_type;
    NSString *_category;
}
@end

@implementation SpellCheckRequest

- (NSString *)getPath:(int)tag {
    NSString *path;
    path = @"search/v1/spell/product";
    return path;
}

- (NSDictionary *)getParameter:(int)tag {
    NSDictionary *parameters = @{
                                 @"st"  :   _type,
                                 @"q"   :   _query,
                                 @"sc"  :   _category,
                                 @"device": @"ios"
                                 };
    return parameters;
}

- (id)getObjectManager:(int)tag {
    _objectManager = [RKObjectManager managerWithBaseURL:[NSURL URLWithString:@"https://ace.tokopedia.com/"]];
    
    RKObjectMapping *statusMapping = [RKObjectMapping mappingForClass:[SpellCheckResponse class]];
    [statusMapping addAttributeMappingsFromArray:@[@"status", @"server_process_time"]];
    
    RKObjectMapping *resultMapping = [RKObjectMapping mappingForClass:[SpellCheckResult class]];
    [resultMapping addAttributeMappingsFromArray:@[@"suggest", @"total_data"]];
    
    [statusMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"data"
                                                                                  toKeyPath:@"data"
                                                                                withMapping:resultMapping]];
    
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:statusMapping
                                                                                          method:RKRequestMethodGET
                                                                                     pathPattern:@"search/v1/spell/product"
                                                                                         keyPath:@""
                                                                                     statusCodes:kTkpdIndexSetStatusCodeOK];
    [_objectManager addResponseDescriptor:responseDescriptor];
    
    return _objectManager;
}

- (int)getRequestMethod:(int)tag {
    return RKRequestMethodGET;
}

- (void)requestSpellingSuggestion {
    _networkManager = [TokopediaNetworkManager new];
    _networkManager.delegate = self;
    _networkManager.tagRequest = SpellCheckNetworkManagerGet;
    _networkManager.isParameterNotEncrypted = YES;
    _networkManager.isUsingHmac = YES;
    _networkManager.timeInterval = 30;
    [_networkManager doRequest];
}
- (NSString *)getRequestStatus:(RKMappingResult *)result withTag:(int)tag {
    SpellCheckResponse *response = [[result dictionary] objectForKey:@""];
    return response.status;
}

- (void)actionAfterRequest:(RKMappingResult *)result withOperation:(RKObjectRequestOperation*)operation withTag:(int)tag {
    SpellCheckResponse *response = [[result dictionary] objectForKey:@""];
    NSString *suggest = [[response.data.suggest capitalizedString] stringByReplacingOccurrencesOfString:@"%20" withString:@" "];
    [self.delegate respondsToSelector:@selector(didReceiveSpellSuggestion:totalData:)];
    [self.delegate didReceiveSpellSuggestion:suggest totalData:response.data.total_data];
}

- (void)actionFailAfterRequest:(id)errorResult withTag:(int)tag {
    
}

- (void)getSpellingSuggestion:(NSString*)type query:(NSString *)query category:(NSString *)category {
    _type = type;
    _query = query;
    _category = category;
    
    [self requestSpellingSuggestion];
}
    
@end