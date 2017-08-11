//
//  TKPDTabViewController.h
//  Tokopedia
//
//  Created by Feizal Badri Asmoro on 5/22/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>

static NSString *TKPDTabViewSegmentedIndex = @"TKPDTabViewSegmentedIndex";
static NSString *TKPDTabViewNavigationMenuIndex = @"TKPDTabViewNavigationMenuIndex";
static NSString *TKPDTabNotification = @"TKPDTabNotification";

typedef NS_ENUM(NSInteger, InboxType) {
    InboxTypeTalk,
    InboxTypeTicket,
};

@protocol TKPDTabViewDelegate <NSObject>

@optional;
- (void)tabViewController:(id)controller didTapButtonAtIndex:(NSInteger)index;
- (void)pushViewController:(id)controller;

@end

@interface TKPDTabViewController : UIViewController <TKPDTabViewDelegate>

@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;
@property (weak, nonatomic) IBOutlet UIView *containerView;

@property (strong, nonatomic) NSArray *viewControllers;
@property (strong, nonatomic) NSArray *tabTitles;
@property (strong, nonatomic) NSArray *menuTitles;
@property (strong, nonatomic) UIViewController *splitVC;
@property InboxType inboxType;

@property (weak, nonatomic) id<TKPDTabViewDelegate> delegate;

@end
