//
//  ResolutionButton.h
//  Tokopedia
//
//  Created by IT Tkpd on 3/3/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ResolutionButton : NSObject <TKPObjectMapping>

@property (nonatomic) NSInteger button_report;
@property (nonatomic) NSInteger button_cancel;
@property (nonatomic) NSInteger button_no_btn;
@property (nonatomic) NSInteger button_edit;
@property (nonatomic) NSInteger hide_no_reply;
@property (nonatomic) NSInteger button_report_hide;
@property (strong, nonatomic) NSString *button_cancel_text;
@property (strong, nonatomic) NSString *button_report_text;

@end
