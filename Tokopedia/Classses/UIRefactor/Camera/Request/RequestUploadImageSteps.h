//
//  RequestUploadImageSteps.h
//  Tokopedia
//
//  Created by Renny Runiawati on 10/12/15.
//  Copyright © 2015 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GeneratedHost.h"

@protocol RequestUploadImageDelegate <NSObject>
@required
-(void)didSuccessUploadImage:(NSInteger)tag;

@optional
-(NSString*)setSuccessMessage:(NSInteger)tag;

@end


@interface RequestUploadImageSteps : NSObject

@property (nonatomic, weak) IBOutlet id<RequestUploadImageDelegate> delegate;

@property (nonatomic, strong) NSDictionary *paramValidation;
@property (nonatomic, strong) NSDictionary *paramImage;
@property (nonatomic, strong) NSDictionary *paramSubmit;

@property (nonatomic, strong) NSString *pathValidation;
@property (nonatomic, strong) NSString *pathImage;
@property (nonatomic, strong) NSString *pathSubmit;

@property GeneratedHost *generatedHost;

@property int tag;
-(void)doRequest;

@end
