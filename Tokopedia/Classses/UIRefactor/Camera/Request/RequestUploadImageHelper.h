//
//  RequestUploadImageHelper.h
//  Tokopedia
//
//  Created by Renny Runiawati on 10/12/15.
//  Copyright © 2015 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol RequestUploadImageHelperDelegate <NSObject>
@required
-(void)setFileUploaded:(NSString*)fileUploaded;
-(void)actionAfterFailRequestMaxTries:(int)tag;

@end


@interface RequestUploadImageHelper : NSObject

@property (nonatomic, weak) IBOutlet id<RequestUploadImageHelperDelegate> delegate;
@property int tag;
@property NSString *upload_host;

-(void)doRequest;
-(void)setParam:(NSDictionary*)param;


@end
