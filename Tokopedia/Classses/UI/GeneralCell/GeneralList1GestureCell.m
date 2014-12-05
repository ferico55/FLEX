//
//  GeneralList1GestureCell.m
//  Tokopedia
//
//  Created by IT Tkpd on 11/4/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "generalcell.h"
#import "GeneralList1GestureCell.h"

@interface GeneralList1GestureCell ()
@property (weak, nonatomic) IBOutlet UIButton *buttondelete;
@property (weak, nonatomic) IBOutlet UIView *viewcell;


@end

@implementation GeneralList1GestureCell

#pragma mark - Factory methods
+ (id)newcell
{
    NSArray* a = [[NSBundle mainBundle] loadNibNamed:@"GeneralList1GestureCell" owner:nil options:0];
    for (id o in a) {
        if ([o isKindOfClass:[self class]]) {
            return o;
        }
    }
    return nil;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
    }
    return self;
}

- (void)awakeFromNib
{
    self.buttondefault.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    self.buttondefault.titleLabel.textAlignment = NSTextAlignmentCenter;
    [self.buttondefault setTitle: @"Set as\nDefault" forState: UIControlStateNormal];
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
                //[_delegate GeneralList1GestureCell:self withindexpath:_indexpath];
                break;
            }
        }
    }

    if (_type==kTKPDGENERALCELL_DATATYPETWOBUTTONKEY)
    {
       if ([sender isKindOfClass:[UISwipeGestureRecognizer class]]) {
            UISwipeGestureRecognizer *swipe = (UISwipeGestureRecognizer*)sender;
            switch (swipe.state) {
                case UIGestureRecognizerStateBegan: {
                    break;
                }
                case UIGestureRecognizerStateChanged: {
                    break;
                }
                case UIGestureRecognizerStateEnded: {
                    //TODO
                    if (swipe.direction == UISwipeGestureRecognizerDirectionRight) {
                        [self viewdetailresetposanimation:YES];
                    }
                    if (swipe.direction == UISwipeGestureRecognizerDirectionLeft) {
                        [self viewdetailshowanimation:YES];
                    }

                    break;
                }
            }
        }
    }
}

- (IBAction)tap:(id)sender {
    if ([sender isKindOfClass:[UIButton class]]) {
        UIButton *btn = (UIButton*)sender;
        //[_delegate DidTapButton:btn atCell:self withindexpath:_indexpath];
    }
}

#pragma mark - Methods
-(void)viewdetailshowanimation:(BOOL)animated
{
    if (animated) {
        [UIView animateWithDuration:0.5
                              delay:0
                            options: UIViewAnimationCurveEaseOut
                         animations:^{
                             CGRect frame = _viewcell.frame;
                             if(frame.origin.x == 0){
                                 switch (_type) {
                                     case kTKPDGENERALCELL_DATATYPEONEBUTTONKEY:
                                         frame.origin.x -= (_buttondelete.frame.size.width);
                                         _buttondefault.hidden = YES;
                                         _buttondelete.hidden = NO;
                                         break;
                                     case kTKPDGENERALCELL_DATATYPETWOBUTTONKEY:
                                         frame.origin.x -= (_buttondelete.frame.size.width+_buttondefault.frame.size.width);
                                         _buttondefault.hidden = NO;
                                         _buttondelete.hidden = NO;
                                         break;
                                     default:
                                         frame.origin.x -= (_buttondelete.frame.size.width+_buttondefault.frame.size.width);
                                         _buttondefault.hidden = NO;
                                         _buttondelete.hidden = NO;
                                         break;
                                 }
                                 

                             }
                             [_viewcell setFrame:frame];
                         }
                         completion:^(BOOL finished){
                         }];
    }
}
-(void)viewdetailresetposanimation:(BOOL)animated
{
    if (animated) {
        [UIView animateWithDuration:0.5
                              delay:0
                            options: UIViewAnimationCurveEaseOut
                         animations:^{
                             CGRect frame = _viewcell.frame;
                             frame.origin.x = 0;
                             [_viewcell setFrame:frame];
                         }
                         completion:^(BOOL finished){
                             _buttondefault.hidden = YES;
                             _buttondelete.hidden = YES;
                         }];
    }
}

-(void)setType:(NSInteger)type
{
    _type = type;
    switch (type) {
        case kTKPDGENERALCELL_DATATYPEONEBUTTONKEY:
            _buttondefault.hidden = YES;
            _buttondelete.hidden = YES;
            break;
        case kTKPDGENERALCELL_DATATYPETWOBUTTONKEY:
            _buttondefault.hidden = NO;
            _buttondelete.hidden = NO;
        default:
            _buttondefault.hidden = YES;
            _buttondelete.hidden = YES;
            break;
    }
}

@end
