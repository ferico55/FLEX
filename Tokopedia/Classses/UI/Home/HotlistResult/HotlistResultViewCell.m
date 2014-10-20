//
//  HotlistResultViewCell.m
//  Tokopedia
//
//  Created by IT Tkpd on 9/2/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "home.h"
#import "HotlistResultViewCell.h"

@implementation HotlistResultViewCell

#pragma mark - Factory Methods
+ (id)newcell
{
    NSArray* a = [[NSBundle mainBundle] loadNibNamed:@"HotlistResultViewCell" owner:nil options:0];
    for (id o in a) {
        if ([o isKindOfClass:[self class]]) {
            return o;
        }
    }
    return nil;
}

- (void)awakeFromNib
{
    _viewcell = [NSArray sortViewsWithTagInArray:_viewcell];
    _act = [NSArray sortViewsWithTagInArray:_act];
    _thumb = [NSArray sortViewsWithTagInArray:_thumb];
    _labelalbum = [NSArray sortViewsWithTagInArray:_labelalbum];
    _labelprice = [NSArray sortViewsWithTagInArray:_labelprice];
    _labeldescription = [NSArray sortViewsWithTagInArray:_labeldescription];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#pragma mark - View Gesture
- (IBAction)gesture:(id)sender {
    
    if ([sender isKindOfClass:[UITapGestureRecognizer class]]) {
        UITapGestureRecognizer *gesture = (UITapGestureRecognizer*)sender;
        switch (gesture.state) {
            case UIGestureRecognizerStateBegan: {
                break;
            }
            case UIGestureRecognizerStateChanged: {
                break;
            }
            case UIGestureRecognizerStateEnded: {
                NSIndexPath* indexpath = _indexpath;
                NSIndexPath *indexpath1 = [NSIndexPath indexPathForRow:indexpath.row inSection:gesture.view.tag-10];
                [_delegate HotlistResultViewCell:self withindexpath:indexpath1];
                break;
            }
        }
        
    }
    
}
@end
