//
//  ResolutionButton.m
//  Tokopedia
//
//  Created by IT Tkpd on 3/3/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "ResolutionButton.h"

@implementation ResolutionButton

// MARK: TKPRootObjectMapping methods
+ (NSDictionary *)attributeMappingDictionary {
    NSArray *keys = @[@"button_report",
                      @"button_cancel",
                      @"button_no_btn",
                      @"button_edit",
                      @"hide_no_reply",
                      @"button_report_hide",
                      @"button_cancel_text",
                      @"button_report_text"];
    return [NSDictionary dictionaryWithObjects:keys forKeys:keys];
}

+ (RKObjectMapping *)mapping {
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:self];
    [mapping addAttributeMappingsFromDictionary:[self attributeMappingDictionary]];
    return mapping;
}

- (NSString*)button_cancel_text {
    return [_button_cancel_text kv_decodeHTMLCharacterEntities];
}

- (NSString*)button_report_text {
    return [_button_report_text kv_decodeHTMLCharacterEntities];
}
@end
