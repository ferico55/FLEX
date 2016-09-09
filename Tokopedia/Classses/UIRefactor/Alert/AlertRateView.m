//
//  AlertRateView.m
//  Tokopedia
//
//  Created by Tokopedia on 7/8/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "AlertRateView.h"
#define CStringSelectedEmoticon @"Rating harus dipilih"

@implementation AlertRateView
{
    UIImage *imageUnselected, *imageUnselectSad, *imageUnSelectSmile, *iconSad, *iconNetral, *iconGood;
    UIView *viewShadow;
    UIView *viewContentSmile;
    int defaultSelectedIndex;
    int selectedIndex;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
- (void)dealloc
{
}

- (void)initButtonContentPopUp:(NSString *)strTitle withImage:(UIImage *)image withFrame:(CGRect)rectFrame withTextColor:(UIColor *)textColor withButton:(UIButton *)tempBtn
{
    int spacing = 3;
    
    tempBtn.frame = rectFrame;
    [tempBtn setImage:image forState:UIControlStateNormal];
    [tempBtn setTitle:strTitle forState:UIControlStateNormal];
    [tempBtn setTitleColor:textColor forState:UIControlStateNormal];
    tempBtn.titleLabel.font = [UIFont title2Theme];
    
    CGSize imageSize = tempBtn.imageView.image.size;
    tempBtn.titleEdgeInsets = UIEdgeInsetsMake(0.0, -imageSize.width, -(imageSize.height+spacing), 0.0);
    CGSize titleSize = [tempBtn.titleLabel.text sizeWithAttributes:@{NSFontAttributeName:tempBtn.titleLabel.font}];
    tempBtn.imageEdgeInsets = UIEdgeInsetsMake(-(titleSize.height+spacing), 0.0, 0.0, -titleSize.width);
}

- (instancetype)initViewWithDelegate:(id<AlertRateDelegate>)delegate withDefaultScore:(NSString *)tag from:(NSString *)strFrom{
    self = [super initWithFrame:CGRectZero];
    
    if(self) {
        if([tag isEqualToString:CReviewScoreBad]) {
            defaultSelectedIndex = CTagMerah;
            selectedIndex = CTagMerah;
        }
        else if([tag isEqualToString:CReviewScoreNeutral]) {
            defaultSelectedIndex = CTagKuning;
            selectedIndex = CTagKuning;
        }
        else if([tag isEqualToString:CReviewScoreGood]) {
            defaultSelectedIndex = CTagHijau;
            selectedIndex = CTagHijau;
        }
        
        
        del = delegate;
        AppDelegate *myDelegate = (AppDelegate *) [UIApplication sharedApplication].delegate;
        
        //Add shadow
        viewShadow = [[UIView alloc] initWithFrame:myDelegate.window.frame];
        viewShadow.backgroundColor = [UIColor blackColor];
        viewShadow.alpha = 0.3f;
        [myDelegate.window addSubview:viewShadow];
        
        //Add view smile
        int padding = 20;
        int heightContent = 190;
        viewContentSmile = [[UIView alloc] initWithFrame:CGRectMake(padding, (myDelegate.window.bounds.size.height-heightContent)/2.0f, myDelegate.window.bounds.size.width-(padding*2), heightContent)];
        viewContentSmile.layer.cornerRadius = 8.0f;
        viewContentSmile.layer.masksToBounds = YES;
        viewContentSmile.backgroundColor = [UIColor whiteColor];
        
        
        imageUnselected = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"icon_neutral50" ofType:@"png"]];
        imageUnselectSad = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"icon_neutral_sad50" ofType:@"png"]];
        imageUnSelectSmile = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"icon_neutral_smile50" ofType:@"png"]];
        
        
        iconSad = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"icon_sad50" ofType:@"png"]];
        iconNetral = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"icon_netral50" ofType:@"png"]];
        iconGood = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"icon_smile50" ofType:@"png"]];
        
        //Set Title
        UILabel *lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, viewContentSmile.bounds.size.width, 45)];
        lblTitle.backgroundColor = [UIColor clearColor];
        lblTitle.text = [NSString stringWithFormat:@"Nilai %@", strFrom];
        lblTitle.textColor = [UIColor blackColor];
        lblTitle.textAlignment = NSTextAlignmentCenter;
        lblTitle.font = [UIFont title1Theme];
        [viewContentSmile addSubview:lblTitle];
        
        
        int diameterImage = 90;
        UIButton *btnTidakPuas = [UIButton buttonWithType:UIButtonTypeCustom];
        [self initButtonContentPopUp:@"Tidak Puas" withImage:defaultSelectedIndex==CTagMerah? iconSad:imageUnselectSad withFrame:CGRectMake(10, lblTitle.bounds.size.height, (viewContentSmile.bounds.size.width-40)/3.0f, diameterImage) withTextColor:[UIColor lightGrayColor] withButton:btnTidakPuas];
        
        UIButton *btnNetral = [UIButton buttonWithType:UIButtonTypeCustom];
        [self initButtonContentPopUp:@"Netral" withImage:defaultSelectedIndex==CTagKuning? iconNetral:imageUnselected withFrame:CGRectMake(btnTidakPuas.frame.origin.x+btnTidakPuas.bounds.size.width+10, btnTidakPuas.frame.origin.y, btnTidakPuas.bounds.size.width, btnTidakPuas.bounds.size.height) withTextColor:[UIColor lightGrayColor] withButton:btnNetral];
        
        UIButton *btnPuas = [UIButton buttonWithType:UIButtonTypeCustom];
        [self initButtonContentPopUp:@"Puas" withImage:defaultSelectedIndex==CTagHijau? iconGood:imageUnSelectSmile withFrame:CGRectMake(btnNetral.frame.origin.x+btnNetral.bounds.size.width+10, btnTidakPuas.frame.origin.y, btnTidakPuas.bounds.size.width, btnTidakPuas.bounds.size.height) withTextColor:[UIColor lightGrayColor] withButton:btnPuas];
        
        btnPuas.tag = CTagHijau;
        btnNetral.tag = CTagKuning;
        btnTidakPuas.tag = CTagMerah;
        [btnPuas addTarget:self action:@selector(actionAlertVote:) forControlEvents:UIControlEventTouchUpInside];
        [btnNetral addTarget:self action:@selector(actionAlertVote:) forControlEvents:UIControlEventTouchUpInside];
        [btnTidakPuas addTarget:self action:@selector(actionAlertVote:) forControlEvents:UIControlEventTouchUpInside];
        
        //Disable lower rate
        if(defaultSelectedIndex == CTagKuning) {
            btnTidakPuas.enabled = NO;
        }
        
        //Add Separator
        UIView *viewSeparator = [[UIView alloc] initWithFrame:CGRectMake(0, btnPuas.frame.origin.y+btnPuas.bounds.size.height, viewContentSmile.bounds.size.width, 0.5)];
        [viewSeparator setBackgroundColor:[UIColor lightGrayColor]];
        viewSeparator.alpha = 0.5f;
        
        //Set Action Btn
        UIButton *btnBatal = [UIButton buttonWithType:UIButtonTypeCustom];
        [btnBatal addTarget:self action:@selector(actionBatal:) forControlEvents:UIControlEventTouchUpInside];
        [btnBatal setTitle:@"Batal" forState:UIControlStateNormal];
        btnBatal.titleLabel.font = [UIFont title2Theme];
        [btnBatal setTitleColor:[UIColor colorWithRed:0 green:122/255.0f blue:255/255.0f alpha:1.0f] forState:UIControlStateNormal];
        btnBatal.frame = CGRectMake(0, viewSeparator.frame.origin.y+viewSeparator.bounds.size.height, viewContentSmile.bounds.size.width/2.0f, viewContentSmile.bounds.size.height-(viewSeparator.frame.origin.y+viewSeparator.bounds.size.height));
        
        UIView *viewVerticalSeparator = [[UIView alloc] initWithFrame:CGRectMake(btnBatal.bounds.size.width, btnBatal.frame.origin.y, 1.5, btnBatal.bounds.size.height)];
        viewVerticalSeparator.backgroundColor = viewSeparator.backgroundColor;
        viewVerticalSeparator.alpha = 0.5f;
        
        UIButton *btnSubmit = [UIButton buttonWithType:UIButtonTypeCustom];
        [btnSubmit addTarget:self action:@selector(actionSubmit:) forControlEvents:UIControlEventTouchUpInside];
        [btnSubmit setTitle:@"Kirim" forState:UIControlStateNormal];
        btnSubmit.titleLabel.font = [UIFont title2Theme];
        [btnSubmit setTitleColor:[UIColor colorWithRed:0 green:122/255.0f blue:255/255.0f alpha:1.0f] forState:UIControlStateNormal];
        btnSubmit.frame = CGRectMake(btnBatal.bounds.size.width+viewVerticalSeparator.bounds.size.width, btnBatal.frame.origin.y, btnBatal.bounds.size.width-viewVerticalSeparator.bounds.size.width, btnBatal.bounds.size.height);
        
        [viewContentSmile addSubview:viewSeparator];
        [viewContentSmile addSubview:btnBatal];
        [viewContentSmile addSubview:viewVerticalSeparator];
        [viewContentSmile addSubview:btnSubmit];
        [viewContentSmile addSubview:btnPuas];
        [viewContentSmile addSubview:btnNetral];
        [viewContentSmile addSubview:btnTidakPuas];
    }
    
    return self;
}


- (void)show {
    AppDelegate *myDelegate = (AppDelegate *) [UIApplication sharedApplication].delegate;
    [myDelegate.window addSubview:viewShadow];
    [myDelegate.window addSubview:viewContentSmile];
}


#pragma mark - Action
- (void)closeWindow {
    [viewShadow removeFromSuperview];
    [viewContentSmile removeFromSuperview];
    viewShadow = viewContentSmile = nil;
}

- (void)actionBatal:(id)sender {
    [self closeWindow];
    [del closeWindow];
}

- (void)actionSubmit:(id)sender {
    [self closeWindow];
    if(selectedIndex > 0)
        [del submitWithSelected:selectedIndex];
    else {
        StickyAlertView *stickyAlertView = [[StickyAlertView alloc] initWithErrorMessages:@[CStringSelectedEmoticon] delegate:del];
        [stickyAlertView show];
    }
}

- (void)actionAlertVote:(UIButton *)btn
{
    if(selectedIndex > 0) {//0 is not selected
        UIButton *tempBtn = (UIButton *)[btn.superview viewWithTag:selectedIndex];
        [tempBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        
        if(tempBtn.tag == CTagHijau)
            [tempBtn setImage:imageUnSelectSmile forState:UIControlStateNormal];
        else if(tempBtn.tag == CTagMerah)
            [tempBtn setImage:imageUnselectSad forState:UIControlStateNormal];
        else
            [tempBtn setImage:imageUnselected forState:UIControlStateNormal];
    }
    
    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    switch (btn.tag) {
        case CTagMerah:
        {
            selectedIndex = CTagMerah;
            [btn setImage:iconSad forState:UIControlStateNormal];
        }
            break;
        case CTagKuning:
        {
            selectedIndex = CTagKuning;
            [btn setImage:iconNetral forState:UIControlStateNormal];
        }
            break;
        case CTagHijau:
        {
            selectedIndex = CTagHijau;
            [btn setImage:iconGood forState:UIControlStateNormal];
        }
    }
}

@end
