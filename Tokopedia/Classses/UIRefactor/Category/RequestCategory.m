//
//  RequestCategory.m
//  Tokopedia
//
//  Created by Renny Runiawati on 6/22/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "RequestCategory.h"

#import "TokopediaNetworkManager.h"
#import "TokopediaCacheManager.h"
#import "UserAuthentificationManager.h"
#import "CategoryList.h"
#import "Tokopedia-Swift.h"

@interface RequestCategory ()

@end

@implementation RequestCategory
{
    CategoryObj *_category;
}

#pragma mark - Network Manager Delegate
-(NSDictionary *)getParameter:(int)tag
{
    NSDictionary *param = @{ @"action" : @"get_department_child",
                             @"department_id" : _department_id
                             };
    return param;
}

-(id)getObjectManager:(int)tag
{
    RKObjectManager *objecManager = [RKObjectManager sharedClient];
    
    RKObjectMapping *statusMapping = [RKObjectMapping mappingForClass:[CategoryObj class]];
    [statusMapping addAttributeMappingsFromDictionary:@{kTKPD_APIERRORMESSAGEKEY:kTKPD_APIERRORMESSAGEKEY,
                                                        kTKPD_APISTATUSKEY:kTKPD_APISTATUSKEY,
                                                        kTKPD_APISERVERPROCESSTIMEKEY:kTKPD_APISERVERPROCESSTIMEKEY}];
    
    RKObjectMapping *resultMapping = [RKObjectMapping mappingForClass:[CategoryResult class]];
    
    RKObjectMapping *listMapping = [RKObjectMapping mappingForClass:[CategoryList class]];
    [listMapping addAttributeMappingsFromArray:@[@"department_name",
                                                   @"department_identifier",
                                                   @"department_dir_view",
                                                   @"department_id",
                                                   @"department_tree"]
      ];
     
     // Relationship Mapping
    [statusMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:kTKPD_APIRESULTKEY toKeyPath:kTKPD_APIRESULTKEY withMapping:resultMapping]];
    
    RKRelationshipMapping *listRelMapping = [RKRelationshipMapping relationshipMappingFromKeyPath:@"list"
                                                                                     toKeyPath:@"list"
                                                                                   withMapping:listMapping];
    [resultMapping addPropertyMapping:listRelMapping];
    
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:statusMapping
                                                                                            method:RKRequestMethodPOST
                                                                                       pathPattern:@"ws/department.pl"
                                                                                           keyPath:@""
                                                                                       statusCodes:kTkpdIndexSetStatusCodeOK];
    
    [objecManager addResponseDescriptor:responseDescriptor];
    
    return objecManager;
}

-(NSString *)getRequestStatus:(id)result withTag:(int)tag
{
    NSDictionary *resultDict = ((RKMappingResult*)result).dictionary;
    id info = [resultDict objectForKey:@""];
    _category = info;
    
    return _category.status;
}

-(NSString *)getPath:(int)tag
{
    return @"ws/department.pl";
}


@end
