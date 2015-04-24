//
//  CreateShopCell.m
//  Tokopedia
//
//  Created by Tokopedia on 4/15/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "CreateShopCell.h"
#import "string_create_shop.h"

@implementation CreateShopCell
- (CreateShopCell *)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    CreateShopCell *result = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(result)
    {
        lblDomain = [[UILabel alloc] initWithFrame:CGRectMake(CPaddingLeft, CPaddingLeft, (self.bounds.size.width/1.9f)-(CPaddingLeft*2), self.bounds.size.height-(CPaddingLeft*2))];
        lblDomain.backgroundColor = [UIColor clearColor];
        lblDomain.text = CStringRootDomain;
        lblDomain.font = [UIFont fontWithName:CFont_Gotham_Book size:CFontSizeFooter];
        [result.contentView addSubview:lblDomain];
    }
    
    return result;
}

- (UILabel *)getLblDomain
{
    return lblDomain;
}
@end
