//
//  ListRekeningBank.m
//  Tokopedia
//
//  Created by Renny Runiawati on 9/28/15.
//  Copyright © 2015 TOKOPEDIA. All rights reserved.
//

#define CacheFileNameListSystemBank @"list_bank"

#import "ListRekeningBank.h"
#import "TransactionBuy.h"

@implementation ListRekeningBank

- (NSString *)cachepath {
    NSString *path = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject]stringByAppendingPathComponent:@"bank-account"];
    
    
    path = [path stringByAppendingPathComponent:CacheFileNameListSystemBank];
    
    return path;
}

-(NSArray*)defaultListBank
{
 NSArray *system_bank = [
                        {
                            sb_active: 1,
                            sb_account_no: "372 177 3939",
                            sb_bank_name: "BCA",
                            sb_bank_cabang: "Kedoya Permai",
                            sb_picture: "https://cdn-alpha.tokopedia.com/img/icon-bca.png",
                            sb_info: "Verifikasi 1x24 jam",
                            sb_account_name: "PT. Tokopedia"
                        },
                        {
                            sb_account_name: "Tokopedia",
                            sb_info: "Verifikasi 2x24 jam",
                            sb_picture: "https://cdn-alpha.tokopedia.com/img/icon-mandiri.png",
                            sb_bank_cabang: "Permata Hijau",
                            sb_bank_name: "MANDIRI",
                            sb_active: 1,
                            sb_account_no: "102 000 5263873"
                        },
                        {
                            sb_account_name: "PT. Tokopedia",
                            sb_info: "Verifikasi 1x24 jam",
                            sb_picture: "https://cdn-alpha.tokopedia.com/img/icon-bni.png",
                            sb_bank_cabang: "Siloam - Kebon Jeruk",
                            sb_bank_name: "BNI",
                            sb_active: 1,
                            sb_account_no: "800 600 6009"
                        },
                        {
                            sb_bank_cabang: "Kebon Jeruk",
                            sb_info: "Verifikasi 1x24 jam",
                            sb_picture: "https://cdn-alpha.tokopedia.com/img/icon-bri.png",
                            sb_active: 1,
                            sb_account_no: "037 701 000435301",
                            sb_bank_name: "BRI",
                            sb_account_name: "PT. Tokopedia"
                        }
        ]
    }
}

//-(RKObjectManager*)objectManager
//{
//    RKObjectManager *objectManagerActionBuy = [RKObjectManager sharedClient];
//    
//    // setup object mappings
//    RKObjectMapping *statusMapping = [RKObjectMapping mappingForClass:[TransactionBuy class]];
//    [statusMapping addAttributeMappingsFromDictionary:@{kTKPD_APISTATUSMESSAGEKEY:kTKPD_APISTATUSMESSAGEKEY,
//                                                        kTKPD_APIERRORMESSAGEKEY:kTKPD_APIERRORMESSAGEKEY,
//                                                        kTKPD_APISTATUSKEY:kTKPD_APISTATUSKEY,
//                                                        kTKPD_APISERVERPROCESSTIMEKEY:kTKPD_APISERVERPROCESSTIMEKEY,
//                                                        }];
//    
//    RKObjectMapping *resultMapping = [RKObjectMapping mappingForClass:[TransactionBuyResult class]];
//    [resultMapping addAttributeMappingsFromArray:@[kTKPD_APIISSUCCESSKEY]];
//    
////    RKObjectMapping *systemBankMapping  = [[self mapping] systemBankMapping];
////    
////    [statusMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:kTKPD_APIRESULTKEY toKeyPath:kTKPD_APIRESULTKEY withMapping:resultMapping]];
////    
////    [resultMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:API_TRANSACTION_SUMMARY_KEY toKeyPath:API_TRANSACTION_SUMMARY_KEY withMapping:transactionMapping]];
////    
////    RKRelationshipMapping *systemBankRel = [RKRelationshipMapping relationshipMappingFromKeyPath:API_SYSTEM_BANK_KEY toKeyPath:API_SYSTEM_BANK_KEY withMapping:systemBankMapping];
////    [resultMapping addPropertyMapping:systemBankRel];
////    
////    // register mappings with the provider using a response descriptor
////    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:statusMapping method:RKRequestMethodPOST pathPattern:API_TRANSACTION_PATH keyPath:@"" statusCodes:kTkpdIndexSetStatusCodeOK];
//    
//    [objectManagerActionBuy addResponseDescriptor:responseDescriptor];
//    
//    return objectManagerActionBuy;
//}

- (id)getFromCache {
    NSError* error;
    NSData *data = [NSData dataWithContentsOfFile:[self cachepath]];
    
    if(data.length) {
        id parsedData = [RKMIMETypeSerialization objectFromData:data
                                                       MIMEType:RKMIMETypeJSON
                                                          error:&error];
        if (parsedData == nil && error) {
            NSLog(@"parser error");
        }
        
        NSMutableDictionary *mappingsDictionary = [[NSMutableDictionary alloc] init];
        //_objectmanager = [self getObjectManager:0];
//        for (RKResponseDescriptor *descriptor in _objectmanager.responseDescriptors) {
//            [mappingsDictionary setObject:descriptor.mapping forKey:descriptor.keyPath];
//        }
        
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

@end
