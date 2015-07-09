//
//  AlertRateView.m
//  Tokopedia
//
//  Created by Tokopedia on 7/8/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "AlertRateView.h"

@implementation AlertRateView
{
    UIImage *imageUnselected;
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
    
    CGSize imageSize = tempBtn.imageView.bounds.size;
    CGSize titleSize = tempBtn.titleLabel.bounds.size;
    CGFloat totalHeight = (imageSize.height + titleSize.height + spacing);
    
    tempBtn.imageEdgeInsets = UIEdgeInsetsMake(- (totalHeight - imageSize.height), 0.0, 0.0, - titleSize.width);
    tempBtn.titleEdgeInsets = UIEdgeInsetsMake(0.0, - imageSize.width, - (totalHeight - titleSize.height),0.0);
}

- (instancetype)initViewWithDelegate:(id<AlertRateDelegate>)delegate withDefaultScore:(NSString *)tag {
    self = [super initWithFrame:CGRectZero];
    
    if(self) {
        if([tag isEqualToString:CRevieweeScroreBad]) {
            defaultSelectedIndex = CTagMerah;
            selectedIndex = CTagMerah;
        }
        else if([tag isEqualToString:CRevieweeScroreNetral]) {
            defaultSelectedIndex = CTagKuning;
            selectedIndex = CTagKuning;
        }
        else if([tag isEqualToString:CRevieweeScroreGood]) {
            defaultSelectedIndex = CTagHijau;
            selectedIndex = CTagHijau;
        }
        
        
        del = delegate;
        AppDelegate *myDelegate = (AppDelegate *) [UIApplication sharedApplication].delegate;
        
        //Add shadow
        viewShadow = [[UIView alloc] initWithFrame:myDelegate.window.frame];
        viewShadow.backgroundColor = [UIColor blackColor];
        viewShadow.alpha = 0.5f;
        [myDelegate.window addSubview:viewShadow];
        
        //Add view smile
        int padding = 20;
        int heightContent = 190;
        viewContentSmile = [[UIView alloc] initWithFrame:CGRectMake(padding, (myDelegate.window.bounds.size.height-heightContent)/2.0f, myDelegate.window.bounds.size.width-(padding*2), heightContent)];
        viewContentSmile.layer.cornerRadius = 20.0f;
        viewContentSmile.layer.masksToBounds = YES;
        viewContentSmile.backgroundColor = [UIColor whiteColor];
        
        imageUnselected = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"icon_neutral" ofType:@"png"]];
        
        //Set Title
        UILabel *lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, viewContentSmile.bounds.size.width, 45)];
        lblTitle.backgroundColor = [UIColor clearColor];
        lblTitle.text = @"FeedBack Toko";
        lblTitle.textColor = [UIColor blackColor];
        lblTitle.textAlignment = NSTextAlignmentCenter;
        lblTitle.font = [UIFont fontWithName:@"GothamBook" size:18.0f];
        [viewContentSmile addSubview:lblTitle];
        
        
        int diameterImage = 100;
        UIButton *btnTidakPuas = [UIButton buttonWithType:UIButtonTypeCustom];
        [self initButtonContentPopUp:@"Tidak Puas" withImage:defaultSelectedIndex==CTagMerah? [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"icon_sad" ofType:@"png"]]:imageUnselected withFrame:CGRectMake(0, lblTitle.bounds.size.height, viewContentSmile.bounds.size.width/3.0f, diameterImage) withTextColor:[UIColor lightGrayColor] withButton:btnTidakPuas];
        
        UIButton *btnNetral = [UIButton buttonWithType:UIButtonTypeCustom];
        [self initButtonContentPopUp:@"Netral" withImage:defaultSelectedIndex==CTagKuning? [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"icon_netral" ofType:@"png"]]:imageUnselected withFrame:CGRectMake(btnTidakPuas.frame.origin.x+btnTidakPuas.bounds.size.width, btnTidakPuas.frame.origin.y, btnTidakPuas.bounds.size.width, btnTidakPuas.bounds.size.height) withTextColor:[UIColor lightGrayColor] withButton:btnNetral];
        
        UIButton *btnPuas = [UIButton buttonWithType:UIButtonTypeCustom];
        [self initButtonContentPopUp:@"Puas" withImage:defaultSelectedIndex==CTagHijau? [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"icon_smile" ofType:@"png"]]:imageUnselected withFrame:CGRectMake(btnNetral.frame.origin.x+btnNetral.bounds.size.width, btnTidakPuas.frame.origin.y, btnTidakPuas.bounds.size.width, btnTidakPuas.bounds.size.height) withTextColor:[UIColor lightGrayColor] withButton:btnPuas];
        
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
        UIView *viewSeparator = [[UIView alloc] initWithFrame:CGRectMake(0, btnPuas.frame.origin.y+btnPuas.bounds.size.height, viewContentSmile.bounds.size.width, 1)];
        [viewSeparator setBackgroundColor:[UIColor lightGrayColor]];
        
        
        //Set Action Btn
        UIButton *btnBatal = [UIButton buttonWithType:UIButtonTypeCustom];
        [btnBatal addTarget:self action:@selector(actionBatal:) forControlEvents:UIControlEventTouchUpInside];
        [btnBatal setTitle:@"Batal" forState:UIControlStateNormal];
        btnBatal.titleLabel.font = [UIFont fontWithName:@"GothamBook" size:16.0f];
        [btnBatal setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        btnBatal.frame = CGRectMake(0, viewSeparator.frame.origin.y+viewSeparator.bounds.size.height, viewContentSmile.bounds.size.width/2.0f, viewContentSmile.bounds.size.height-(viewSeparator.frame.origin.y+viewSeparator.bounds.size.height));
        
        UIView *viewVerticalSeparator = [[UIView alloc] initWithFrame:CGRectMake(btnBatal.bounds.size.width, btnBatal.frame.origin.y, 1, btnBatal.bounds.size.height)];
        viewVerticalSeparator.backgroundColor = viewSeparator.backgroundColor;
        
        UIButton *btnSubmit = [UIButton buttonWithType:UIButtonTypeCustom];
        [btnSubmit addTarget:self action:@selector(actionSubmit:) forControlEvents:UIControlEventTouchUpInside];
        [btnSubmit setTitle:@"Submit" forState:UIControlStateNormal];
        [btnSubmit setTitleColor:btnBatal.titleLabel.textColor forState:UIControlStateNormal];
        btnSubmit.titleLabel.font = btnBatal.titleLabel.font;
        btnSubmit.frame = CGRectMake(btnBatal.bounds.size.width, btnBatal.frame.origin.y, btnBatal.bounds.size.width, btnBatal.bounds.size.height);
        
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
    [del submitWithSelected:selectedIndex];
}

- (void)actionAlertVote:(UIButton *)btn
{
    if(selectedIndex > 0) {//0 is not selected
        UIButton *tempBtn = (UIButton *)[btn.superview viewWithTag:selectedIndex];
        [tempBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        [tempBtn setImage:imageUnselected forState:UIControlStateNormal];
    }
    
    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    switch (btn.tag) {
        case CTagMerah:
        {
            selectedIndex = CTagMerah;
            [btn setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"icon_sad" ofType:@"png"]] forState:UIControlStateNormal];
        }
            break;
        case CTagKuning:
        {
            selectedIndex = CTagKuning;
            [btn setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"icon_netral" ofType:@"png"]] forState:UIControlStateNormal];
        }
            break;
        case CTagHijau:
        {
            selectedIndex = CTagHijau;
            [btn setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"icon_smile" ofType:@"png"]] forState:UIControlStateNormal];
        }
    }
}

@end
