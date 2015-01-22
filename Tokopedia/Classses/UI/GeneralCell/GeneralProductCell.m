//
//  GeneralProductCell.m
//  Tokopedia
//
//  Created by IT Tkpd on 9/2/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "string_home.h"
#import "GeneralProductCell.h"

@interface GeneralProductCell ()

@property (strong, nonatomic) IBOutlet UIView *firstContentSubview;
@property (strong, nonatomic) IBOutlet UIView *secondContentSubview;

@end

@implementation GeneralProductCell

#pragma mark - Factory Methods
+ (id)newcell
{
    NSArray* a = [[NSBundle mainBundle] loadNibNamed:@"GeneralProductCell" owner:nil options:0];
    for (id o in a) {
        if ([o isKindOfClass:[self class]]) {
            return o;
        }
    }
    return nil;
}

- (void)awakeFromNib
{
//    _firstContentSubview.layer.shadowColor = [UIColor blackColor].CGColor;
//    _firstContentSubview.layer.shadowOffset = CGSizeMake(0, 0.3);
//    _firstContentSubview.layer.shadowOpacity = 0.2;
//    _firstContentSubview.layer.shadowRadius = 0.5;
//
//    _secondContentSubview.layer.shadowColor = [UIColor blackColor].CGColor;
//    _secondContentSubview.layer.shadowOffset = CGSizeMake(0, 0.3);
//    _secondContentSubview.layer.shadowOpacity = 0.2;
//    _secondContentSubview.layer.shadowRadius = 0.5;
    
    _viewcell = [NSArray sortViewsWithTagInArray:_viewcell];
    _act = [NSArray sortViewsWithTagInArray:_act];
    _thumb = [NSArray sortViewsWithTagInArray:_thumb];
    _labelalbum = [NSArray sortViewsWithTagInArray:_labelalbum];
    _labelprice = [NSArray sortViewsWithTagInArray:_labelprice];
    _labeldescription = [NSArray sortViewsWithTagInArray:_labeldescription];
    
    [_viewcell makeObjectsPerformSelector:@selector(setExclusiveTouch:) withObject:@(YES)];
    [_thumb makeObjectsPerformSelector:@selector(setExclusiveTouch:) withObject:@(YES)];
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
                NSInteger row = indexpath.row;
                NSIndexPath *indexpath1 = [NSIndexPath indexPathForRow:row inSection:gesture.view.tag-10];
                [_delegate GeneralProductCell:self withindexpath:indexpath1];
                break;
            }
        }
    }
}

@end