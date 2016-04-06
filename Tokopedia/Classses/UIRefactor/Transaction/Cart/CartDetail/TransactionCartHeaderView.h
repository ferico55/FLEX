//
//  TransactionCartHeaderView.h
//  Tokopedia
//
//  Created by IT Tkpd on 1/13/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TransactionCartList.h"
@class TransactionCartHeaderView;

#pragma mark - General Talk Cell Delegate
@protocol TransactionCartHeaderViewDelegate <NSObject>
@required
- (void)deleteTransactionCartHeaderView:(TransactionCartHeaderView*)view atSection:(NSInteger)section;
- (void)didTapShopAtSection:(NSInteger)section;
@end

@interface TransactionCartHeaderView : UIView


@property (nonatomic, weak) IBOutlet id<TransactionCartHeaderViewDelegate> delegate;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintwidthbadge;
@property (weak, nonatomic) IBOutlet UIImageView *LMBadgeImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintYShopName;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintXShopName;

@property (weak, nonatomic) IBOutlet UIButton *deleteButton;
@property (weak, nonatomic) IBOutlet UILabel *shopNameLabel;
@property (nonatomic) NSInteger section;

+(id)newview;
-(void)setViewModel:(CartModelView*)viewModel page:(NSInteger)page section:(NSInteger)section delegate:(UIViewController*)delegate;

@end
