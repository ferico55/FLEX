//
//  InboxResolutionCenterComplainViewController.h
//  Tokopedia
//
//  Created by IT Tkpd on 2/26/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ResolutionCenterDetailViewController;

@interface InboxResolutionCenterComplainViewController : UIViewController
;
@property (nonatomic) NSInteger filterReadIndex;
@property (nonatomic) NSInteger typeComplaint;

@property (strong, nonatomic)ResolutionCenterDetailViewController *detailViewController;

typedef enum {
    TypeComplaintAll = 2,
    TypeComplaintMine = 0,
    TypeComplaintBuyer = 1
} TypeComplaint;

@end
