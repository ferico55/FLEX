//
//  ResolutionConversation.h
//  Tokopedia
//
//  Created by IT Tkpd on 3/3/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ResolutionAttachment.h"
#import "AddressFormList.h"

@interface ResolutionConversation : NSObject <TKPObjectMapping>

@property (nonatomic) NSArray *attachment;
@property (nonatomic, strong) NSString *remark;
@property (nonatomic, strong) NSString *conversation_id;
@property (nonatomic, strong) NSString *time_ago;
@property (nonatomic, strong) NSString *create_time;
@property (nonatomic, strong) NSString *refund_amt;
@property (nonatomic) NSInteger flag_received;
@property (nonatomic, strong) NSString *user_url;
@property (nonatomic, strong) NSString *create_time_wib;
@property (nonatomic, strong) NSString *user_name;
@property (nonatomic, strong) NSString *user_img;
@property (nonatomic, strong) NSNumber *solution;
@property (nonatomic, strong) NSString *remark_str;
@property (nonatomic, strong) NSString *input_resi;

@property (nonatomic, strong) NSString *kurir_name;
@property (nonatomic, strong) NSString *input_kurir;
@property (nonatomic) NSInteger show_edit_resi_button;
@property (nonatomic) NSInteger show_track_button;

@property (nonatomic, strong) NSNumber *trouble_type;
@property (nonatomic, strong) NSString *refund_amt_idr;
@property (nonatomic) NSInteger action_by;
@property (nonatomic) NSInteger solution_flag;
@property (nonatomic) NSInteger system_flag;
@property (nonatomic, strong) NSString *address_edited;
@property (nonatomic, strong) NSString *show_edit_addr_button;
@property (nonatomic, strong) NSString *left_count;
@property (nonatomic) NSInteger view_more;

@property (nonatomic, strong) AddressFormList *address;

@property (nonatomic) BOOL isAddedConversation;

@property (nonatomic, strong) NSString *trouble_string;
@property (nonatomic, strong) NSString *solution_string;

@end
