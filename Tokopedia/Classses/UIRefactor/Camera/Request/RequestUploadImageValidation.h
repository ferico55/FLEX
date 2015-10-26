//
//  RequestUploadImageValidation.h
//  Tokopedia
//
//  Created by Renny Runiawati on 10/12/15.
//  Copyright © 2015 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol RequestUploadImageValidationDelegate <NSObject>
@required
-(void)setPostKey:(NSString*)postKey;
-(void)actionAfterFailRequestMaxTries:(int)tag;

@end


@interface RequestUploadImageValidation : NSObject

@property (nonatomic, weak) IBOutlet id<RequestUploadImageValidationDelegate> delegate;
@property int tag;

-(void)doRequest;
-(void)setParam:(NSDictionary*)param;
-(void)setPath:(NSString*)path;


@end