//
//  GiveReviewResponseViewController.m
//  Tokopedia
//
//  Created by Kenneth Vincent on 2/26/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import "GiveReviewResponseViewController.h"
#import "HPGrowingTextView.h"
#import "ViewLabelUser.h"
#import "MyReviewDetailDataManager.h"
#import "CMPopTipView.h"
#import "UIImageView+AFNetworking.h"
#import "SmileyAndMedal.h"
#import "ShopBadgeLevel.h"
#import <QuartzCore/QuartzCore.h>

@interface GiveReviewResponseViewController () <
    UICollectionViewDelegateFlowLayout,
    HPGrowingTextViewDelegate
>
{
    MyReviewDetailDataManager *_dataManager;
    CMPopTipView *_cmPopTipView;
    
    IBOutlet UICollectionView *_collectionView;
}


@property (strong, nonatomic) IBOutlet UIView *giveResponseView;
@property (strong, nonatomic) IBOutlet HPGrowingTextView *responseMessageGrowingTextView;
@property (strong, nonatomic) IBOutlet UIButton *sendButton;

@property (strong, nonatomic) IBOutlet UIView *headerView;
@property (strong, nonatomic) IBOutlet UIImageView *revieweeImage;
@property (strong, nonatomic) IBOutlet ViewLabelUser *revieweeNameLabel;
@property (strong, nonatomic) IBOutlet UIButton *revieweeReputation;
@property (strong, nonatomic) IBOutlet UIView *horizontalBorderView;

@property (strong, nonatomic) IBOutlet UIView *titleView;
@property (strong, nonatomic) IBOutlet UILabel *invoiceLabel;

@end

@implementation GiveReviewResponseViewController {
}

- (void)viewDidLayoutSubviews {
//    [super viewDidLayoutSubviews];
    CGRect frame = _headerView.frame;
    frame.size.width = self.view.bounds.size.width;
    _headerView.frame = frame;
    [_headerView sizeToFit];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _dataManager = [[MyReviewDetailDataManager alloc] initWithCollectionView:_collectionView
                                                                        role:_inbox.role
                                                                    isDetail:YES
                                                                    delegate:nil];
    
    
    _collectionView.delegate = self;
    
    [_dataManager replaceReviews:@[_review]];
    
    UIBarButtonItem *backBarButton = [[UIBarButtonItem alloc] initWithTitle:@" "
                                                                      style:UIBarButtonItemStylePlain
                                                                     target:self
                                                                     action:nil];
    self.navigationItem.backBarButtonItem = backBarButton;
    
    _invoiceLabel.text = _inbox.invoice_ref_num;
    _titleView.frame = CGRectMake(0, 0, self.view.bounds.size.width-144, self.navigationController.navigationBar.bounds.size.height);
    self.navigationItem.titleView = _titleView;
    
    [self setHeaderView];
    [self setGrowingTextView];
    
    CGRect frame = _headerView.frame;
    frame.size.width = self.view.frame.size.width;
    _headerView.frame = frame;
    [_headerView sizeToFit];
    
    frame = _headerView.frame;
    frame.origin.y = -_headerView.frame.size.height;
    _headerView.frame = frame;
    
    [_collectionView addSubview:_headerView];
    _collectionView.contentInset = UIEdgeInsetsMake(_headerView.frame.size.height, 0, 0, 0);
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidShow:)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Methods
- (void)setHeaderView {
    [_revieweeImage setImageWithURL:[NSURL URLWithString:_inbox.reviewee_picture]
                   placeholderImage:[UIImage imageNamed:@"icon_profile_picture.jpeg"]];
    [_revieweeImage.layer setCornerRadius:_revieweeImage.frame.size.width/2];
    [_revieweeImage setClipsToBounds:YES];
    
    [_revieweeNameLabel setText:_inbox.reviewee_name];
    [_revieweeNameLabel setText:[UIColor colorWithRed:69/255.0 green:124/255.0 blue:16/255.0 alpha:1.0]
                       withFont:[UIFont fontWithName:@"GothamMedium" size:13.0]];
    [_revieweeNameLabel setLabelBackground:[_inbox.reviewee_role isEqualToString:@"1"]?@"Pembeli":@"Penjual"];
    
    if([_inbox.role isEqualToString:@"1"]) {//Buyer
        [SmileyAndMedal generateMedalWithLevel:_inbox.shop_badge_level.level
                                       withSet:_inbox.shop_badge_level.set
                                     withImage:_revieweeReputation
                                       isLarge:NO];
        [_revieweeReputation setTitle:@"" forState:UIControlStateNormal];
    }
    else {
        [_revieweeReputation setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle]
                                                                        pathForResource:@"icon_smile_small"
                                                                        ofType:@"png"]]
                             forState:UIControlStateNormal];
        [_revieweeReputation setTitle:[NSString stringWithFormat:@"%@%%", (_inbox.user_reputation==nil? @"0":_inbox.user_reputation.positive_percentage)] forState:UIControlStateNormal];
    }
}

- (void)setGrowingTextView {
    _responseMessageGrowingTextView = [[HPGrowingTextView alloc] initWithFrame:CGRectMake(8.0, 10.0, self.view.frame.size.width - _sendButton.frame.size.width - 24, 30)];
    
    [_responseMessageGrowingTextView setIsScrollable:NO];
    [_responseMessageGrowingTextView setContentInset:UIEdgeInsetsMake(0, 5, 0, 5)];
    [_responseMessageGrowingTextView.layer setBorderWidth:1];
    [_responseMessageGrowingTextView.layer setBorderColor:[[UIColor colorWithWhite:224.0/255 alpha:1.0] CGColor]];
    [_responseMessageGrowingTextView.layer setCornerRadius:5.0];
    [_responseMessageGrowingTextView.layer setMasksToBounds:YES];
    [_responseMessageGrowingTextView setMinNumberOfLines:1];
    _responseMessageGrowingTextView.maxNumberOfLines = 6;
    _responseMessageGrowingTextView.returnKeyType = UIReturnKeyDone;
    _responseMessageGrowingTextView.delegate = self;
    _responseMessageGrowingTextView.internalTextView.scrollIndicatorInsets = UIEdgeInsetsMake(5, 0, 5, 0);
    [_responseMessageGrowingTextView setBackgroundColor:[UIColor whiteColor]];
    [_responseMessageGrowingTextView setPlaceholder:@"Balas ulasan Pembeli"];
    [_responseMessageGrowingTextView setFont:[UIFont fontWithName:@"Gotham Book"
                                                             size:12.0]];
    
    [_giveResponseView addSubview:_responseMessageGrowingTextView];
    _giveResponseView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
}

- (void)resignKeyboardView:(id)sender {
    [_responseMessageGrowingTextView resignFirstResponder];
}

#pragma mark - Collection View Delegate
- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return [_dataManager sizeForItemAtIndexPath:indexPath];
}

- (void)collectionView:(UICollectionView *)collectionView
       willDisplayCell:(UICollectionViewCell *)cell
    forItemAtIndexPath:(NSIndexPath *)indexPath {
    [_dataManager announceWillAppearForItemInCell:cell];
}

- (void)collectionView:(UICollectionView *)collectionView
  didEndDisplayingCell:(UICollectionViewCell *)cell
    forItemAtIndexPath:(NSIndexPath *)indexPath {
    [_dataManager announceDidDisappearForItemInCell:cell];
}

#pragma mark - Growing Text View Delegate
- (void)growingTextView:(HPGrowingTextView *)growingTextView willChangeHeight:(float)height {
    float diff = growingTextView.frame.size.height - height;
    
    CGRect aRect = _giveResponseView.frame;
    aRect.size.height -= diff;
    aRect.origin.y += diff;
    
    _giveResponseView.frame = aRect;
}

#pragma mark - Keyboard Notification
- (void)keyboardWillShow:(NSNotification*)notification {
    NSDictionary *userInfo = [notification userInfo];
    CGSize keyboardSize = [[userInfo objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, keyboardSize.height, 0.0);
    _collectionView.contentInset = contentInsets;
    _collectionView.scrollIndicatorInsets = contentInsets;
}

- (void)keyboardDidShow:(NSNotification*)notification {
    [_collectionView scrollRectToVisible:CGRectMake(0, _collectionView.contentSize.height - _collectionView.bounds.size.height, _collectionView.bounds.size.width, _collectionView.bounds.size.height)
                                animated:YES];
    [_giveResponseView setFrame:CGRectMake(0.0, _collectionView.contentSize.height - _collectionView.bounds.size.height + 59, _giveResponseView.frame.size.width, _giveResponseView.frame.size.height)];
}

- (void)keyboardWillHide:(NSNotification*)notification {
    CGRect frame = CGRectMake(0, self.view.frame.size.height - - _giveResponseView.frame.size.height, _giveResponseView.frame.size.width, _giveResponseView.frame.size.height);
    [UIView animateWithDuration:TKPD_FADEANIMATIONDURATION
                          delay:0
                        options: UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         [_giveResponseView setFrame:frame];
                     }
                     completion:^(BOOL finished){
                     }];
}

@end
