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
#import "TransactionObjectMapping.h"

@interface ListRekeningBank ()
{
    TransactionObjectMapping *_mapping;
    NSArray *listRekening;
}

@end


@implementation ListRekeningBank

- (NSString *)cachepath {
    NSString *path = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject]stringByAppendingPathComponent:@"bank-account"];
    
    
    path = [path stringByAppendingPathComponent:CacheFileNameListSystemBank];
    
    return path;
}

-(TransactionObjectMapping*)mapping
{
    if (!_mapping) {
        _mapping = [TransactionObjectMapping new];
    }
    
    return _mapping;
}

-(NSArray*)defaultListBank
{
    NSMutableArray *systemBankArray = [NSMutableArray new];
#if DEBUG
    [systemBankArray addObject: @{
                                  @"sb_bank_cabang":@"Tomang Tol",
                                  @"sb_picture":@"",
                                  @"sb_info":@"Verifikasi 2x24 jam",
                                  @"sb_bank_name":@"List Default",
                                  @"sb_active":@"1",
                                  @"sb_account_no":@"==============",
                                  @"sb_account_name":@"PT. Tokopedia"
                                  }];
#endif
    NSArray *systemBank =
                                @[
                                    @{
                                        @"sb_active": @"1",
                                        @"sb_account_no": @"372 177 3939",
                                        @"sb_bank_name": @"BCA",
                                        @"sb_bank_cabang": @"Kedoya Permai",
                                        @"sb_picture": @"https://cdn-alpha.tokopedia.com/img/icon-bca.png",
                                        @"sb_info": @"Verifikasi 1x24 jam",
                                        @"sb_account_name": @"PT. Tokopedia"
                                    },
                                    @{
                                        @"sb_account_name": @"Tokopedia",
                                        @"sb_info": @"Verifikasi 2x24 jam",
                                        @"sb_picture": @"https://cdn-alpha.tokopedia.com/img/icon-mandiri.png",
                                        @"sb_bank_cabang": @"Permata Hijau",
                                        @"sb_bank_name": @"MANDIRI",
                                        @"sb_active": @"1",
                                        @"sb_account_no": @"102 000 5263873"
                                    },
                                    @{
                                        @"sb_account_name": @"PT. Tokopedia",
                                        @"sb_info": @"Verifikasi 1x24 jam",
                                        @"sb_picture": @"https://cdn-alpha.tokopedia.com/img/icon-bni.png",
                                        @"sb_bank_cabang": @"Siloam - Kebon Jeruk",
                                        @"sb_bank_name": @"BNI",
                                        @"sb_active": @"1",
                                        @"sb_account_no": @"800 600 6009"
                                    },
                                    @{
                                        @"sb_bank_cabang": @"Kebon Jeruk",
                                        @"sb_info": @"Verifikasi 1x24 jam",
                                        @"sb_picture": @"https://cdn-alpha.tokopedia.com/img/icon-bri.png",
                                        @"sb_active": @"1",
                                        @"sb_account_no": @"037 701 000435301",
                                        @"sb_bank_name": @"BRI",
                                        @"sb_account_name": @"PT. Tokopedia"
                                    },
                                    @{
                                        @"sb_bank_cabang":@"Tomang Tol",
                                        @"sb_picture":@"https://ecs1.tokopedia.net/img/Logo-CIMB.png",
                                        @"sb_info":@"Verifikasi 2x24 jam",
                                        @"sb_bank_name":@"CIMB",
                                        @"sb_active":@"1",
                                        @"sb_account_no":@"177 01 00731 002",
                                        @"sb_account_name":@"PT. Tokopedia"
                                    }
                                ];
    [systemBankArray addObjectsFromArray:systemBank];
    
    NSMutableArray *systemBankWithMapping = [NSMutableArray new];
    for (NSDictionary *systemBank in systemBankArray) {
        TransactionSystemBank *bank = [TransactionSystemBank new];
        bank.sb_bank_cabang = [systemBank objectForKey:@"sb_bank_cabang"];
        bank.sb_info = [systemBank objectForKey:@"sb_info"];
        bank.sb_picture = [systemBank objectForKey:@"sb_picture"];
        bank.sb_account_name = [systemBank objectForKey:@"sb_account_name"];
        bank.sb_account_no = [systemBank objectForKey:@"sb_account_no"];
        bank.sb_bank_name = [systemBank objectForKey:@"sb_bank_name"];
        [systemBankWithMapping addObject:bank];
    }
    
    return [systemBankWithMapping copy];
}

-(RKObjectManager*)objectManager
{
    RKObjectManager *objectManager = [RKObjectManager sharedClient];
    TransactionBuy *transacitonBuy = [TransactionBuy new];
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:transacitonBuy.mapping
                                                                                            method:RKRequestMethodGET
                                                                                       pathPattern:nil
                                                                                           keyPath:@""
                                                                                       statusCodes:kTkpdIndexSetStatusCodeOK];
    [objectManager addResponseDescriptor:responseDescriptor];
    
    return objectManager;
}

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
        for (RKResponseDescriptor *descriptor in [self objectManager].responseDescriptors) {
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


-(NSArray*)getRekeningBankList
{
    RKMappingResult *mappingResult = [self getFromCache];
    if(mappingResult) {
        NSDictionary *resultDict = mappingResult.dictionary;
        TransactionBuy* transaction = [resultDict objectForKey:@""];
        NSString *status = transaction.status;
        
        if([status isEqualToString:@"OK"]) {
            return transaction.result.system_bank;
        }
    }
    return [self defaultListBank];
}

@end
