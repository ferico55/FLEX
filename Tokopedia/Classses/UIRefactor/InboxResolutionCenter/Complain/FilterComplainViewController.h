//
//  FilterComplainViewController.h
//  Tokopedia
//
//  Created by IT Tkpd on 2/26/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>
#pragma mark - Filter Complain View Controller Delegate
@protocol FilterComplainViewControllerDelegate <NSObject>
@required
- (void)filterProcess:(NSString*)filterProcess filterRead:(NSString*)filterRead;
@end

@interface FilterComplainViewController : UIViewController


@property (nonatomic, weak) IBOutlet id<FilterComplainViewControllerDelegate> delegate;


@property (nonatomic, strong) NSString *filterProcess;
@property (nonatomic, strong) NSString *filterRead;

@end
