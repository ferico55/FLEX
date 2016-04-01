//
//  NotesList.m
//  Tokopedia
//
//  Created by IT Tkpd on 10/10/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "NotesList.h"

@implementation NotesList

+(RKObjectMapping *)mapping{
    RKObjectMapping *listMapping = [RKObjectMapping mappingForClass:[NotesList class]];
    [listMapping addAttributeMappingsFromArray:@[@"note_id",
                                                 @"note_status",
                                                 @"note_title"
                                                 ]];
    return listMapping;
}

- (NSString *)note_title
{
    return [_note_title kv_decodeHTMLCharacterEntities];
}

@end
