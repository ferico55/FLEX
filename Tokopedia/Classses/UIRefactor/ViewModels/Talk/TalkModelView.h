//
//  TalkModelView.h
//  Tokopedia
//
//  Created by Tonito Acen on 7/22/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TalkModelView : NSObject

@property (strong, nonatomic) NSString *userName;
@property (strong, nonatomic) NSString *userLabel;
@property (strong, nonatomic) NSString *userImage;
@property (strong, nonatomic) NSString *productName;
@property (strong, nonatomic) NSString *productImage;
@property (strong, nonatomic) NSString *createTime;
@property (strong, nonatomic) NSString *totalComment;
@property (strong, nonatomic) NSString *followStatus;
@property (strong, nonatomic) NSString *readStatus;
@property (strong, nonatomic) NSString *talkMessage;

@end
