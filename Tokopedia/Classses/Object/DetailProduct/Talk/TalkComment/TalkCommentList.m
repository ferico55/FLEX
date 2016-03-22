//
//  TalkList.m
//  Tokopedia
//
//  Created by IT Tkpd on 9/29/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "stringrestkit.h"
#import "TalkComment.h"
#import "ProductTalkDetailViewController.h"
#import "ShopReputation.h"
#import "TalkCommentList.h"

@implementation TalkCommentList

+ (RKObjectMapping *)mapping {
    RKObjectMapping *listMapping = [RKObjectMapping mappingForClass:[TalkCommentList class]];

    [listMapping addAttributeMappingsFromArray:@[
                                                 TKPD_TALK_COMMENT_ID,
                                                 TKPD_TALK_COMMENT_MESSAGE,
                                                 TKPD_COMMENT_ID,
                                                 TKPD_TALK_COMMENT_ISMOD,
                                                 TKPD_TALK_COMMENT_ISSELLER,
                                                 TKPD_TALK_COMMENT_CREATETIME,
                                                 TKPD_TALK_COMMENT_USERIMG,
                                                 TKPD_TALK_COMMENT_USERNAME,
                                                 TKPD_TALK_COMMENT_USERID,
                                                 TKPD_TALK_COMMENT_USER_LABEL,
                                                 TKPD_TALK_COMMENT_USER_LABEL_ID,
                                                 TKPD_TALK_COMMENT_SHOP_NAME,
                                                 TKPD_TALK_COMMENT_SHOP_IMAGE,
                                                 TKPD_TALK_COMMENT_IS_OWNER
                                                 ]];


    [listMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:CCommentShopReputation
                                                                                toKeyPath:CCommentShopReputation
                                                                              withMapping:[ShopReputation mapping]]];

    [listMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:CCommentUserReputation
                                                                                toKeyPath:CCommentUserReputation
                                                                              withMapping:[ReputationDetail mapping]]];
    return listMapping;
}

- (NSString *)comment_message {
    return [_comment_message kv_decodeHTMLCharacterEntities];
}

- (NSString *)comment_shop_name {
    return [_comment_shop_name kv_decodeHTMLCharacterEntities];
}

- (NSString *)comment_user_name {
    return [_comment_user_name kv_decodeHTMLCharacterEntities];
}

- (BOOL)isSeller {
    return [self.comment_user_label isEqualToString:@"Penjual"];
}
@end
