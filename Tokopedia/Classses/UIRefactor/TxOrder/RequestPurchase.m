//
//  RequestPurchase.m
//  Tokopedia
//
//  Created by Renny Runiawati on 3/21/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import "RequestPurchase.h"

@implementation RequestPurchase

+(void)fetchListPuchasePage:(NSInteger)page
                     action:(NSString*)action
                    invoice:(NSString*)invoice
                  startDate:(NSString*)startDate
                    endDate:(NSString*)endDate
                     status:(NSString*)status
                    success:(void (^)(NSArray *list, NSInteger nextPage, NSString* uriNext))success
                    failure:(void (^)(NSError *error))failure {

    
    NSDictionary* param = @{@"action"   : action,
                            @"page"     : @(page),
                            @"invoice"  : invoice,
                            @"start"    :startDate,
                            @"end"      : endDate,
                            @"status"   : status
                            };
    
    TokopediaNetworkManager *networkManager = [TokopediaNetworkManager new];
    [networkManager requestWithBaseUrl:kTkpdBaseURLString path:@"tx-order.pl" method:RKRequestMethodPOST parameter:param mapping:[TxOrderStatus mapping] onSuccess:^(RKMappingResult *successResult, RKObjectRequestOperation *operation) {
        
        TxOrderStatus *response = [successResult.dictionary objectForKey:@""];
        
        if(response.message_error)
        {
            NSArray *array = response.message_error?:[[NSArray alloc] initWithObjects:kTKPDMESSAGE_ERRORMESSAGEDEFAULTKEY, nil];
            StickyAlertView *alert = [[StickyAlertView alloc] initWithErrorMessages:array delegate:self];
            [alert show];
            failure(nil);
        } else {
            NSInteger nextPage = [[networkManager splitUriToPage:response.result.paging.uri_next] integerValue];
            success(response.result.list,nextPage, response.result.paging.uri_next);
        }
        
    } onFailure:^(NSError *errorResult) {
        failure(errorResult);
    }];
}

@end
