//
//  OrderButton.h
//  Tokopedia
//
//  Created by IT Tkpd on 2/23/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OrderButton : NSObject <TKPObjectMapping>

@property (nonatomic) NSInteger button_open_dispute;
@property (nonatomic, strong) NSString *button_res_center_url;
@property (nonatomic) NSInteger button_open_time_left;
@property (nonatomic) NSInteger button_res_center_go_to;
@property (nonatomic) NSInteger button_upload_proof;
@property (nonatomic) NSInteger button_track;
@property (nonatomic) NSInteger button_ask_seller;
@property (nonatomic) NSInteger button_cancel_request;


@end
