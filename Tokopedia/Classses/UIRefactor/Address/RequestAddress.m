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
    TokopediaNetworkManager *_provinceNetworkManager;
    TokopediaNetworkManager *_cityNetworkManager;
    TokopediaNetworkManager *_districtNetworkManager;
    
    AddressObj *_address;
    
    NSString *_cachePath;
    URLCacheConnection *_cacheConnection;
    URLCacheController *_cacheController;
}

-(TokopediaNetworkManager*)setNetworkManager:(TokopediaNetworkManager*)networkManager withTag:(int)tag {
    if (!networkManager){
        networkManager = [TokopediaNetworkManager new];
        networkManager.tagRequest = tag;
        [self initCache];
    }
    return networkManager;
}

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

-(void)doRequestProvinces
{
    [self setNetworkManager:_provinceNetworkManager withTag:TagRequestGetProvince];
    [self doRequestNetworkManager:_provinceNetworkManager];
}

-(void)doRequestCities
{
    [self setNetworkManager:_cityNetworkManager withTag:TagRequestGetCity];
    [self doRequestNetworkManager:_cityNetworkManager];
}

-(void)doRequestDistricts
{
    [self setNetworkManager:_districtNetworkManager withTag:TagRequestGetDistrict];
    [self doRequestNetworkManager:_districtNetworkManager];
}

-(void)doRequestNetworkManager:(TokopediaNetworkManager*)networkManager;
{
    RKMappingResult* cacheMappingResult = [self getFromCache];
    
    if(cacheMappingResult) {
        NSDictionary *resultDict = cacheMappingResult.dictionary;
        _address = [resultDict objectForKey:@""];
        [_delegate successRequestAddress:self withResultObj:_address];
    } else {
        [networkManager requestWithBaseUrl:[NSString basicUrl]
                                      path:@"address.pl"
                                    method:RKRequestMethodPOST
                                 parameter:[self getParameter:networkManager.tagRequest]
                                   mapping:[AddressObj mapping]
                                 onSuccess:^(RKMappingResult *successResult, RKObjectRequestOperation *operation) {
                                     [self actionAfterSuccessfulRequestWithResult:successResult withOperation:operation];
                                 }
                                 onFailure:^(NSError *errorResult) {
                                     [self actionAfterError:errorResult];
                                 }];
    }
}

#pragma mark - Network Manager Delegate
-(NSDictionary *)getParameter:(int)tag
{
    NSDictionary *param =@{};
    if (tag == TagRequestGetProvince) {
        param = @{ @"action" : @"get_province"
                   };
    }
    
    if (tag == TagRequestGetCity) {
        param = @{ @"action" : @"get_city",
                   @"province_id" : _provinceID?:@""
                 };
    }

    if (tag == TagRequestGetDistrict) {
        param = @{ @"action" : @"get_district",
                   @"city_id" : _cityID?:@"",
                   };
    }
    
    return param;
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

@end
