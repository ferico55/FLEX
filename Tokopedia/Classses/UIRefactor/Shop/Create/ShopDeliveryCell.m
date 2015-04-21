//
//  ShopDeliveryCell.m
//  Tokopedia
//
//  Created by Tokopedia on 4/16/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "ShopDeliveryCell.h"
#import "string_create_shop.h"

@implementation ShopDeliveryCell

- (void)awakeFromNib {
    // Initialization code
}

- (ShopDeliveryCell *)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    ShopDeliveryCell *cell = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(cell)
    {
        cell.contentView.backgroundColor = [UIColor clearColor];
        lblText = [[UILabel alloc] initWithFrame:CGRectMake(CPaddingLeft, 0, cell.bounds.size.width/2.0f, cell.bounds.size.height)];
        lblText.backgroundColor = [UIColor clearColor];
        lblText.font = [UIFont fontWithName:CFont_Gotham_Book size:CFontSizeHeader];
        [cell.contentView addSubview:lblText];
        
        txtField = [[UITextField alloc] initWithFrame:CGRectMake(lblText.frame.origin.x+lblText.bounds.size.width, 0, cell.bounds.size.width-(CPaddingLeft*3)-(lblText.frame.origin.x+lblText.bounds.size.width), cell.bounds.size.height)];
        txtField.textAlignment = NSTextAlignmentRight;
        txtField.backgroundColor = [UIColor clearColor];
        txtField.placeholder = @"1234";
        txtField.font = [UIFont fontWithName:CFont_Gotham_Book size:CFontSizeHeader];
        [cell.contentView addSubview:txtField];
        
        lblValue = [[UILabel alloc] initWithFrame:txtField.frame];
        lblValue.backgroundColor = [UIColor clearColor];
        lblValue.textColor = [UIColor blueColor];
        lblValue.textAlignment = NSTextAlignmentRight;
        lblValue.font = [UIFont fontWithName:CFont_Gotham_Book size:CFontSizeHeader];
        [cell.contentView addSubview:lblValue];
    }
    
    return cell;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}



#pragma mark - Method
- (UILabel *)getLblValue
{
    return lblValue;
}

- (UILabel *)getLblText
{
    return lblText;
}

- (UITextField *)getTxtField
{
    return txtField;
}
@end
