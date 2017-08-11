//
//  FilterLocationViewCell.m
//  Tokopedia
//
//  Created by IT Tkpd on 9/5/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "sortfiltershare.h"
#import "FilterLocationViewCell.h"

#pragma mark - Filter Location View Cell
@implementation FilterLocationViewCell

#pragma mark - Factory methods
+ (id)newcell
{
    NSArray* a = [[NSBundle mainBundle] loadNibNamed:@"FilterLocationViewCell" owner:nil options:0];
    for (id o in a) {
        if ([o isKindOfClass:[self class]]) {
            return o;
        }
    }
    return nil;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#pragma mark - View Gestures
-(IBAction)gesture:(id)sender
{
    if ([sender isKindOfClass:[UITapGestureRecognizer class]]) {
        UITapGestureRecognizer *gesture = (UITapGestureRecognizer *)sender;
        switch (gesture.state) {
            case UIGestureRecognizerStateBegan: {
                break;
            }
            case UIGestureRecognizerStateChanged: {
                break;
            }
            case UIGestureRecognizerStateEnded: {
                NSIndexPath *indexpath = [_data objectForKey:kTKPDFILTER_DATAINDEXPATHKEY];
                [_delegate FilterLocationViewCell:self withindexpath:indexpath];
                break;
            }
            
            default:
                break;
        }
    }
}

#pragma mark - Properties
-(void)setData:(NSDictionary *)data
{
    _data = data;
    
    if (data) {
        _label.text = [_data objectForKey:kTKPDFILTER_DATACOLUMNKEY];
    }
}


@end
