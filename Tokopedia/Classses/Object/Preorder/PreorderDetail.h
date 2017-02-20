//
//  preorderDetail.h
//  Tokopedia
//
//  Created by atnlie on 12/27/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PreorderDetail : NSObject<TKPObjectMapping>

@property (nonatomic, strong) NSString *preorder_process_time_type_string;
@property (nonatomic) NSInteger preorder_process_time_type;
@property (nonatomic) NSInteger preorder_process_time;
@property (nonatomic) BOOL preorder_status;

@end
