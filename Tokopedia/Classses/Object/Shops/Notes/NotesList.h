//
//  NotesList.h
//  Tokopedia
//
//  Created by IT Tkpd on 10/10/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NotesList : NSObject

@property (strong, nonatomic) NSString *note_id;
@property (strong, nonatomic) NSString *note_status;
@property (strong, nonatomic) NSString *note_title;

+(RKObjectMapping*)mapping;
@end
