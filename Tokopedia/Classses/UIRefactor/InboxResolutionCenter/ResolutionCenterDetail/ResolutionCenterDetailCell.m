//
//  ResolutionCenterDetailCell.m
//  Tokopedia
//
//  Created by IT Tkpd on 3/3/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "ResolutionCenterDetailCell.h"

@implementation ResolutionCenterDetailCell

#pragma mark - Factory methods
+ (id)newCell
{
    NSArray* a = [[NSBundle mainBundle] loadNibNamed:@"ResolutionCenterDetailCell" owner:nil options:0];
    for (id o in a) {
        if ([o isKindOfClass:[self class]]) {
            return o;
        }
    }
    return nil;
}

-(void)setIsMark:(BOOL)isMark
{
//    _isMark = isMark;
//    if (!_isMark) {
//        CGRect frame = _markView.frame;
//        frame.size.height = 0;
//        _markView.frame = frame;
//        
//        frame = _atachmentView.frame;
//        frame.origin.y = _markView.frame.origin.y + _markView.frame.size.height;
//        _atachmentView.frame = frame;
//        [_containerView addSubview:_atachmentView];
//        
//        frame = _oneButtonView.frame;
//        frame.origin.y = 104;
//        _oneButtonView.frame = frame;
//        [_atachmentView addSubview:_oneButtonView];
//    }
}

//-(void)setIsShowAttachment:(BOOL)isShowAttachment
//{
//    _isShowAttachment = isShowAttachment;
//    if (isShowAttachment) {
//        CGRect frame = _oneButtonView.frame;
//        frame.origin.y = 104;
//        _oneButtonView.frame = frame;
//        [_atachmentView addSubview:_oneButtonView];
//        
//        frame = _twoButtonView.frame;
//        frame.origin.y = _markView.frame.origin.y + _markView.frame.size.height;
//        _twoButtonView.frame = frame;
//        [_atachmentView addSubview:_twoButtonView];
//    }
//    else
//    {
//        CGRect frame = _oneButtonView.frame;
//        frame.origin.y = _markView.frame.origin.y + _markView.frame.size.height;
//        _oneButtonView.frame = frame;
//        [_containerView addSubview:_oneButtonView];
//        
//        frame = _twoButtonView.frame;
//        frame.origin.y = _markView.frame.origin.y + _markView.frame.size.height;
//        _twoButtonView.frame = frame;
//        [_containerView addSubview:_twoButtonView];
//        
//    }
//}

- (void)awakeFromNib {
    
//    CGRect frame = _atachmentView.frame;
//    frame.origin.y = _markView.frame.origin.y + _markView.frame.size.height;
//    _atachmentView.frame = frame;
//    [_containerView addSubview:_atachmentView];
//    
//    frame = _atachmentView.frame;
//    frame.origin.y = _markView.frame.origin.y + _markView.frame.size.height;
//    _atachmentView.frame = frame;
//    [_containerView addSubview:_atachmentView];
//    

}
- (IBAction)tap:(id)sender {
    [_delegate tapCellButton:(UIButton*)sender atIndexPath:_indexPath];
}

- (void)hideAllViews
{
    [_attachmentImages makeObjectsPerformSelector:@selector(setImage:) withObject:nil];
    _oneButtonView.hidden = YES;
    _twoButtonView.hidden = YES;
    _atachmentView.hidden = YES;
    
}
- (IBAction)gesture:(UITapGestureRecognizer*)sender {
    if (sender.view.tag == 15) {
        [_delegate goToShopOrProfileIndexPath:_indexPath];
    }
    else
    {
        [_delegate goToImageViewerIndex:sender.view.tag-10 atIndexPath:_indexPath];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [self.contentView layoutIfNeeded];
    self.markLabel.preferredMaxLayoutWidth = CGRectGetWidth(self.markLabel.frame);
}

@end
