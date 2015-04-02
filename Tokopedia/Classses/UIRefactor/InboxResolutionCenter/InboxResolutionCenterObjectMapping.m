//
//  InboxResolutionCenterObjectMapping.m
//  Tokopedia
//
//  Created by IT Tkpd on 2/26/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "InboxResolutionCenterObjectMapping.h"
#import "string_inbox_resolution_center.h"

@implementation InboxResolutionCenterObjectMapping

-(RKObjectMapping*)resolutionLastMapping
{
    RKObjectMapping *resolutionLastMapping = [RKObjectMapping mappingForClass:[ResolutionLast class]];
    [resolutionLastMapping addAttributeMappingsFromArray:@[
                                                           API_LAST_RESOLUTION_ID_KEY,
                                                           API_LAST_ACTION_BY_KEY,
                                                           API_LAST_SHOW_APPEAL_BUTTON_KEY,
                                                           API_LAST_RIVAL_ACCEPTED_KEY,
                                                           API_LAST_REFUND_AMOUNT_IDR_KEY,
                                                           API_LAST_REFUND_AMOUNT_KEY,
                                                           API_LAST_USER_NAME_KEY,
                                                           API_LAST_SOLUTION_KEY,
                                                           API_LAST_USER_URL_KEY,
                                                           API_LAST_CREATE_TIME_STR_KEY,
                                                           API_LAST_TROUBLE_TYPE_KEY,
                                                           API_LAST_SHOW_ACCEPT_ADMIN_BUTTON_KEY,
                                                           API_LAST_CREATE_TIME_KEY,
                                                           API_LAST_FLAG_RECIEVED_KEY,
                                                           API_LAST_SHOW_ACCEPT_BUTTON_KEY,
                                                           API_LAST_SHOW_INPUT_RESI_BUTTON_KEY,
                                                           API_LAST_SHOW_FINISH_BUTTON_KEY
                                                           ]];
    return resolutionLastMapping;
}

-(RKObjectMapping*)resolutionOrderMapping
{
    RKObjectMapping *resolutionOrderMapping = [RKObjectMapping mappingForClass:[ResolutionOrder class]];
    [resolutionOrderMapping addAttributeMappingsFromArray:@[
                                                            API_ORDER_PDF_URL_KEY,
                                                            API_ORDER_SHIPPING_PRICE_IDR_KEY,
                                                            API_ORDER_OPEN_AMOUNT_IDR_KEY,
                                                            API_ORDER_SHIPPING_PRICE_KEY,
                                                            API_ORDER_OPEN_AMOUNT_KEY,
                                                            API_ORDER_INVOICE_REF_NUM_KEY
                                                           ]];
    return resolutionOrderMapping;
}

-(RKObjectMapping*)resolutionByMapping
{
    RKObjectMapping *resolutionByMapping = [RKObjectMapping mappingForClass:[ResolutionBy class]];
    [resolutionByMapping addAttributeMappingsFromArray:@[
                                                        API_BY_CUSTOMER_KEY,
                                                        API_BY_SELLER_KEY
                                                        ]];
    return resolutionByMapping;
}

-(RKObjectMapping*)resolutionShopMapping
{
    RKObjectMapping *resolutionShopMapping = [RKObjectMapping mappingForClass:[ResolutionShop class]];
    [resolutionShopMapping addAttributeMappingsFromArray:@[
                                                         API_SHOP_IMAGE_KEY,
                                                         API_SHOP_NAME_KEY,
                                                         API_SHOP_URL_KEY
                                                         ]];
    return resolutionShopMapping;
}

-(RKObjectMapping*)resolutionCustomerMapping
{
    RKObjectMapping *resolutionCustomerMapping = [RKObjectMapping mappingForClass:[ResolutionCustomer class]];
    [resolutionCustomerMapping addAttributeMappingsFromArray:@[
                                                           API_CUSTOMER_URL_KEY,
                                                           API_CUSTOMER_NAME_KEY,
                                                           API_CUSTOMER_IMAGE_KEY
                                                           ]];
    return resolutionCustomerMapping;
}

-(RKObjectMapping*)resolutionDisputeMapping
{
    RKObjectMapping *resolutionDisputeMapping = [RKObjectMapping mappingForClass:[ResolutionDispute class]];
    [resolutionDisputeMapping addAttributeMappingsFromArray:@[API_DISPUTE_UPDATE_TIME_KEY,
                                                              API_DISPUTE_IS_RESPONDED_KEY,
                                                              API_DISPUTE_CREATE_TIME_KEY,
                                                              API_DISPUTE_IS_EXPIRED_KEY,
                                                              API_DISPUTE_UPDATE_TIME_SHORT_KEY,
                                                              API_DISPUTE_IS_CALL_ADMINT_KEY,
                                                              API_DISPUTE_CREATE_TIME_SHORT_KEY,
                                                              API_DISPUTE_STATUS_KEY,
                                                              API_DISPUTE_DEADLINE_KEY,
                                                              API_DISPUTE_RESOLUTION_ID_KEY,
                                                              API_DISPUTE_DETAIL_URL_KEY,
                                                              API_DISPUTE_30_DAYS_KEY
                                                               ]];
    return resolutionDisputeMapping;
}

-(RKObjectMapping*)resolutionConversationMapping
{
    RKObjectMapping *resolutionConversationMapping = [RKObjectMapping mappingForClass:[ResolutionConversation class]];
    [resolutionConversationMapping addAttributeMappingsFromArray:@[
                                                                   API_CONVERSATION_REMARK_KEY,
                                                                   API_CONVERSATION_ID_KEY,
                                                                   API_CONVERSATION_TIME_AGO_KEY,
                                                                   API_CONVERSATION_CREATE_TIME_KEY,
                                                                   API_CONVERSATION_REFUND_AMOUNT_KEY,
                                                                   API_CONVERSATION_FLAG_RECEIVED_KEY,
                                                                   API_CONVERSATION_USER_URL_KEY,
                                                                   API_CONVERSATION_CREATE_TIME_WIB_KEY,
                                                                   API_CONVERSATION_USER_NAME_KEY,
                                                                   API_CONVERSATION_USER_IMAGE_KEY,
                                                                   API_CONVERSATION_SOLUTION_KEY,
                                                                   API_CONVERSATION_REMARK_STRING_KEY,
                                                                   API_CONVERSATION_TROUBLE_TYPE_KEY,
                                                                   API_CONVERSATION_REFUND_AMOUNT_IDR_KEY,
                                                                   API_CONVERSATION_ACTION_BY_KEY,
                                                                   API_CONVERSATION_SOLUTION_FLAG_KEY,
                                                                   API_CONVERSATION_SYSTEM_FLAG_KEY,
                                                                   API_CONVERSATION_LEFT_COUNT_KEY,
                                                                   API_CONVERSATION_FLAG_VIEW_MORE_KEY,
                                                                   API_CONVERSATION_RESI_NUMBER_KEY,
                                                                   API_CONVERSATION_SHIPMENT_NAME_KEY,
                                                                   API_CONVERSATION_SHIPMENT_KEY,
                                                                   API_CONVERSATION_SHOW_TRACK_BUTTON_KEY,
                                                                   API_CONVERSATION_SHOW_EDIT_RESI_BUTTON_KEY
                                                                   ]];
    return resolutionConversationMapping;
}

-(RKObjectMapping*)resolutionAttachmentMapping
{
    RKObjectMapping *resolutionAttachmentMapping = [RKObjectMapping mappingForClass:[ResolutionAttachment class]];
    [resolutionAttachmentMapping addAttributeMappingsFromArray:@[
                                                                 API_ATTACHMENT_REAL_FILE_URL_KEY,
                                                                 API_ATTACHMENT_FILE_URL_KEY
                                                                 ]];
    return resolutionAttachmentMapping;
}

-(RKObjectMapping*)resolutionButtonMapping
{
    RKObjectMapping *resolutionButtonMapping = [RKObjectMapping mappingForClass:[ResolutionButton class]];
    [resolutionButtonMapping addAttributeMappingsFromArray:@[
                                                             API_BUTTON_REPORT_KEY,
                                                             API_BUTTON_NO_BUTTON_KEY,
                                                             API_BUTTON_EDIT_KEY,
                                                             API_BUTTON_CANCEL_KEY                                                            ]];
    return resolutionButtonMapping;
}

@end
