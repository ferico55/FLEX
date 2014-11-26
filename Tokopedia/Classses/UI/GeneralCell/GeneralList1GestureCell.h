//
//  GeneralList1GestureCell.h
//  Tokopedia
//
//  Created by IT Tkpd on 11/4/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kTKPDGENERALLIST1GESTURECELL_IDENTIFIER @"GeneralList1GeneralCellIdentifier"

#pragma mark - General List 1 Gesture Cell Delegate
@protocol GeneralList1GestureCellDelegate <NSObject>
@required
-(void)GeneralList1GestureCell:(UITableViewCell*)cell withindexpath:(NSIndexPath*)indexpath;
-(void)CellDidSwipe;
@optional
- (NSString *)tableView:(UITableView *)tableView titleForSwipeAccessoryButtonForRowAtIndexPath:(NSIndexPath *)indexPath;
-(void)DidTapButton:(UIButton*)button atCell:(UITableViewCell*)cell withindexpath:(NSIndexPath*)indexpath;
@end

@interface GeneralList1GestureCell : UITableViewCell

#if __IPHONE_OS_VERSION_MIN_REQUIRED >= TKPD_MINIMUMIOSVERSION
@property (nonatomic, weak) IBOutlet id<GeneralList1GestureCellDelegate> delegate;
#else
@property (nonatomic, assign) IBOutlet id<GeneralList1GestureCellDelegate> delegate;
#endif

@property (weak, nonatomic) IBOutlet UILabel *labelname;
@property (weak, nonatomic) IBOutlet UILabel *labeldefault;
@property (strong, nonatomic) NSIndexPath *indexpath;
@property (weak, nonatomic) IBOutlet UIButton *buttondefault;

@property (nonatomic) NSInteger type;

+(id)newcell;
-(void)viewdetailresetposanimation:(BOOL)animated;
-(void)viewdetailshowanimation:(BOOL)animated;

@end
