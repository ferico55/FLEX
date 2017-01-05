//
//  RequestAddress.m
//  Tokopedia
//
//  Created by Renny Runiawati on 6/22/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "RequestAddress.h"
#import "TokopediaNetworkManager.h"

#define TagRequestGetProvince 10
#define TagRequestGetCity 11
#define TagRequestGetDistrict 12

@implementation RequestAddress
{
    TokopediaNetworkManager *_networkManager;
    
    AddressObj *_address;
    
    NSString *_cachePath;
    URLCacheConnection *_cacheConnection;
    URLCacheController *_cacheController;
}

-(TokopediaNetworkManager*)networkManager {
    if (!_networkManager) {
        _networkManager = [TokopediaNetworkManager new];
        _networkManager.isUsingHmac = YES;
    }
    
    [self initCache];
    return _networkManager;
}

-(void)doRequestProvinces
{
    RKMappingResult* cacheMappingResult = [self getFromCache];
    
    if(cacheMappingResult) {
        NSDictionary *resultDict = cacheMappingResult.dictionary;
        _address = [resultDict objectForKey:@""];
        [_delegate successRequestAddress:self withResultObj:_address];
    } else {
        [[self networkManager] requestWithBaseUrl:[NSString v4Url]
                                      path:@"/v4/address/get_province.pl"
                                    method:RKRequestMethodPOST
                                 parameter:nil
                                   mapping:[AddressObj mapping]
                                 onSuccess:^(RKMappingResult *successResult, RKObjectRequestOperation *operation) {
                                     [self actionAfterSuccessfulRequestWithResult:successResult withOperation:operation];
                                 }
                                 onFailure:^(NSError *errorResult) {
                                     [self actionAfterError:errorResult];
                                 }];
    }
}

-(void)doRequestCities
{
    RKMappingResult* cacheMappingResult = [self getFromCache];
    
    if(cacheMappingResult) {
        NSDictionary *resultDict = cacheMappingResult.dictionary;
        _address = [resultDict objectForKey:@""];
        [_delegate successRequestAddress:self withResultObj:_address];
    } else {
        [[self networkManager] requestWithBaseUrl:[NSString v4Url]
                                             path:@"/v4/address/get_city.pl"
                                           method:RKRequestMethodPOST
                                        parameter:@{ @"province_id" : _provinceID?:@"" }
                                          mapping:[AddressObj mapping]
                                        onSuccess:^(RKMappingResult *successResult, RKObjectRequestOperation *operation) {
                                            [self actionAfterSuccessfulRequestWithResult:successResult withOperation:operation];
                                        }
                                        onFailure:^(NSError *errorResult) {
                                            [self actionAfterError:errorResult];
                                        }];
    }
}

-(void)doRequestDistricts
{
    RKMappingResult* cacheMappingResult = [self getFromCache];
    
    if(cacheMappingResult) {
        NSDictionary *resultDict = cacheMappingResult.dictionary;
        _address = [resultDict objectForKey:@""];
        [_delegate successRequestAddress:self withResultObj:_address];
    } else {
        [[self networkManager] requestWithBaseUrl:[NSString v4Url]
                                             path:@"/v4/address/get_district.pl"
                                           method:RKRequestMethodPOST
                                        parameter:@{ @"city_id" : _cityID?:@""}
                                          mapping:[AddressObj mapping]
                                        onSuccess:^(RKMappingResult *successResult, RKObjectRequestOperation *operation) {
                                            [self actionAfterSuccessfulRequestWithResult:successResult withOperation:operation];
                                        }
                                        onFailure:^(NSError *errorResult) {
                                            [self actionAfterError:errorResult];
                                        }];
    }

}

#pragma mark - requestWithBaseUrl Methods

-(void)actionAfterSuccessfulRequestWithResult:(RKMappingResult *)successResult withOperation:(RKObjectRequestOperation *)operation
{
    NSDictionary *resultDict = successResult.dictionary;
    _address = [resultDict objectForKey:@""];
    
    if (_address.message_error.count == 0) {
        [self setToCache:operation];
        [_delegate successRequestAddress:self withResultObj:_address];
    }
    else
    {
        StickyAlertView *alert =[[StickyAlertView alloc]initWithErrorMessages:_address.message_error delegate:_delegate];
        [alert show];
    }
}

-(void)actionAfterError:(NSError *)errorResult{
    NSArray *errors;
    if(errorResult.code == -1011) {
        errors = @[@"Mohon maaf, terjadi kendala pada server"];
    } else if (errorResult.code==-1009 || errorResult.code==-999) {
        errors = @[@"Tidak ada koneksi internet"];
    } else {
        errors = @[errorResult.localizedDescription];
    }
    
    [_delegate failedRequestAddress:errors];
}

#pragma mark - Cache

- (void)initCache {
    _cacheConnection = (_cacheConnection)?:[URLCacheConnection new];
    _cacheController = (_cacheController)?:[URLCacheController new];
    
    NSString *path = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject]stringByAppendingPathComponent:@"address"];
    
    switch (_tag) {
        case 10:
            _cachePath = [path stringByAppendingPathComponent:@"address_province"];
            break;
        case 11:
        {
            NSString *pathString = [NSString stringWithFormat:@"address_city_%@",_provinceID];
            _cachePath = [path stringByAppendingPathComponent:pathString];
            break;
        }
        case 12:
        {
            NSString *pathString = [NSString stringWithFormat:@"address_district_%@_%@",_provinceID,_cityID];
            _cachePath = [path stringByAppendingPathComponent:pathString];
            break;
        }
        default:
            break;
    }
    
    
    _cacheController.filePath = _cachePath;
    _cacheController.URLCacheInterval = 300.0;
    [_cacheController initCacheWithDocumentPath:path];
}

- (RKMappingResult*)getFromCache {
    NSError* error;
    NSData *data = [NSData dataWithContentsOfFile:_cachePath];
    
    if(data.length) {
        id parsedData = [RKMIMETypeSerialization objectFromData:data
                                                       MIMEType:RKMIMETypeJSON
                                                          error:&error];
        if (parsedData == nil && error) {
            NSLog(@"parser error");
        }
        
        NSMutableDictionary *mappingsDictionary = [[NSMutableDictionary alloc] init];
        for (RKResponseDescriptor *descriptor in ((RKObjectManager*)[self getObjectManager]).responseDescriptors) {
            [mappingsDictionary setObject:descriptor.mapping forKey:descriptor.keyPath];
        }
        
        RKMapperOperation *mapper = [[RKMapperOperation alloc] initWithRepresentation:parsedData
                                                                   mappingsDictionary:mappingsDictionary];
        NSError *mappingError = nil;
        BOOL isMapped = [mapper execute:&mappingError];
        if (isMapped && !mappingError) {
            RKMappingResult *mappingresult = [mapper mappingResult];
            
            return mappingresult;
        }
    }
    
    return nil;
}

- (void)setToCache:(RKObjectRequestOperation*)operation {
    [_cacheConnection connection:operation.HTTPRequestOperation.request
              didReceiveResponse:operation.HTTPRequestOperation.response];
    
    [_cacheController connectionDidFinish:_cacheConnection];
    [operation.HTTPRequestOperation.responseData writeToFile:_cachePath atomically:YES];
}

-(id)getObjectManager
{
    RKObjectManager *objecManager = [RKObjectManager sharedClient];
    
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:[AddressObj mapping]
                                                                                            method:RKRequestMethodPOST
                                                                                       pathPattern:@"address.pl"
                                                                                           keyPath:@""
                                                                                       statusCodes:kTkpdIndexSetStatusCodeOK];
    
    [objecManager addResponseDescriptor:responseDescriptor];
    
    return objecManager;
}


@end
