//
//  HotListCell.m
//  Tokopedia
//
//  Created by IT Tkpd on 8/19/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "string_home.h"
#import "HotlistCell.h"

@interface HotlistCell ()

@property (weak, nonatomic) IBOutlet UIView *contentSubview;

@end

@implementation HotlistCell

@synthesize delegate = _delegate;

#pragma mark - Factory methods

+ (id)newcell
{
    NSArray* a = [[NSBundle mainBundle] loadNibNamed:@"HotlistCell" owner:nil options:0];
    for (id o in a) {
        if ([o isKindOfClass:[self class]]) {
            return o;
        }
    }
    return nil;
}

#pragma mark - Initialization

- (void)awakeFromNib
{
    _productimageview.multipleTouchEnabled = NO;
    _productimageview.exclusiveTouch = YES;
    
//    _contentSubview.layer.shadowColor = [UIColor blackColor].CGColor;
//    _contentSubview.layer.shadowOffset = CGSizeMake(0, 0.3);
//    _contentSubview.layer.shadowOpacity = 0.2;
//    _contentSubview.layer.shadowRadius = 0.5;
//    _contentSubview.layer.shadowPath = [UIBezierPath bezierPathWithRect:_contentSubview.bounds].CGPath;
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
                [_delegate HotlistCell:self withindexpath:_indexpath withimageview:_productimageview];
                break;
            }
                
            default:
                break;
        }
    }
    else if ([sender isKindOfClass:[UISwipeGestureRecognizer class]])
    {
        UISwipeGestureRecognizer *swipeRecognizer = (UISwipeGestureRecognizer *)sender;
        if (swipeRecognizer.direction == UISwipeGestureRecognizerDirectionLeft )
        {
            NSLog(@"left");
        }
        else
        {
            NSLog(@"Right");
        }        
    }
}

@end
