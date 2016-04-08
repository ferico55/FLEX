//
//  EtalaseCell.m
//  Tokopedia
//
//  Created by Johanes Effendi on 4/5/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import "EtalaseCell.h"

@implementation EtalaseCell

+ (id)newcell
{
    NSArray* a = [[NSBundle mainBundle] loadNibNamed:@"EtalaseCell" owner:nil options:0];
    for (id o in a) {
        if ([o isKindOfClass:[self class]]) {
            return o;
        }
    }
    return nil;
}

- (void)awakeFromNib {
    [_checkImageView setHidden:YES];
    if(_isEditable){
        [_deleteImageView setHidden:NO];
    }else{
        [_deleteImageView setHidden:YES];
    }
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    if(selected){
        if(_showCheckImage){
            [_checkImageView setHidden:NO];
            self.accessoryType = UITableViewCellAccessoryNone;
        }
        [_nameLabel setTextColor:[UIColor colorWithRed:(66/255.0) green:(189/255.0) blue:(65/255.0) alpha:1]];
    }else{
        [_checkImageView setHidden:YES];
        [_nameLabel setTextColor:[UIColor blackColor]];
    }
}

- (IBAction)deleteGestureTapped:(id)sender {
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
                [_delegate deleteEtalaseWithIndexPath:_indexpath];
                break;
            }
                
            default:
                break;
        }
        
    }
}

@end
