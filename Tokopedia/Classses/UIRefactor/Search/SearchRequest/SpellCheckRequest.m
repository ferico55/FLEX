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


@interface SpellCheckRequest () {
    TokopediaNetworkManager *_networkManager;
    
    NSString *_query;
    NSString *_type;
    NSString *_category;
}
@end

@implementation SpellCheckRequest


- (NSDictionary *)parameters {
    NSDictionary *parameters = @{
                                 @"st"  :   _type,
                                 @"q"   :   _query,
                                 @"sc"  :   _category,
                                 @"device": @"ios"
                                 };
    return parameters;
}

- (void)requestSpellingSuggestion {
    _networkManager = [TokopediaNetworkManager new];
    _networkManager.tagRequest = SpellCheckNetworkManagerGet;
    _networkManager.isParameterNotEncrypted = YES;
    _networkManager.isUsingHmac = YES;
    _networkManager.timeInterval = 30;
    
    [_networkManager requestWithBaseUrl:[NSString aceUrl]
                                   path:@"/search/v1/spell/product"
                                 method:RKRequestMethodGET
                              parameter:[self parameters]
                                mapping:[SpellCheckResponse mapping]
                              onSuccess:^(RKMappingResult *successResult, RKObjectRequestOperation *operation) {
                                  [self didReceiveSpellSuggestion:successResult];
                              }
                              onFailure:^(NSError *errorResult) {
                              }];
    
}

- (void)didReceiveSpellSuggestion:(RKMappingResult*)successResult {
    SpellCheckResponse *response = [[successResult dictionary] objectForKey:@""];
    NSString *suggest = [[response.data.suggest capitalizedString] stringByReplacingOccurrencesOfString:@"%20" withString:@" "];
    [self.delegate respondsToSelector:@selector(didReceiveSpellSuggestion:totalData:)];
    [self.delegate didReceiveSpellSuggestion:suggest totalData:response.data.total_data];
}

- (void)getSpellingSuggestion:(NSString*)type query:(NSString *)query category:(NSString *)category {
    _type = type;
    _query = query;
    _category = category;
    
    [self requestSpellingSuggestion];
}
    
@end