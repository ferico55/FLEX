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
#import "MyReviewDetailViewController.h"
#import "ReviewImageAttachment.h"
#import "NavigateViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface GiveReviewResponseViewController () <
    UICollectionViewDelegateFlowLayout,
    RSKGrowingTextViewDelegate,
    DetailReputationReviewComponentDelegate
>
{
    MyReviewDetailDataManager *_dataManager;
    CMPopTipView *_cmPopTipView;
    
    ReviewRequest *_reviewRequest;
    NavigateViewController *_navigator;
    
    NSInteger _count;
    
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
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *responseViewBottomConstraint;

@property (strong, nonatomic) IBOutlet UIView *titleView;
@property (strong, nonatomic) IBOutlet UILabel *invoiceLabel;

@end

@implementation GiveReviewResponseViewController {
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _dataManager = [[MyReviewDetailDataManager alloc] initWithCollectionView:_collectionView
                                                                        role:_inbox.role
                                                                    isDetail:YES
                                                                  imageCache:_imageCache
                                                                    delegate:self];
    
    
    _collectionView.delegate = self;
    _collectionView.alwaysBounceVertical = YES;
    
    CGRect frame = _collectionView.frame;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        frame.size.width = [[self.navigationController viewControllers] firstObject].view.bounds.size.width;
    } else {
        frame.size.width = [[UIScreen screens] lastObject].bounds.size.width;
    }
    
    _collectionView.frame = frame;
    [_collectionView sizeToFit];
    
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
    
    frame = _headerView.frame;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        frame.size.width = [[self.navigationController viewControllers] firstObject].view.bounds.size.width;
    } else {
        frame.size.width = [[UIScreen screens] lastObject].bounds.size.width;
    }
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
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    _reviewRequest = [ReviewRequest new];
    
    _navigator = [NavigateViewController new];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillShowNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification
                                                  object:nil];
}

#pragma mark - Actions
- (IBAction)didTapSendButton:(id)sender {
    NSString *message = [_textView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    if (message.length > 5) {
        [_reviewRequest requestInsertReputationReviewResponseWithReputationID:_review.reputation_id
                                                              responseMessage:_textView.text
                                                                     reviewID:_review.review_id
                                                                       shopID:_review.shop_id
                                                                    onSuccess:^(ResponseComment *result) {
                                                                        if ([result.data.is_success isEqualToString:@"1"]) {
                                                                            NSMutableArray *allViewControllers = [NSMutableArray arrayWithArray:[self.navigationController viewControllers]];
                                                                            
                                                                            StickyAlertView *alert = [[StickyAlertView alloc] initWithSuccessMessages:@[@"Anda berhasil membalas ulasan"]
                                                                                                                                             delegate:self];
                                                                            [alert show];
                                                                            
                                                                            for (UIViewController *aViewController in allViewControllers) {
                                                                                if ([aViewController isKindOfClass:[MyReviewDetailViewController class]]) {
                                                                                    [self.navigationController popToViewController:aViewController animated:YES];
                                                                                    [[NSNotificationCenter defaultCenter] postNotificationName:@"RefreshData"
                                                                                                                                        object:nil];
                                                                                }
                                                                            }
                                                                        } else {
                                                                            if (result.message_error && result.message_error.count > 0) {
                                                                                StickyAlertView *alert = [[StickyAlertView alloc] initWithErrorMessages:result.message_error
                                                                                                                                               delegate:self];
                                                                                [alert show];
                                                                            } else {
                                                                                StickyAlertView *alert = [[StickyAlertView alloc] initWithErrorMessages:@[@"Anda gagal membalas ulasan"]
                                                                                                                                               delegate:self];
                                                                                [alert show];
                                                                            }
                                                                        }
                                                                    }
                                                                    onFailure:^(NSError *error) {
                                                                        StickyAlertView *alert = [[StickyAlertView alloc] initWithErrorMessages:@[@"Anda gagal membalas ulasan"]
                                                                                                                                       delegate:self];
                                                                        [alert show];
                                                                    }];
    } else {
        StickyAlertView *alert = [[StickyAlertView alloc] initWithErrorMessages:@[@"Komentar terlalu pendek, minimum 5 karakter."]
                                                                       delegate:self];
        [alert show];
    }
    
}

#pragma mark - Methods
- (void)setHeaderView {
    [_revieweeImage setImageWithURL:[NSURL URLWithString:_inbox.reviewee_picture]
                   placeholderImage:[UIImage imageNamed:@"icon_profile_picture.jpeg"]];
    [_revieweeImage.layer setCornerRadius:_revieweeImage.frame.size.width/2];
    [_revieweeImage setClipsToBounds:YES];
    
    [_revieweeNameLabel setText:_inbox.reviewee_name];
    [_revieweeNameLabel setText:[UIColor colorWithRed:69/255.0 green:124/255.0 blue:16/255.0 alpha:1.0]
                       withFont:[UIFont smallThemeMedium]];
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

#pragma mark - Text View Delegate
- (void)textViewDidBeginEditing:(UITextView *)textView {
    [_collectionView scrollToBottomAnimated:YES];
}

#pragma mark - Scroll View Delegate
- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView {
    [_giveResponseView resignFirstResponder];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [_giveResponseView resignFirstResponder];
}

#pragma mark - Reputation Detail Cells Delegate
- (void)didTapAttachedImages:(DetailReputationReview *)review withIndex:(NSInteger)index {
    NSMutableArray *descriptionArray = [NSMutableArray new];
    NSMutableArray<UIImageView*> *imageArray = [NSMutableArray new];
    
    _count = 0;
    
    for (ReviewImageAttachment *imageAttachment in review.review_image_attachment) {
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:imageAttachment.uri_large]];
        [request addValue:@"image/*" forHTTPHeaderField:@"Accept"];
        UIImageView *imageView = [UIImageView new];
        [imageView setImageWithURLRequest:request
                         placeholderImage:[UIImage imageNamed:@"attached_image_placeholder.png"]
                                  success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                      _count++;
                                      [imageView setImage:image];
                                      [descriptionArray addObject:imageAttachment.desc?:@""];
                                      [imageArray addObject:imageView];
                                      if (_count == review.review_image_attachment.count) {
                                          [_navigator navigateToShowImageFromViewController:self withImageDictionaries:imageArray imageDescriptions:descriptionArray indexImage:index];
                                      }
                                  }
                                  failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                                      
                                      
                                  }];
        
    }
}

#pragma mark - Keyboard Notification
- (void)keyboardWillShow:(NSNotification*)notification {
    // get keyboard size and loctaion
    CGRect keyboardBounds;
    [[notification.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue: &keyboardBounds];
    NSNumber *duration = notification.userInfo[UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = notification.userInfo[UIKeyboardAnimationCurveUserInfoKey];
    
    // Need to translate the bounds to account for rotation.
    keyboardBounds = [self.view convertRect:keyboardBounds toView:nil];
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:[duration doubleValue]];
    [UIView setAnimationCurve:[curve intValue]];
    
    _responseViewBottomConstraint.constant = keyboardBounds.size.height;
    [self.view layoutIfNeeded];
    
    [_giveResponseView becomeFirstResponder];
    [UIView commitAnimations];
}

- (void)keyboardWillHide:(NSNotification*)notification {
    // get keyboard size and loctaion
    CGRect keyboardBounds;
    [[notification.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue: &keyboardBounds];
    NSNumber *duration = notification.userInfo[UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = notification.userInfo[UIKeyboardAnimationCurveUserInfoKey];
    
    // Need to translate the bounds to account for rotation.
    keyboardBounds = [self.view convertRect:keyboardBounds toView:nil];
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:[duration doubleValue]];
    [UIView setAnimationCurve:[curve intValue]];
    
    
    _responseViewBottomConstraint.constant = 0;
    [self.view layoutIfNeeded];
    
    [_giveResponseView resignFirstResponder];
    [UIView commitAnimations];
}

@end
