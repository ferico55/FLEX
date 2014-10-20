//
//  SortCell.m
//  Tokopedia
//
//  Created by IT Tkpd on 9/17/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "sortfiltershare.h"
#import "SortCell.h"

@implementation SortCell

@synthesize delegate = _delegate;

#pragma mark - Factory methods

+ (id)newcell
{
    NSArray* a = [[NSBundle mainBundle] loadNibNamed:@"SortCell" owner:nil options:0];
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

#pragma mark - Properties
-(void)setData:(NSDictionary *)data
{
    _data = data;
    if (data) {
        NSDictionary *detaildata = [_data objectForKey:kTKPDSORT_DATASORTKEY];
        _label.text = [detaildata objectForKey:kTKPDFILTER_DATASORTNAMEKEY];
    }
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
                NSIndexPath *indexpath = [_data objectForKey:kTKPDFILTER_DATAINDEXPATHKEY];
                [_delegate SortCell:self withindexpath:indexpath];
                break;
            }
        }
    }
    
}

@end
