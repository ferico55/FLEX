//
//  ViewLabelUser.m
//  Tokopedia
//
//  Created by Tokopedia on 6/23/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//
#import "string_inbox_message.h"
#import "ViewLabelUser.h"

@implementation ViewLabelUser {
    UILabel *lblUser;
    UILabel *lblText;
}

@synthesize inboxMessageCell;

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self) {
        [self addView];
    }
    
    return self;
}

- (void)awakeFromNib
{
    [self addView];
}


#pragma mark - Method
- (void)addView
{
    lblUser = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 21)];
    lblText = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 21)];
    
    lblUser.layer.cornerRadius = 2.0f;
    lblUser.layer.masksToBounds = YES;
    lblUser.font = [UIFont microTheme];
    lblUser.layer.masksToBounds = YES;
    lblUser.textAlignment = NSTextAlignmentCenter;
    
    lblText.font = [UIFont smallTheme];
    lblText.textColor = [UIColor blackColor];
    
    [self addSubview:lblUser];
    [self addSubview:lblText];
}

- (float)calculateWidth:(NSString *)strText withFont:(UIFont *)font
{
    UILabel *tempLbl = [[UILabel alloc] init];
    tempLbl.text = strText;
    tempLbl.font = font;
    return [tempLbl sizeThatFits:CGSizeMake(9999, 21)].width;
}


- (void)setText:(NSString *)strText
{
    if(lblUser.text.length == 0)
        lblUser.frame = CGRectMake(0, 0, 0, lblUser.bounds.size.height);
        
    lblText.frame = CGRectMake(lblUser.frame.origin.x+(lblUser.text.length==0? 0:5)+lblUser.bounds.size.width, lblUser.frame.origin.y, self.bounds.size.width-(lblUser.frame.origin.x+5+lblUser.bounds.size.width), lblUser.bounds.size.height);
    lblText.text = strText;
}

- (NSString *)getText
{
    return lblUser.text;
}

- (void)setLabelBackground:(NSString *)type {
        UILabel * (^addLabel)(UIColor *, NSString *) = ^UILabel * (UIColor *bgColor, NSString *text) {
            [lblUser setBackgroundColor:bgColor];
            [lblUser setTextColor:[UIColor whiteColor]];
            [lblUser setText:text];
            return lblUser;
        };
    

        if([type isEqualToString:CPenjual]) {
            addLabel([UIColor colorWithRed:185/255.0f green:74/255.0f blue:72/255.0f alpha:1.0f],CPenjual);
        } else if([type isEqualToString:CPembeli]) {
            addLabel([UIColor colorWithRed:42/255.0f green:180/255.0f blue:194/255.0f alpha:1.0f], CPembeli);
        } else if([type isEqualToString:CAdministrator]) {
            addLabel([UIColor colorWithRed:248/255.0f green:148/255.0f blue:6/255.0f alpha:1.0f], CAdministrator);
        } else if([type isEqualToString:CPengguna]) {
            addLabel([UIColor colorWithRed:70/255.0f green:136/255.0f blue:71/255.0f alpha:1.0f], CPengguna);
        } else if([type isEqualToString:CBuyer]) {
            addLabel([UIColor colorWithRed:248/255.0f green:148/255.0f blue:6/255.0f alpha:1.0f], CBuyer);
        } else if([type isEqualToString:CSeller]) {
            addLabel([UIColor colorWithRed:70/255.0f green:136/255.0f blue:71/255.0f alpha:1.0f], CSeller);
        } else if([type isEqualToString:CSystemTracker]) {
            addLabel([UIColor colorWithRed:153/255.0f green:153/255.0f blue:153/255.0f alpha:1.0f], CSystemTracker);
        } else if([type isEqualToString:CTokopedia]) {
            addLabel([UIColor colorWithRed:153/255.0f green:153/255.0f blue:153/255.0f alpha:1.0f], CTokopedia);
        }
    
        lblUser.frame = CGRectMake(0, 0, (lblUser.text.length==0? 0 : [self calculateWidth:lblUser.text withFont:lblUser.font]+10), 21);
        lblText.frame = CGRectMake(lblUser.frame.origin.x+(lblUser.text.length==0? 0:5)+lblUser.bounds.size.width, lblUser.frame.origin.y, self.bounds.size.width-(lblUser.frame.origin.x+5+lblUser.bounds.size.width), lblUser.bounds.size.height);

}

- (void)setColor:(int)tagCase
{
    switch (tagCase) {
        case CTagPengguna:
        {
            lblUser.backgroundColor = [UIColor colorWithRed:70/255.0f green:136/255.0f blue:71/255.0f alpha:1.0f];
            lblUser.textColor = [UIColor whiteColor];
            lblUser.text = CPengguna;
        }
            break;
        case CTagPembeli:
        {
            lblUser.backgroundColor = [UIColor colorWithRed:42/255.0f green:180/255.0f blue:194/255.0f alpha:1.0f];
            lblUser.textColor = [UIColor whiteColor];
            lblUser.text = CPembeli;
        }
            break;
        case CTagPenjual:
        {
            lblUser.backgroundColor = [UIColor colorWithRed:185/255.0f green:74/255.0f blue:72/255.0f alpha:1.0f];
            lblUser.textColor = [UIColor whiteColor];
            lblUser.text = CPenjual;
        }
            break;
        case CTagAdministrator:
        {
            lblUser.backgroundColor = [UIColor colorWithRed:248/255.0f green:148/255.0f blue:6/255.0f alpha:1.0f];
            lblUser.textColor = [UIColor whiteColor];
            lblUser.text = CAdministrator;
        }
            break;
        case CTagSystemTracker:
        {
            lblUser.backgroundColor = [UIColor colorWithRed:153/255.0f green:153/255.0f blue:153/255.0f alpha:1.0f];
            lblUser.textColor = [UIColor whiteColor];
            lblUser.text = CSystemTracker;
        }
            break;
        case CTagBuyer:
        {
            lblUser.backgroundColor = [UIColor colorWithRed:248/255.0f green:148/255.0f blue:6/255.0f alpha:1.0f];
            lblUser.textColor = [UIColor whiteColor];
            lblUser.text = CBuyer;
        }
            break;
        case CTagSeller:
        {
            lblUser.backgroundColor = [UIColor colorWithRed:70/255.0f green:136/255.0f blue:71/255.0f alpha:1.0f];
            lblUser.textColor = [UIColor whiteColor];
            lblUser.text = CSeller;
        }
            break;
        case CTagTokopedia:
        {
            lblUser.backgroundColor = [UIColor colorWithRed:153/255.0f green:153/255.0f blue:153/255.0f alpha:1.0f];
            lblUser.textColor = [UIColor whiteColor];
            lblUser.text = CTokopedia;
        }
            break;
        default:
        {
            lblUser.text = @"";
        }
            break;
    }
    
    lblUser.frame = CGRectMake(0, 0, (lblUser.text.length==0? 0 : [self calculateWidth:lblUser.text withFont:lblUser.font]+10), 21);
    lblText.frame = CGRectMake(lblUser.frame.origin.x+(lblUser.text.length==0? 0:5)+lblUser.bounds.size.width, lblUser.frame.origin.y, self.bounds.size.width-(lblUser.frame.origin.x+5+lblUser.bounds.size.width), lblUser.bounds.size.height);
}

- (void)setText:(UIColor *)color withFont:(UIFont *)font
{
    if(color != nil)
        lblText.textColor = color;
    
    if(font != nil)
        lblText.font = font;
}

- (UILabel *)getLblText
{
    return lblText;
}
@end
