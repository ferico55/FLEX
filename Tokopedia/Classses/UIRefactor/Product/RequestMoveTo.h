//
//  RequestMoveTo.h
//  Tokopedia
//
//  Created by IT Tkpd on 4/29/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol RequestMoveToDelegate <NSObject>
@required
-(void)successMoveToWithMessages:(NSArray*)successMessages;
-(void)failedMoveToWithMessages:(NSArray*)errorMessages;

@end

@interface RequestMoveTo : NSObject

@property UIViewController *_viewController;

@property (nonatomic, weak) IBOutlet id<RequestMoveToDelegate> delegate;

-(void)requestActionMoveToWarehouse:(NSString*)productID etalaseName:(NSString *)etalaseName;
-(void)requestActionMoveToEtalase:(NSString*)productID etalaseID:(NSString*)etalaseID etalaseName:(NSString*)etalaseName;

@end
