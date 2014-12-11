//
//  TalkList.h
//  Tokopedia
//
//  Created by IT Tkpd on 9/29/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TalkCommentList : NSObject

@property (nonatomic, strong) NSString *talk_id;
@property (nonatomic, strong) NSString *comment_message;
@property (nonatomic, strong) NSString *comment_id;
@property (nonatomic, strong) NSString *is_moderator;
@property (nonatomic, strong) NSString *is_seller;
@property (nonatomic, strong) NSString *comment_create_time;
@property (nonatomic, strong) NSString *comment_user_image;
@property (nonatomic, strong) NSString *comment_user_name;
@property (nonatomic, strong) NSString *is_not_delivered;

@end
