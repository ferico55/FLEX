//
//  NoResultViewController.m
//  Tokopedia
//
//  Created by Johanes Effendi on 11/9/15.
//  Copyright © 2015 TOKOPEDIA. All rights reserved.
//

#import "NoResultReusableView.h"

@interface NoResultReusableView ()
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *descLabel;
@property (weak, nonatomic) IBOutlet UIButton *button;

@end

@implementation NoResultReusableView

-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [[NSBundle mainBundle] loadNibNamed:@"NoResultReusableView"
                                      owner:self
                                    options:nil];
        [self.view setFrame:CGRectMake(0, 0, frame.size.width?:[[UIScreen mainScreen]bounds].size.width, frame.size.height?:[[UIScreen mainScreen]bounds].size.height)];
        [self addSubview:self.view];
    }
    return self;
}

-(void)generateAllElements:(NSString *)fileName title:(NSString *)title desc:(NSString *)desc btnTitle:(NSString *)btnTitle{
    [self setNoResultImage:fileName];
    [self setNoResultTitle:title];
    [self setNoResultDesc:desc];
    if(btnTitle != nil){
        [self hideButton:NO];
        [self setNoResultButtonTitle:btnTitle];
    }else{
        [self hideButton:YES];
    }
}

#pragma mark - Setter
-(void)setNoResultImage:(NSString *)fileName{
    [_imageView setImage:[UIImage imageNamed:fileName]];
}

-(void)setNoResultTitle:(NSString *)title{
    [_titleLabel setText:title];
}

-(void)setNoResultDesc:(NSString *)desc{
    [_descLabel setText:desc];
}

-(void)setNoResultButtonTitle:(NSString *)btnTitle{
    [_button setTitle:btnTitle forState:UIControlStateNormal];
}

-(void)hideButton:(bool)hide{
    [_button setHidden:hide];
}
-(void)buttonDidTapped:(id)sender{
    [self.delegate buttonDidTapped:sender];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
