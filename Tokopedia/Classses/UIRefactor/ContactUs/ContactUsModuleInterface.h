//
//  ContactUsModuleInterface.h
//  Tokopedia
//
//  Created by Tokopedia on 9/2/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ContactUsModuleInterface <NSObject>

- (void)updateView;
- (void)didTapProblem;
- (void)didTapContactUsButton;

@end