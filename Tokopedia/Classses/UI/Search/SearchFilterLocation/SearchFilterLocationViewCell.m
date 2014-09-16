//
//  SearchFilterLocationViewCell.m
//  Tokopedia
//
//  Created by IT Tkpd on 9/5/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "SearchFilterLocationViewCell.h"

@implementation SearchFilterLocationViewCell

#pragma mark - Factory methods

+ (id)newcell
{
    NSArray* a = [[NSBundle mainBundle] loadNibNamed:@"SearchFilterLocationViewCell" owner:nil options:0];
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
        UITapGestureRecognizer *gesture = (UITapGestureRecognizer *)sender;
        [_delegate SearchFilterLocationViewCell:self withdata:_data];
    }
}

#pragma mark - Properties
-(void)setData:(NSDictionary *)data
{
    _data = data;
    
    if (data) {
        //NSDictionary *column = [_data objectForKey:@"column"];
        _label.text = [_data objectForKey:@"column"];
    }
}


@end
