//
//  ProductEditWholesaleCell.m
//  Tokopedia
//
//  Created by IT Tkpd on 12/11/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "string_product.h"
#import "ProductEditWholesaleCell.h"

@implementation ProductEditWholesaleCell

#pragma mark - Factory methods
+ (id)newcell
{
    NSArray* a = [[NSBundle mainBundle] loadNibNamed:@"ProductEditWholesaleCell" owner:nil options:0];
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

#pragma mark - View Action
- (IBAction)tap:(id)sender {
    [_delegate removeCell:self atIndexPath:_indexPath];
}

#pragma mark - Textfield Delegate
-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    [textField resignFirstResponder];
    [_delegate ProductEditWholesaleCell:self textFieldShouldBeginEditing:textField withIndexPath:_indexPath];
    return YES;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [_delegate ProductEditWholesaleCell:self textFieldShouldReturn:textField withIndexPath:_indexPath];
    return YES;
}

-(BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    [_delegate ProductEditWholesaleCell:self textFieldShouldEndEditing:textField withIndexPath:_indexPath];
    return YES;
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    [_delegate ProductEditWholesaleCell:self textField:textField shouldChangeCharactersInRange:range replacementString:string];
    return YES;
}

@end
