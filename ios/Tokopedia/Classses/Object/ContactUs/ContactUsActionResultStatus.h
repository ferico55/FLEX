//
//  ContactUsActionResultStatus.h
//  Tokopedia
//
//  Created by Tokopedia on 9/7/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ContactUsActionResultStatus : NSObject

@property (nonatomic, strong, nonnull) NSString *ticket_category_attachment_status;
@property (nonatomic, strong, nonnull) NSString *ticket_category_back_url;
@property (nonatomic, strong, nonnull) NSString *ticket_category_breadcrumb;
@property (nonatomic, strong, nonnull) NSString *ticket_category_login_status;
@property (nonatomic, strong, nonnull) NSString *ticket_category_invoice_status;

@end
