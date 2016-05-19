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
#import "Tokopedia-Swift.h"

@implementation SearchAWSResult

+ (RKObjectMapping *)mapping {
    RKObjectMapping *resultMapping = [RKObjectMapping mappingForClass:self];
    
    [resultMapping addAttributeMappingsFromDictionary:@{@"has_catalog" : @"has_catalog", @"search_url" : @"search_url", @"st":@"st",@"redirect_url" : @"redirect_url", @"department_id" : @"department_id", @"share_url" : @"share_url"}];
    
    RKRelationshipMapping *listCatalogsRel = [RKRelationshipMapping relationshipMappingFromKeyPath:@"catalogs" toKeyPath:@"catalogs" withMapping:[SearchAWSProduct mapping]];
    [resultMapping addPropertyMapping:listCatalogsRel];
    
    RKRelationshipMapping *listProductsRel = [RKRelationshipMapping relationshipMappingFromKeyPath:@"products" toKeyPath:@"products" withMapping:[SearchAWSProduct mapping]];
    [resultMapping addPropertyMapping:listProductsRel];

	RKRelationshipMapping *hashtagRel = [RKRelationshipMapping relationshipMappingFromKeyPath:@"hashtag" toKeyPath:@"hashtag" withMapping:[Hashtags mapping]];
    [resultMapping addPropertyMapping:hashtagRel];
    
    RKRelationshipMapping *pageRel = [RKRelationshipMapping relationshipMappingFromKeyPath:@"paging" toKeyPath:@"paging" withMapping:[Paging mapping]];
    [resultMapping addPropertyMapping:pageRel];
    
    RKRelationshipMapping *categoryRelationship = [RKRelationshipMapping relationshipMappingFromKeyPath:@"breadcrumb" toKeyPath:@"breadcrumb" withMapping:[CategoryDetail mapping]];
    [resultMapping addPropertyMapping:categoryRelationship];
    
    return resultMapping;
}

@end
