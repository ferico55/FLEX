//
//  ContactUsFormInteractor.h
//  Tokopedia
//
//  Created by Tokopedia on 9/7/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ContactUsFormInteractorIO.h"

@interface ContactUsFormInteractor : NSObject <ContactUsFormInteractorInput>

@property (nonatomic, weak) id <ContactUsFormInteractorOutput> output;

@end
