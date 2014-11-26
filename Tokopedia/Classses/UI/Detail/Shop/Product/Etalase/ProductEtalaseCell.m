//
//  ProductEtalaseCell.m
//  Tokopedia
//
//  Created by IT Tkpd on 10/13/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "detail.h"
#import "ProductEtalaseCell.h"

@implementation ProductEtalaseCell

@synthesize delegate = _delegate;

#pragma mark - Factory methods

+ (id)newcell
{
    NSArray* a = [[NSBundle mainBundle] loadNibNamed:@"ProductEtalaseCell" owner:nil options:0];
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
    
}

#pragma mark - Methods

-(void)reset
{
    
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
                [_delegate ProductEtalaseCell:self withindexpath:_indexpath ];
                break;
            }
        }
        
    }
    
}

@end
