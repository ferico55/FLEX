//
//  RequestShipmentCourier.m
//  Tokopedia
//
//  Created by Feizal Badri Asmoro on 2/2/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "string_shipment.h"

#import "RequestShipmentCourier.h"
#import "ShipmentOrder.h"
#import "ShipmentCourier.h"
#import "ShipmentCourierPackage.h"
#import "TKPDSecureStorage.h"

@interface RequestShipmentCourier () {
    __weak RKObjectManager *_objectManager;
    __weak RKManagedObjectRequestOperation *_request;
    RKResponseDescriptor *_responseDescriptorStatus;
    NSOperationQueue *_operationQueue;
}

@end

@implementation RequestShipmentCourier

- (id)init
{
    self = [super init];
    if (self) {
        _operationQueue = [NSOperationQueue new];
        [self configureActionReskit];
    }
    return self;
}

- (void)configureActionReskit
{
    
    _objectManager =  [RKObjectManager sharedClient];

    RKObjectMapping *statusMapping = [RKObjectMapping mappingForClass:[ShipmentOrder class]];
    [statusMapping addAttributeMappingsFromDictionary:@{
                                                        kTKPD_APISTATUSKEY              : kTKPD_APISTATUSKEY,
                                                        kTKPD_APISERVERPROCESSTIMEKEY   : kTKPD_APISERVERPROCESSTIMEKEY,
                                                        kTKPD_APISTATUSMESSAGEKEY       : kTKPD_APISTATUSMESSAGEKEY,
                                                        }];

    RKObjectMapping *resultMapping = [RKObjectMapping mappingForClass:[ShipmentResult class]];

    RKObjectMapping *shipmentMapping = [RKObjectMapping mappingForClass:[ShipmentCourier class]];
    [shipmentMapping addAttributeMappingsFromDictionary:@{
                                                          API_SHIPMENT_ID_KEY           : API_SHIPMENT_ID_KEY,
                                                          API_SHIPMENT_IMAGE_KEY        : API_SHIPMENT_IMAGE_KEY,
                                                          API_SHIPMENT_NAME_KEY         : API_SHIPMENT_NAME_KEY,
                                                          }];

    RKObjectMapping *shipmentPackageMapping = [RKObjectMapping mappingForClass:[ShipmentCourierPackage class]];
    [shipmentPackageMapping addAttributeMappingsFromDictionary:@{
                                                                 API_SHIPMENT_PACKAGE_DESC      : API_SHIPMENT_PACKAGE_DESC,
                                                                 API_SHIPMENT_PACKAGE_ACTIVE    : API_SHIPMENT_PACKAGE_ACTIVE,
                                                                 API_SHIPMENT_PACKAGE_NAME      : API_SHIPMENT_PACKAGE_NAME,
                                                                 API_SHIPMENT_PACKAGE_ID        : API_SHIPMENT_PACKAGE_ID,
                                                                 }];
    
    [statusMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:kTKPD_APIRESULTKEY
                                                                                  toKeyPath:kTKPD_APIRESULTKEY
                                                                                withMapping:resultMapping]];

    [resultMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:API_SHIPMENT_KEY
                                                                                  toKeyPath:API_SHIPMENT_KEY
                                                                                withMapping:shipmentMapping]];

    [shipmentMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:API_SHIPMENT_PACKAGE_KEY
                                                                                  toKeyPath:API_SHIPMENT_PACKAGE_KEY
                                                                                withMapping:shipmentPackageMapping]];
    
    RKResponseDescriptor *actionResponseDescriptorStatus = [RKResponseDescriptor responseDescriptorWithMapping:statusMapping
                                                                                                        method:RKRequestMethodPOST
                                                                                                   pathPattern:API_GET_SHIPMENT_COURIER_PATH
                                                                                                       keyPath:@""
                                                                                                   statusCodes:kTkpdIndexSetStatusCodeOK];
    
    [_objectManager addResponseDescriptor:actionResponseDescriptorStatus];
}

- (void)request
{
    if (_request.isExecuting) return;
    
    TKPDSecureStorage *secureStorage = [TKPDSecureStorage standardKeyChains];
    NSDictionary *auth = [secureStorage keychainDictionary];
    
    NSDictionary* param = @{
                            API_ACTION_KEY           : API_GET_EDIT_SHIPPING_FORM,
                            };
    
    _request = [_objectManager appropriateObjectRequestOperationWithObject:self
                                                                    method:RKRequestMethodPOST
                                                                      path:API_GET_SHIPMENT_COURIER_PATH
                                                                parameters:[param encrypt]];
    
    [_request setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        NSDictionary *result = ((RKMappingResult*)mappingResult).dictionary;
        BOOL status = [[[result objectForKey:@""] status] isEqualToString:kTKPDREQUEST_OKSTATUS];
        if (status){
            ShipmentOrder *shipment = [result objectForKey:@""];
            [self.delegate didReceiveShipmentCourier:shipment.result.shipment];
        }
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        if ([self.delegate respondsToSelector:@selector(requestShipmentCourierError:)]) {
            [self.delegate requestShipmentCourierError:error]; //TODO:: Create function
        }
    }];
    
    [_operationQueue addOperation:_request];
    
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:kTKPDREQUEST_TIMEOUTINTERVAL
                                                      target:self
                                                    selector:@selector(cancel)
                                                    userInfo:nil
                                                     repeats:NO];
    
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
}

- (void)cancel
{
    
}

@end
