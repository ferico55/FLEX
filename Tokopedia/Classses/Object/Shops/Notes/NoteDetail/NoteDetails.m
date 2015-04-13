//
//  NoteDetails.m
//  Tokopedia
//
//  Created by IT Tkpd on 10/14/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "NoteDetails.h"

@implementation NoteDetails

- (NSString*)notes_title {
    return [_notes_title kv_decodeHTMLCharacterEntities];
}

- (NSString*)notes_content {
    return [_notes_content kv_decodeHTMLCharacterEntities];
}

@end
