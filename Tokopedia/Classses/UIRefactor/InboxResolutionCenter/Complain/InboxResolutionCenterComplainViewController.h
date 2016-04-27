//
//  InboxResolutionCenterComplainViewController.h
//  Tokopedia
//
//  Created by IT Tkpd on 2/26/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ResolutionCenterDetailViewController;

@protocol ResolutionComplainDelegate <NSObject>

-(void)backToFirstPageWithFilterProcess:(NSInteger)filterProcess;

@end

@interface InboxResolutionCenterComplainViewController : UIViewController
;
@property (nonatomic) NSInteger typeComplaint;

@property (nonatomic) NSInteger filterProcess;
@property (nonatomic) NSInteger filterSort;
@property (nonatomic) NSInteger filterRead;


@property (strong, nonatomic) id<ResolutionComplainDelegate> delegate;
@property (strong, nonatomic) ResolutionCenterDetailViewController *detailViewController;

typedef enum {
    TypeComplaintAll = 2,
    TypeComplaintMine = 0,
    TypeComplaintBuyer = 1
} TypeComplaint;

-(void)refreshRequest;
-(void)removeAllSelected;

@end
