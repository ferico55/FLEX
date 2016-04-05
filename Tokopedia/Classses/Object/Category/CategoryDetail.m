//
//  CategoryDetail.m
//  Tokopedia
//
//  Created by Tokopedia on 2/15/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import "CategoryDetail.h"

@implementation CategoryDetail

@synthesize hasChildCategories = _hasChildCategories;
@synthesize isLastCategory = _isLastCategory;

- (void)setCategoryId:(NSString *)categoryId {
    if ([categoryId isKindOfClass:[NSNumber class]]) {
        _categoryId = [NSString stringWithFormat:@"%@", categoryId];
    } else {
        _categoryId = categoryId;
    }
}

- (void)setIsLastCategory:(BOOL)isLastCategory {
    _isLastCategory = isLastCategory;
}

- (BOOL)isLastCategory {
    if (self.child.count == 0) {
        return YES;
    } else {
        return NO;
    }
}

- (void)setHasChildCategories:(BOOL)hasChildCategories {
    _hasChildCategories = hasChildCategories;
}

- (BOOL)hasChildCategories {
    if (self.child.count > 0) {
        return YES;
    } else {
        return NO;
    }
}

- (BOOL)isEqual:(CategoryDetail *)object {
    BOOL isEqual = NO;
    @try {
        if ([self.categoryId isEqualToString:object.categoryId]) {
            isEqual = YES;
        }
    }
    @catch (NSException *exception) {
        isEqual = NO;
    }
    @finally {
        return isEqual;
    }
}

+(RKObjectMapping *)mapping {
    NSDictionary *categoryAttributeMappings = @{
                                                @"d_id" : @"categoryId",
                                                @"title" : @"name",
                                                @"tree" : @"tree",
                                                @"href" : @"url",
                                                };
    
    RKObjectMapping *categoryMapping = [RKObjectMapping mappingForClass:self];
    [categoryMapping addAttributeMappingsFromDictionary:categoryAttributeMappings];
    
    RKObjectMapping *childCategoryMapping = [RKObjectMapping mappingForClass:self];
    [childCategoryMapping addAttributeMappingsFromDictionary:categoryAttributeMappings];
    
    RKObjectMapping *lastCategoryMapping = [RKObjectMapping mappingForClass:self];
    [lastCategoryMapping addAttributeMappingsFromDictionary:categoryAttributeMappings];
    
    RKRelationshipMapping *childCategoryRelationship = [RKRelationshipMapping relationshipMappingFromKeyPath:@"child" toKeyPath:@"child" withMapping:childCategoryMapping];
    [categoryMapping addPropertyMapping:childCategoryRelationship];
    
    RKRelationshipMapping *lastCategoryRelationship = [RKRelationshipMapping relationshipMappingFromKeyPath:@"child" toKeyPath:@"child" withMapping:lastCategoryMapping];
    [childCategoryMapping addPropertyMapping:lastCategoryRelationship];
    
    return categoryMapping;
}

@end
