//
//  ProductTalkDetailHeaderView.h
//  Tokopedia
//
//  Created by Samuel Edwin on 10/15/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import <ComponentKit/CKComponentHostingView.h>
#import "TalkList.h"

@interface ProductTalkDetailHeaderView : CKComponentHostingView

@property (nonatomic, copy) void(^onTapProduct)(TalkList *);
@property (nonatomic, copy) void(^onTapUser)(TalkList *);

- (instancetype)initWithTalk:(TalkList *)talk;

@end
