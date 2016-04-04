//
//  NotesResult.h
//  Tokopedia
//
//  Created by IT Tkpd on 10/10/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NotesList.h"
#define CDetail @"detail"

@class NoteDetails;
@interface NotesResult : NSObject
@property (strong, nonatomic) NSArray *list;
@property (strong, nonatomic) NoteDetails *detail;

+(RKObjectMapping*)mapping;

@end
