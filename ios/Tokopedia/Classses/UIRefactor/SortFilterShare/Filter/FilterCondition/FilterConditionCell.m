//
//  FilterConditionCell.m
//  Tokopedia
//
//  Created by IT Tkpd on 10/2/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "sortfiltershare.h"
#import "FilterConditionCell.h"

#pragma mark - Filter Location View Cell
@implementation FilterConditionCell

#pragma mark - Factory methods
+ (id)newcell
{
    NSArray* a = [[NSBundle mainBundle] loadNibNamed:@"FilterConditionCell" owner:nil options:0];
    for (id o in a) {
        if ([o isKindOfClass:[self class]]) {
            return o;
        }
    }
    return nil;
}

- (void)awakeFromNib
{
    // Initialization code
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
                [_delegate FilterConditionCell:self withindexpath:indexpath];
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
        NSDictionary* column = [_data objectForKey:kTKPDFILTER_DATACOLUMNKEY];
        _label.text = [column objectForKey:kTKPDFILTER_DATASORTNAMEKEY];
    }
}

@end