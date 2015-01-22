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
                NSIndexPath *indexPath = _indexpath;
                
                UIAlertView *alert = [[UIAlertView alloc]
                                      initWithTitle:@"Skip Review"
                                      message:@"Are you sure you want to skip this review ?"
                                      delegate:self
                                      cancelButtonTitle:@"Cancel"
                                      otherButtonTitles:nil];
                
                [alert addButtonWithTitle:@"Skip"];
                [alert show];
                break;
            }
                
            case 15 :
            {
                NSIndexPath* indexpath = _indexpath;
                
                ReviewFormViewController *vc = [ReviewFormViewController new];
                
                UINavigationController *nav = [_delegate navigationController:self withindexpath:indexpath];
                vc.data = _data;
                vc.isEditForm = YES;
                [nav.navigationController pushViewController:vc animated:YES];
                break;
                
            }
                
            default:
                break;
        }
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    //delete talk
    if(buttonIndex == 1) {
        NSIndexPath* indexpath = _indexpath;
        [_delegate skipReview:self withindexpath:indexpath];
    }
}

@end
