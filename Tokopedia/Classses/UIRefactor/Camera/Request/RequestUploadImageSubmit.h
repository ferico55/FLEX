//
//  RequestUploadImageSubmit.h
//  Tokopedia
//
//  Created by Renny Runiawati on 10/12/15.
//  Copyright © 2015 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol RequestUploadImageSubmitDelegate <NSObject>
@required
-(void)successSubmitMessage:(NSArray*)successMessage;
-(void)actionAfterFailRequestMaxTries:(int)tag;

@end


@interface RequestUploadImageSubmit : NSObject

@property (nonatomic, weak) IBOutlet id<RequestUploadImageSubmitDelegate> delegate;
@property int tag;

-(void)doRequest;

-(void)setParam:(NSDictionary*)param;
-(void)setPath:(NSString*)path;

@end