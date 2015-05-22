//
//  NoteDetails.h
//  Tokopedia
//
//  Created by IT Tkpd on 10/14/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>
#define CNotesPosition @"notes_position"
#define CNotesStatus @"notes_status"
#define CNotesCreateTime @"notes_create_time"
#define CNotesID @"notes_id"
#define CNotesTitle @"notes_title"
#define CNotesActive @"notes_active"
#define CNotesUpdateTime @"notes_update_time"
#define CNotesContent @"notes_content"


@interface NoteDetails : NSObject

@property (nonatomic, strong) NSString *notes_title;
@property (nonatomic, strong) NSString *notes_update_time;
@property (nonatomic, strong) NSString *notes_content;
@property (nonatomic, strong) NSString *notes_create_time;
@property (nonatomic, strong) NSString *notes_position;
@property (nonatomic, strong) NSString *notes_status;
@property (nonatomic, strong) NSString *notes_id;
@property (nonatomic, strong) NSString *notes_active;
@end