//
//  ContactUsInteractor.h
//  Tokopedia
//
//  Created by Tokopedia on 9/2/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ContactUsResponse.h"
#import "ContactUsInteractorIO.h"

@interface ContactUsInteractor : NSObject <ContactUsInteractorInput>

@property (nonatomic, weak) id <ContactUsInteractorOutput> output;

@end
