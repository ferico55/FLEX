//
//  SearchResultCell.m
//  Tokopedia
//
//  Created by IT Tkpd on 8/28/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "SearchResultCell.h"

@interface SearchResultCell()

@end

@implementation SearchResultCell
{
}

#pragma mark - Factory methods

+ (id)newcell
{
    NSArray* a = [[NSBundle mainBundle] loadNibNamed:@"SearchResultCell" owner:nil options:0];
    for (id o in a) {
        if ([o isKindOfClass:[self class]]) {
            return o;
        }
    }
    return nil;
}

#pragma mark - Life Cycle
-(void)awakeFromNib
{
    [super awakeFromNib];
    _viewcell = [NSArray sortViewsWithTagInArray:_viewcell];
    _thumb = [NSArray sortViewsWithTagInArray:_thumb];
    _labelprice = [NSArray sortViewsWithTagInArray:_labelprice];
    _labeldescription = [NSArray sortViewsWithTagInArray:_labeldescription];
    _labelalbum = [NSArray sortViewsWithTagInArray:_labelalbum];
    _act = [NSArray sortViewsWithTagInArray:_act];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the  for the selected state
}

#pragma mark - View Action
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
                [_delegate SearchResultCell:self withindexpath:indexpath1];
                break;
            }
                
            default:
                break;
        }
    }
}


@end
