//
//  RequestATC.m
//  Tokopedia
//
//  Created by Renny Runiawati on 3/15/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import "RequestATC.h"

@implementation RequestATC

+(void)fetchFormProductID:(NSString*)productID
                addressID:(NSString*)addressID
                  success:(void(^)(TransactionATCFormResult* data))success
                   failed:(void(^)(NSError * error))failed {
    
    TokopediaNetworkManager *networkManager = [TokopediaNetworkManager new];
    
    NSDictionary* param = @{@"action" : @"get_add_to_cart_form",
                            @"product_id":productID,
                            @"address_id": addressID
                            };
    
    [networkManager requestWithBaseUrl:kTkpdBaseURLString
                                  path:@"/tx-cart.pl"
                                method:RKRequestMethodPOST
                             parameter:param
                               mapping:[TransactionATCForm mapping]
                             onSuccess:^(RKMappingResult *successResult, RKObjectRequestOperation *operation) {
     TransactionATCForm *form = [successResult.dictionary objectForKey:@""];
    if(form.message_error)
     {
         NSArray *messages = form.message_error?:@[kTKPDMESSAGE_ERRORMESSAGEDEFAULTKEY];
         StickyAlertView *alert = [[StickyAlertView alloc] initWithErrorMessages:messages delegate:self];
         [alert show];
         failed(nil);
     } else{
         success(form.result);
     }
    } onFailure:^(NSError *errorResult) {
        failed(errorResult);
    }];
}

@end
