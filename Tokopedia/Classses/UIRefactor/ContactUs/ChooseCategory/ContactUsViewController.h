//
//  ContactUsViewController.h
//  Tokopedia
//
//  Created by Tonito Acen on 4/8/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ContactUsViewInterface.h"
#import "ContactUsModuleInterface.h"

@interface ContactUsViewController : UIViewController <ContactUsViewInterface>

@property (nonatomic, strong) id<ContactUsModuleInterface> eventHandler;

@end
