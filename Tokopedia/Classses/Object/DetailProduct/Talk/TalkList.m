//
//  TalkList.m
//  Tokopedia
//
//  Created by IT Tkpd on 9/29/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "stringrestkit.h"
#import "Talk.h"
#import "InboxTalkViewController.h"
#import "TalkList.h"
#import "TalkModelView.h"

@implementation TalkList

+ (RKObjectMapping *)mapping {
    RKObjectMapping *listMapping = [RKObjectMapping mappingForClass:[TalkList class]];

    [listMapping addAttributeMappingsFromArray:@[
                                                 TKPD_TALK_PRODUCT_NAME,
                                                 TKPD_TALK_SHOP_ID,
                                                 TKPD_TALK_USER_IMG,
                                                 TKPD_TALK_PRODUCT_STATUS,
                                                 TKPD_TALK_CREATE_TIME,
                                                 TKPD_TALK_MESSAGE,
                                                 TKPD_TALK_FOLLOW_STATUS,
                                                 TKPD_TALK_READ_STATUS,
                                                 TKPD_TALK_TOTAL_COMMENT,
                                                 TKPD_TALK_USER_NAME,
                                                 TKPD_TALK_PRODUCT_ID,
                                                 TKPD_TALK_ID,
                                                 TKPD_TALK_PRODUCT_IMAGE,
                                                 TKPD_TALK_OWN,
                                                 TKPD_TALK_USER_ID,
                                                 TKPD_TALK_USER_LABEL,
                                                 TKPD_TALK_USER_LABEL_ID
                                                 ]];



    // Relationship Mapping
    [listMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:CTalkUserReputation toKeyPath:CTalkUserReputation withMapping:[ReputationDetail mapping]]];
    return listMapping;
}

- (NSString*)talk_message {
    return [_talk_message kv_decodeHTMLCharacterEntities];
}

- (NSString*)talk_product_name {
    return [_talk_product_name kv_decodeHTMLCharacterEntities];
}

- (TalkModelView *)viewModel {
    if(_viewModel == nil) {
        TalkModelView *viewModel = [[TalkModelView alloc] init];
        [viewModel setProductName:self.talk_product_name];
        [viewModel setProductImage:self.talk_product_image];
        [viewModel setUserName:self.talk_user_name];
        [viewModel setUserLabel:self.talk_user_label];
        [viewModel setUserImage:self.talk_user_image];
        [viewModel setCreateTime:self.talk_create_time];
        [viewModel setTotalComment:self.talk_total_comment];
        [viewModel setFollowStatus:[NSString stringWithFormat:@"%ld", (long)self.talk_follow_status]];
        [viewModel setReadStatus:self.talk_read_status];
        [viewModel setTalkMessage:self.talk_message];
        [viewModel setTalkOwnerStatus:self.talk_own];
        [viewModel setProductStatus:self.talk_product_status];
        [viewModel setUserReputation:self.talk_user_reputation];
        
        _viewModel = viewModel;
    }
    
    return _viewModel;
}

@end
