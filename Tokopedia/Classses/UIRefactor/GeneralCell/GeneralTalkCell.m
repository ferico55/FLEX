//
//  GeneralTalkCell.m
//  Tokopedia
//
//  Created by IT Tkpd on 9/29/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "GeneralTalkCell.h"
#import "ProductTalkDetailViewController.h"
#import "ProfileBiodataViewController.h"
#import "ProfileFavoriteShopViewController.h"
#import "ProfileContactViewController.h"
#import "TKPDTabProfileNavigationController.h"

#import "TalkList.h"
#import "TKPDSecureStorage.h"

#import "DetailProductViewController.h"

#import "detail.h"

@interface GeneralTalkCell () <UIActionSheetDelegate>

@end

@implementation GeneralTalkCell

#pragma mark - Factory Methods
+ (id)newcell
{
    NSArray* a = [[NSBundle mainBundle] loadNibNamed:@"GeneralTalkCell" owner:nil options:0];
    NSLog(@"%@", @"New Cell");
    for (id o in a) {
        if ([o isKindOfClass:[self class]]) {
            return o;
        }
    }
    return nil;
}

- (void)awakeFromNib
{
    // round user profile picture
    self.thumb.layer.cornerRadius = self.thumb.layer.frame.size.width / 2;
    
    // add gesture to product image
    UITapGestureRecognizer* productGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapProduct)];
    [self.productImageView addGestureRecognizer:productGesture];
    [self.productImageView setUserInteractionEnabled:YES];
    
    // add gesture to label message
    UITapGestureRecognizer *messageGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapMessage)];
    [self.commentlabel addGestureRecognizer:messageGesture];
    [self.commentlabel setUserInteractionEnabled:YES];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setProductViewIsHidden:(BOOL)productViewIsHidden
{
    _productViewIsHidden = productViewIsHidden;
    if (productViewIsHidden) {
        CGRect middleViewFrame = self.middleView.frame;
        middleViewFrame.size.height = 0;
        self.middleView.frame = middleViewFrame;
        self.middleView.hidden = YES;
        
        CGRect buttonsViewFrame = self.buttonsView.frame;
        buttonsViewFrame.origin.y = 113;
        self.buttonsView.frame = buttonsViewFrame;
        
        CGRect subContentViewFrame = self.subContentView.frame;
        subContentViewFrame.size.height = 113 + self.buttonsView.frame.size.height;
        self.subContentView.frame = subContentViewFrame;
    }
}

- (void)setTalkFollowStatus:(BOOL)talkFollowStatus
{
    _talkFollowStatus = talkFollowStatus;
    if (talkFollowStatus) {
        [_unfollowButton setTitle:@"Berhenti Ikuti" forState:UIControlStateNormal];
        [_unfollowButton setImage:[UIImage imageNamed:@"icon_diskusi_unfollow_grey"] forState:UIControlStateNormal];
        
    } else {
        [_unfollowButton setTitle:@"Ikuti" forState:UIControlStateNormal];
        [_unfollowButton setImage:[UIImage imageNamed:@"icon_check_grey"] forState:UIControlStateNormal];
    }
}



#pragma mark - View Action
- (void)tapProduct {
    NSIndexPath* indexpath = _indexpath;
    
    TalkList *talkList = (TalkList *)_data;
    NSString *productId = talkList.talk_product_id;
    UINavigationController *nav = [_delegate navigationController:self withindexpath:indexpath];
    
    DetailProductViewController *vc = [DetailProductViewController new];
    vc.data = @{kTKPDDETAIL_APIPRODUCTIDKEY : productId};
    [nav.navigationController pushViewController:vc animated:YES];
}

- (void)tapMessage {
    NSIndexPath* indexpath = _indexpath;
    
    [_delegate GeneralTalkCell:self withindexpath:indexpath];
}

-(IBAction)tap:(id)sender
{
    if ([sender isKindOfClass:[UIButton class]]) {
        UIButton *btn = (UIButton *)sender;
        NSIndexPath* indexpath = _indexpath;
        switch (btn.tag) {
            case 10:
            {
                [_delegate GeneralTalkCell:self withindexpath:indexpath];
                break;
            }
                
            case 11 :
            {
                [_delegate unfollowTalk:self withindexpath:indexpath withButton:_unfollowButton];
                NSLog(@"Running this");
                break;
            }
                
            case 12 :
            {
                [_delegate reportTalk:self withindexpath:indexpath];
                break;
            }
                
            case 13 :
            {
                [_delegate deleteTalk:self withindexpath:indexpath];
                break;
            }
            //click user
            case 14 :
            {
                TalkList *talkList = (TalkList *)_data;

                TKPDSecureStorage* secureStorage = [TKPDSecureStorage standardKeyChains];
                NSDictionary* auth = [secureStorage keychainDictionary];
                auth = [auth mutableCopy];

                NSMutableArray *viewcontrollers = [NSMutableArray new];
    
                /** create new view controller **/
                ProfileBiodataViewController *v = [ProfileBiodataViewController new];
                [viewcontrollers addObject:v];
                
                ProfileFavoriteShopViewController *v1 = [ProfileFavoriteShopViewController new];
                v1.data = @{kTKPDFAVORITED_APIUSERIDKEY:@(talkList.talk_user_id),
                            kTKPDDETAIL_APISHOPIDKEY:talkList.talk_shop_id,
                            kTKPD_AUTHKEY:auth};
                [viewcontrollers addObject:v1];
                
                ProfileContactViewController *v2 = [ProfileContactViewController new];
                [viewcontrollers addObject:v2];

                TKPDTabProfileNavigationController *tapnavcon = [TKPDTabProfileNavigationController new];
                tapnavcon.data = @{kTKPDFAVORITED_APIUSERIDKEY:@(talkList.talk_user_id),
                                   kTKPD_AUTHKEY:auth};
                [tapnavcon setViewControllers:viewcontrollers animated:YES];
                [tapnavcon setSelectedIndex:0];
                
                UINavigationController *nav = [_delegate navigationController:self withindexpath:indexpath];
                
                [nav.navigationController pushViewController:tapnavcon animated:YES];
                break;
            }
                
            //click product
            case 15 :
            {
                TalkList *talkList = (TalkList *)_data;
                NSString *productId = talkList.talk_product_id;
                UINavigationController *nav = [_delegate navigationController:self withindexpath:indexpath];
                
                DetailProductViewController *vc = [DetailProductViewController new];
                vc.data = @{kTKPDDETAIL_APIPRODUCTIDKEY : productId};
                [nav.navigationController pushViewController:vc animated:YES];
                
                break;
            }
                
            case 16:
            {
                TKPDSecureStorage *secureStorage = [TKPDSecureStorage standardKeyChains];
                NSDictionary *auth = [secureStorage keychainDictionary];
                auth = [auth mutableCopy];
                
                TalkList *talkList = (TalkList *)_data;

                NSMutableArray *buttonTitles = [[NSMutableArray alloc] init];
                // Check whether the comment is belong to the logged in user,
                // or the comment is on the user's shop
                NSInteger loginUserId = [[auth objectForKey:@"user_id"] integerValue];
                NSString *talkIsOwner = talkList.talk_own;
                
                if ((loginUserId == talkList.talk_user_id && talkList.talk_user_id)
                    || talkIsOwner.length > 0
                    ) {
                    [buttonTitles addObject:@"Hapus"];
                }
                
                // If the comment is not user's comment, Report button added
                if (loginUserId && loginUserId != talkList.talk_user_id && !talkIsOwner.length) {
                    [buttonTitles addObject:@"Lapor"];
                }
                
                NSString *otherButtonTitles = [buttonTitles componentsJoinedByString:@","];

                UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                                         delegate:self
                                                                cancelButtonTitle:@"Batal"
                                                           destructiveButtonTitle:nil
                                                                otherButtonTitles:otherButtonTitles, nil];
                [actionSheet showInView:self.contentView];
            }
                
            default:
                break;
        }
    }
}

#pragma mark - Action sheet delegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    TKPDSecureStorage *secureStorage = [TKPDSecureStorage standardKeyChains];
    NSDictionary *auth = [secureStorage keychainDictionary];
    auth = [auth mutableCopy];
    
    TalkList *talkList = (TalkList *)_data;
    NSInteger cancelButtonIndex = actionSheet.cancelButtonIndex;

    if (buttonIndex == 0) {
        // if the comment is belong to the logged in user, the cliked button is delete button
        if ([talkList.talk_shop_id isEqualToString:[[auth objectForKey:@"shop_id"] stringValue]] ||
            talkList.talk_user_id == [[auth objectForKey:@"user_id"] integerValue]) {
            
            [_delegate deleteTalk:self withindexpath:_indexpath];

        // if not belong to the logged in user, clicked button is report button
        } else {
            [_delegate reportTalk:self withindexpath:_indexpath];
        }
    }
    // if button index is 2, then the cliked button at index 1 is report button
    else if (buttonIndex != cancelButtonIndex) {
         [_delegate reportTalk:self withindexpath:_indexpath];
    }

}


@end
