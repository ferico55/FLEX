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
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self != nil)
    {
        lblDomain = [[UILabel alloc] initWithFrame:CGRectMake(CPaddingLeft+2, CPaddingLeft, (self.bounds.size.width/1.9f)-(CPaddingLeft*2), self.bounds.size.height-(CPaddingLeft*2))];
        lblDomain.backgroundColor = [UIColor clearColor];
        lblDomain.text = CStringRootDomain;
        lblDomain.font = [UIFont fontWithName:CFont_Gotham_Book size:CFontSizeFooter];
        [self.contentView addSubview:lblDomain];
    }
    
    return self;
}

- (UILabel *)getLblDomain
{
    return lblDomain;
}
@end
