//
//  SearchAWSResult.m
//  Tokopedia
//
//  Created by Tonito Acen on 8/26/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "SearchAWSResult.h"
#import "SearchAWSProduct.h"
#import "Hashtags.h"
#import "Breadcrumb.h"
#import "Paging.h"

@implementation SearchAWSResult

+ (RKObjectMapping *)mapping {
    RKObjectMapping* mapping = [RKObjectMapping mappingForClass:self];

    [mapping addAttributeMappingsFromDictionary:@{@"has_catalog" : @"has_catalog", @"search_url":@"search_url", @"st":@"st",@"redirect_url" : @"redirect_url", @"department_id" : @"department_id"}];
    
    RKRelationshipMapping *listRel = [RKRelationshipMapping relationshipMappingFromKeyPath:@"products" toKeyPath:@"products" withMapping:[SearchAWSProduct mapping]];
    [mapping addPropertyMapping:listRel];
    
    RKRelationshipMapping *hashtagRel = [RKRelationshipMapping relationshipMappingFromKeyPath:@"hashtag" toKeyPath:@"hashtag" withMapping:[Hashtags mapping]];
    [mapping addPropertyMapping:hashtagRel];
    
    RKRelationshipMapping *categoryRelationship = [RKRelationshipMapping relationshipMappingFromKeyPath:@"breadcrumb" toKeyPath:@"breadcrumb" withMapping:[CategoryDetail mapping]];
    [mapping addPropertyMapping:categoryRelationship];
    
    RKRelationshipMapping *pageRel = [RKRelationshipMapping relationshipMappingFromKeyPath:@"paging" toKeyPath:@"paging" withMapping:[Paging mapping]];
    [mapping addPropertyMapping:pageRel];
    
    return mapping;
    
}

@end
