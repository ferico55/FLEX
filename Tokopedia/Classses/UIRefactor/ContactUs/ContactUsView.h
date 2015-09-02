//
//  ContactUsView.h
//  Tokopedia
//
//  Created by Tokopedia on 9/2/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ContactUsView <NSObject>

- (void)setFormWithCategories:(NSArray *)categories;
- (void)setErrorView;
- (void)setRetryView;

@end