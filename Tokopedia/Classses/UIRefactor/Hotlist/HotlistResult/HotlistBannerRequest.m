//
//  HotlistBanner.m
//  Tokopedia
//
//  Created by Tonito Acen on 9/15/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "HotlistBannerRequest.h"
#import "HotlistBanner.h"


@implementation HotlistBannerRequest

- (void)requestBanner {
    _bannerManager = [[TokopediaNetworkManager alloc] init];
    [_bannerManager setDelegate:self];
    [_bannerManager doRequest];
}

#pragma mark - Tokopedia Network Manager
- (NSString *)getPath:(int)tag {
    return @"hotlist.pl";
}

- (id)getObjectManager:(int)tag {
    RKObjectManager *objectManager = [RKObjectManager sharedClient];
    
    RKObjectMapping *statusMapping = [RKObjectMapping mappingForClass:[HotlistBanner class]];
    [statusMapping addAttributeMappingsFromDictionary:@{@"status" : @"status"}];
    
    RKObjectMapping *infoMapping = [RKObjectMapping mappingForClass:[HotlistBannerInfo class]];
    [infoMapping addAttributeMappingsFromDictionary:@{@"meta_description" : @"meta_description", @"hotlist_description" : @"hotlist_description", @"cover_img" : @"cover_img"}];
    
    RKObjectMapping *queryMapping = [RKObjectMapping mappingForClass:[HotlistBannerQuery class]];
    [queryMapping addAttributeMappingsFromDictionary:@{@"q" : @"q", @"sc" : @"sc"}];
    
    RKObjectMapping *resultMapping = [RKObjectMapping mappingForClass:[HotlistBannerResult class]];
    
    RKRelationshipMapping *infoRel = [RKRelationshipMapping relationshipMappingFromKeyPath:@"info" toKeyPath:@"info" withMapping:infoMapping];
    [resultMapping addPropertyMapping:infoRel];
    
    RKRelationshipMapping *queryRel = [RKRelationshipMapping relationshipMappingFromKeyPath:@"query" toKeyPath:@"query" withMapping:queryMapping];
    [resultMapping addPropertyMapping:queryRel];
    
    RKRelationshipMapping *resultRel = [RKRelationshipMapping relationshipMappingFromKeyPath:@"result" toKeyPath:@"result" withMapping:resultMapping];
    [statusMapping addPropertyMapping:resultRel];
    
    RKResponseDescriptor *responseDescriptorStatus = [RKResponseDescriptor responseDescriptorWithMapping:statusMapping method:RKRequestMethodPOST pathPattern:[self getPath:nil] keyPath:@"" statusCodes:kTkpdIndexSetStatusCodeOK];
    
    [objectManager addResponseDescriptor:responseDescriptorStatus];
    
    return objectManager;
}

- (NSDictionary *)getParameter:(int)tag {
    NSDictionary *parameter = @{@"action" : @"get_hotlist_banner", @"key" : _bannerKey?:@""};
    
    return parameter;
}

- (NSString *)getRequestStatus:(id)result withTag:(int)tag {
    NSDictionary *resultDict = ((RKMappingResult*)result).dictionary;
    id stat = [resultDict objectForKey:@""];
    HotlistBanner *banner = stat;

    return banner.status;
}

- (void)actionAfterRequest:(id)successResult withOperation:(RKObjectRequestOperation *)operation withTag:(int)tag {
    NSDictionary *result = ((RKMappingResult*)successResult).dictionary;
    HotlistBanner *banner = [result objectForKey:@""];
    
    [_delegate didReceiveBannerHotlist:banner.result];
}

@end
