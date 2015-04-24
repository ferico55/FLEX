//
//  GeneralTableViewController.h
//  Tokopedia
//
//  Created by Feizal Badri Asmoro on 2/3/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol GeneralTableViewControllerDelegate <NSObject>

@optional
- (void)didSelectObject:(id)object senderIndexPath:(NSIndexPath *)indexPath withObjectName:(NSString *)strName;
- (void)didSelectObject:(id)object senderIndexPath:(NSIndexPath *)indexPath;
- (void)didSelectObject:(id)object;
- (void)viewController:(UITableViewController *)viewController didSelectObject:(id)object;

@end

@interface GeneralTableViewController : UITableViewController
@property (nonatomic) BOOL isObjectCategory;
@property (strong, nonatomic) NSArray *objects;
@property (strong, nonatomic) id selectedObject;
@property (strong, nonatomic) NSIndexPath *senderIndexPath;
@property (strong, nonatomic) id<GeneralTableViewControllerDelegate> delegate;
@property UITableViewCellStyle tableViewCellStyle;

@property NSInteger tag;

@property BOOL enableSearch;

@property (nonatomic) BOOL isPresentedViewController;

@property (nonatomic, strong) UISearchBar *searchBar;

@end