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
#import "Tokopedia-Swift.h"
#import "ReviewRequest.h"
#import <QuartzCore/QuartzCore.h>

@interface GiveReviewResponseViewController () <
    UICollectionViewDelegateFlowLayout,
    HPGrowingTextViewDelegate
>
{
    MyReviewDetailDataManager *_dataManager;
    CMPopTipView *_cmPopTipView;
    
    ReviewRequest *_reviewRequest;
    
    IBOutlet UICollectionView *_collectionView;
}


@property (strong, nonatomic) IBOutlet UIView *giveResponseView;
@property (strong, nonatomic) IBOutlet RSKGrowingTextView *textView;
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
                                                                  imageCache:_imageCache
                                                                    delegate:nil];
    
    
    _collectionView.delegate = self;
    _collectionView.alwaysBounceVertical = YES;
    
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
    
    _textView.layer.borderWidth = 0.5f;
    _textView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    
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
    
    _reviewRequest = [ReviewRequest new];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Actions
- (IBAction)didTapSendButton:(id)sender {
//    _reviewRequest requestInsertReputationReviewResponseWithReputationID:<#(NSString *)#> responseMessage:<#(NSString *)#> reviewID:<#(NSString *)#> shopID:<#(NSString *)#> onSuccess:<#^(ResponseCommentResult *result)successCallback#> onFailure:<#^(NSError *error)errorCallback#>
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

- (void)resignKeyboardView:(id)sender {
    [_textView resignFirstResponder];
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
    
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(_headerView.frame.size.height, 0.0, keyboardSize.height, 0.0);
    _collectionView.contentInset = contentInsets;
    _collectionView.scrollIndicatorInsets = contentInsets;
    
    [_giveResponseView becomeFirstResponder];
}

- (void)keyboardDidShow:(NSNotification*)notification {
    [_collectionView scrollRectToVisible:CGRectMake(0, _collectionView.contentSize.height - _collectionView.bounds.size.height, _collectionView.bounds.size.width, _collectionView.bounds.size.height)
                                animated:YES];
    [_giveResponseView setFrame:CGRectMake(0.0, _collectionView.contentSize.height - _collectionView.bounds.size.height + 50, _giveResponseView.frame.size.width, _giveResponseView.frame.size.height)];
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
