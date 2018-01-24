//
//  Headline.m
//  Tokopedia
//
//  Created by Billion Goenawan on 29/12/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

#import "Headline.h"
#import "Tokopedia-Swift.h"

@implementation Headline

+(RKObjectMapping *)mapping{
    RKObjectMapping *resultMapping = [RKObjectMapping mappingForClass:[Headline class]];
    [resultMapping addAttributeMappingsFromDictionary:@{@"template_id":@"templateId",
                                                        @"promoted_text":@"promotedText",
                                                        @"description":@"headlineDescription",
                                                        @"button_text":@"buttonText"
                                                        }];
    [resultMapping addAttributeMappingsFromArray:@[@"name"]];
    
    [resultMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"image"
                                                                                  toKeyPath:@"headlineImage"
                                                                                withMapping:[HeadlineImage mapping]]];
    
    [resultMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"badges" toKeyPath:@"badges" withMapping:[ProductBadge mapping]]];
    
    return resultMapping;
}

@end
