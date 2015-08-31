//
//  RequestPayment.h
//  Tokopedia
//
//  Created by Renny Runiawati on 8/28/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RequestGenerateHost.h"
#import "RequestUploadImage.h"

@class TransactionAction;

@protocol RequestPaymentDelegate <NSObject>
@required
-(NSDictionary *)getImageObject;
-(NSDictionary *)getParamConfirmationValidaion:(BOOL)isStepValidation;
-(void)requestSuccessConfirmPayment:(TransactionAction*)action;

@end

@interface RequestPayment : NSObject <GenerateHostDelegate, TokopediaNetworkManagerDelegate, RequestUploadImageDelegate>

@property (nonatomic, weak) IBOutlet id<RequestPaymentDelegate> delegate;

-(void)doRequestPaymentConfirmation;

@end
