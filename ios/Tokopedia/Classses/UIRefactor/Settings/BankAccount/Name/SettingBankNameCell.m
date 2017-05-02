//
//  SettingBankNameCell.m
//  Tokopedia
//
//  Created by IT Tkpd on 11/7/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "profile.h"
#import "SettingBankNameCell.h"

@implementation SettingBankNameCell

#pragma mark - Factory methods
+ (id)newcell
{
    NSArray* a = [[NSBundle mainBundle] loadNibNamed:@"SettingBankNameCell" owner:nil options:0];
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
        // Initialization code
    }
    return self;
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
        switch (gesture.state) {
            case UIGestureRecognizerStateBegan: {
                break;
            }
            case UIGestureRecognizerStateChanged: {
                break;
            }
            case UIGestureRecognizerStateEnded: {
                NSIndexPath *indexpath = [_data objectForKey:kTKPDPROFILE_DATAINDEXPATHKEY];
                [_delegate SettingBankNameCell:self withindexpath:indexpath];
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
        _label.text = [_data objectForKey:kTKPDPROFILE_DATALOCATIONNAMEKEY];
    }
}

@end
