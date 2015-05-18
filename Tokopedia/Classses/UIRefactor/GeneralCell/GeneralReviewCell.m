
//
//  GeneralReviewCell.m
//  Tokopedia
//
//  Created by IT Tkpd on 10/9/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "GeneralReviewCell.h"
#import "ReviewFormViewController.h"
#import "ReviewList.h"
#import "stringrestkit.h"
#import "NavigateViewController.h"
#import "string_inbox_review.h"

#pragma mark - General Review Cell
@implementation GeneralReviewCell

#pragma mark - Factory Methods
+ (id)newcell
{
    NSArray* a = [[NSBundle mainBundle] loadNibNamed:@"GeneralReviewCell" owner:nil options:0];
    for (id o in a) {
        if ([o isKindOfClass:[self class]]) {
            return o;
        }
    }
    return nil;
}

- (void)awakeFromNib
{
    self.userImageView.layer.cornerRadius = self.userImageView.frame.size.width/2;
    
    UITapGestureRecognizer *userGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapUser)];
    [_userTapView addGestureRecognizer:userGes];
    [_userTapView setUserInteractionEnabled:YES];
    
    
    UITapGestureRecognizer *productGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapProduct)];
    [_productTapView addGestureRecognizer:productGes];
    [_productTapView setUserInteractionEnabled:YES];
    
    UITapGestureRecognizer *reviewGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapReview)];
    [_reviewTapView addGestureRecognizer:reviewGes];
    [_reviewTapView setUserInteractionEnabled:YES];
    

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#pragma mark - View Action
-(IBAction)tap:(id)sender
{
    if ([sender isKindOfClass:[UIButton class]]) {
        UIButton *btn = (UIButton *)sender;
        switch (btn.tag) {
            case 10:
            {
                
                NSIndexPath* indexpath = _indexpath;
                [_delegate GeneralReviewCell:self withindexpath:indexpath];

                break;
            }
            case 11 :
            {
                
                NSIndexPath* indexpath = _indexpath;

                ReviewFormViewController *vc = [ReviewFormViewController new];
                
                UINavigationController *nav = [_delegate navigationController:self withindexpath:indexpath];
                vc.data = _data;
                vc.reviewIndex = indexpath.row;
                [nav.navigationController pushViewController:vc animated:YES];
                break;
            }
                
            case 12 :
            {
                
                UIAlertView *alert = [[UIAlertView alloc]
                                      initWithTitle:@"Lewati"
                                      message:@"Apakah kamu yakin ingin melewati ulasan ini ?"
                                      delegate:self
                                      cancelButtonTitle:@"Batal"
                                      otherButtonTitles:nil];
                
                [alert addButtonWithTitle:@"Lewati"];
                [alert show];
                break;
            }
                
            case 15 :
            {
                NSIndexPath* indexpath = _indexpath;
                
                ReviewFormViewController *vc = [ReviewFormViewController new];
                
                UINavigationController *nav = [_delegate navigationController:self withindexpath:indexpath];
                vc.data = _data;
                vc.reviewIndex = indexpath.row;
                vc.isEditForm = YES;
                [nav.navigationController pushViewController:vc animated:YES];
                break;
                
            }
                
            case 16 : {
                [_delegate reportReview:self withindexpath:_indexpath];
                break;
            }
                
            default:
                break;
        }
    }
}

- (void)tapProduct {
    NavigateViewController *navigation = [NavigateViewController new];
    NSIndexPath* indexpath = _indexpath;
    UINavigationController *nav = [_delegate navigationController:self withindexpath:indexpath];
    
    ReviewList *list = (ReviewList *)_data;
    if(![list.review_product_status isEqualToString:STATE_PRODUCT_BANNED] && ![list.review_product_status isEqualToString:STATE_PRODUCT_DELETED]) {
        [navigation navigateToProductFromViewController:nav withProductID:list.review_product_id];
    }

}

- (void)tapReview {
    NSIndexPath* indexpath = _indexpath;
    
    ReviewList *list = (ReviewList*)_data;
    if([list.review_id isEqualToString:NEW_REVIEW_STATE]) {
        NSIndexPath* indexpath = _indexpath;
        
        ReviewFormViewController *vc = [ReviewFormViewController new];
        
        UINavigationController *nav = [_delegate navigationController:self withindexpath:indexpath];
        vc.data = _data;
        vc.reviewIndex = indexpath.row;
        [nav.navigationController pushViewController:vc animated:YES];
    } else {
        [_delegate GeneralReviewCell:self withindexpath:indexpath];
    }
    

}

- (void)tapUser {
    NavigateViewController *navigation = [NavigateViewController new];
    NSIndexPath* indexpath = _indexpath;
    UINavigationController *nav = [_delegate navigationController:self withindexpath:indexpath];
    
    ReviewList *list = (ReviewList *)_data;
    [navigation navigateToProfileFromViewController:nav withUserID:list.review_user_id];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    //delete talk
    if(buttonIndex == 1) {
        NSIndexPath* indexpath = _indexpath;
        [_delegate skipReview:self withindexpath:indexpath];
    }
}

@end
