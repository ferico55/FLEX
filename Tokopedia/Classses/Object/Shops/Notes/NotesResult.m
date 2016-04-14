//
//  NotesResult.m
//  Tokopedia
//
//  Created by IT Tkpd on 10/10/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "NotesResult.h"

@implementation NotesResult
+(RKObjectMapping *)mapping{
    RKObjectMapping *resultMapping = [RKObjectMapping mappingForClass:[NotesResult class]];
    RKRelationshipMapping *listRel = [RKRelationshipMapping relationshipMappingFromKeyPath:kTKPD_APILISTKEY toKeyPath:kTKPD_APILISTKEY withMapping:[NotesList mapping]];
    [resultMapping addPropertyMapping:listRel];
    return resultMapping;
}
@end
