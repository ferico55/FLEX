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

@interface RequestAddress ()<TokopediaNetworkManagerDelegate>

@end

@implementation RequestAddress
{
    TokopediaNetworkManager *_provinceNetworkManager;
    TokopediaNetworkManager *_cityNetworkManager;
    TokopediaNetworkManager *_districtNetworkManager;
    
    AddressObj *_address;
    
    NSString *_cachePath;
    NSTimeInterval _timeinterval;
    URLCacheConnection *_cacheConnection;
    URLCacheController *_cacheController;
}


-(TokopediaNetworkManager*)provinceNetworkManager
{
    if (!_provinceNetworkManager) {
        _provinceNetworkManager = [TokopediaNetworkManager new];
        _provinceNetworkManager.delegate = self;
        _provinceNetworkManager.tagRequest = TagRequestGetProvince;
        [self initCache];
    }
    
    return _provinceNetworkManager;
}

-(TokopediaNetworkManager*)cityNetworkManager
{
    if (!_cityNetworkManager) {
        _cityNetworkManager = [TokopediaNetworkManager new];
        _cityNetworkManager.delegate = self;
        _cityNetworkManager.tagRequest = TagRequestGetCity;
        [self initCache];
    }
    return _cityNetworkManager;
}

-(TokopediaNetworkManager*)districtNetworkManager
{
    if (!_districtNetworkManager) {
        _districtNetworkManager = [TokopediaNetworkManager new];
        _districtNetworkManager.delegate = self;
        _districtNetworkManager.tagRequest = TagRequestGetDistrict;
        [self initCache];
    }
    
    return _districtNetworkManager;
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
    TokopediaNetworkManager *networkManager = [self provinceNetworkManager];
    [self doRequestNetworkManager:networkManager];
}

-(void)doRequestCities
{
    TokopediaNetworkManager *networkManager = [self cityNetworkManager];
    [self doRequestNetworkManager:networkManager];
}

-(void)doRequestDistricts
{
    TokopediaNetworkManager *networkManager = [self districtNetworkManager];
    [self doRequestNetworkManager:networkManager];
}

-(void)doRequestNetworkManager:(TokopediaNetworkManager*)networkManager;
{
    [_cacheController getFileModificationDate];
    _timeinterval = fabs([_cacheController.fileDate timeIntervalSinceNow]);
    
    if([self getFromCache]) {
        [networkManager requestSuccess:[self getFromCache] withOperation:nil];
    } else {
        [networkManager doRequest];
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

-(id)getObjectManager:(int)tag
{
    RKObjectManager *objecManager = [RKObjectManager sharedClient];
    
    RKObjectMapping *statusMapping = [RKObjectMapping mappingForClass:[AddressObj class]];
    [statusMapping addAttributeMappingsFromDictionary:@{kTKPD_APIERRORMESSAGEKEY:kTKPD_APIERRORMESSAGEKEY,
                                                        kTKPD_APISTATUSKEY:kTKPD_APISTATUSKEY,
                                                        kTKPD_APISERVERPROCESSTIMEKEY:kTKPD_APISERVERPROCESSTIMEKEY}];
    
    RKObjectMapping *resultMapping = [RKObjectMapping mappingForClass:[AddressResult class]];
    
    RKObjectMapping *citiesMapping = [RKObjectMapping mappingForClass:[AddressCity class]];
    [citiesMapping addAttributeMappingsFromArray:@[@"city_id",
                                                 @"city_name"
                                                 ]
     ];
    
    RKObjectMapping *districtsMapping = [RKObjectMapping mappingForClass:[AddressDistrict class]];
    [districtsMapping addAttributeMappingsFromArray:@[@"district_id",
                                                      @"district_name"
                                                      ]
     ];
    
    RKObjectMapping *provincesMapping = [RKObjectMapping mappingForClass:[AddressProvince class]];
    [provincesMapping addAttributeMappingsFromArray:@[@"province_id",
                                                      @"province_name"
                                                      ]
     ];
    
    // Relationship Mapping
    [statusMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:kTKPD_APIRESULTKEY toKeyPath:kTKPD_APIRESULTKEY withMapping:resultMapping]];
    
    RKRelationshipMapping *cityRelMapping = [RKRelationshipMapping relationshipMappingFromKeyPath:@"cities"
                                                                                        toKeyPath:@"cities"
                                                                                      withMapping:citiesMapping];
    [resultMapping addPropertyMapping:cityRelMapping];
    
    RKRelationshipMapping *districtRelMapping = [RKRelationshipMapping relationshipMappingFromKeyPath:@"districts"
                                                                                        toKeyPath:@"districts"
                                                                                      withMapping:districtsMapping];
    [resultMapping addPropertyMapping:districtRelMapping];
    
    RKRelationshipMapping *provinceRelMapping = [RKRelationshipMapping relationshipMappingFromKeyPath:@"provinces"
                                                 
                                                                                            toKeyPath:@"provinces"
                                                                                          withMapping:provincesMapping];
    [resultMapping addPropertyMapping:provinceRelMapping];
    
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:statusMapping
                                                                                            method:RKRequestMethodPOST
                                                                                       pathPattern:@"address.pl"
                                                                                           keyPath:@""
                                                                                       statusCodes:kTkpdIndexSetStatusCodeOK];
    
    [objecManager addResponseDescriptor:responseDescriptor];
    
    return objecManager;
}

-(NSString *)getRequestStatus:(id)result withTag:(int)tag
{
    NSDictionary *resultDict = ((RKMappingResult*)result).dictionary;
    id info = [resultDict objectForKey:@""];
    _address = info;
    
    return _address.status;
}

-(NSString *)getPath:(int)tag
{
    return @"address.pl";
}

-(void)actionAfterRequest:(id)successResult withOperation:(RKObjectRequestOperation *)operation withTag:(int)tag
{
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

-(void)actionFailAfterRequest:(id)errorResult withTag:(int)tag
{
    NSError *error = errorResult;
    NSArray *errors;
    if(error.code == -1011) {
        errors = @[@"Mohon maaf, terjadi kendala pada server"];
    } else if (error.code==-1009 || error.code==-999) {
        errors = @[@"Tidak ada koneksi internet"];
    } else {
        errors = @[error.localizedDescription];
    }
    
    [_delegate failedRequestAddress:errors];
}

-(void)actionAfterFailRequestMaxTries:(int)tag
{

}


- (id)getFromCache {
    [_cacheController getFileModificationDate];
    _timeinterval = fabs([_cacheController.fileDate timeIntervalSinceNow]);
    
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
        for (RKResponseDescriptor *descriptor in ((RKObjectManager*)[self getObjectManager:_tag]).responseDescriptors) {
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
