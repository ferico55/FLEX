//
//  InboxTicketDetailAttachment.h
//  Tokopedia
//
//  Created by Tokopedia on 6/24/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface InboxTicketDetailAttachment : NSObject <TKPObjectMapping>

@property (strong, nonatomic) NSString *img_src;
@property (strong, nonatomic) NSString *img_link;
@property (strong, nonatomic) UIImage *img;

@end
