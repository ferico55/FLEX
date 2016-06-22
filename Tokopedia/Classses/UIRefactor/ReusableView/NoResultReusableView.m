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
        
//        UIDevice *device = [UIDevice currentDevice];					//Get the device object
//        [device beginGeneratingDeviceOrientationNotifications];			//Tell it to start monitoring the accelerometer for orientation
//        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];	//Get the notification centre for the app
//        [nc addObserver:self											//Add yourself as an observer
//               selector:@selector(orientationChanged:)
//                   name:UIDeviceOrientationDidChangeNotification
//                 object:device];
    }
    return self;
}

- (void)orientationChanged:(NSNotification *)note
{
    [self.view setFrame:CGRectMake(0, 0, [[UIScreen mainScreen]bounds].size.width, [[UIScreen mainScreen]bounds].size.height)];
}

-(void)generateAllElements:(NSString *)fileName title:(NSString *)title desc:(NSString *)desc btnTitle:(NSString *)btnTitle{
    if(fileName != nil){
    [self setNoResultImage:fileName];
    }else{
        [self setNoResultImage:NO_RESULT_ICON];
    }
    [self setNoResultTitle:title];
    [self setNoResultDesc:desc];
    if(btnTitle != nil){
        _button.layer.cornerRadius = 3;
        [self hideButton:NO];
        [self setNoResultButtonTitle:btnTitle];
    }else{
        
        [self hideButton:YES];
    }
}

- (void)generateRequestErrorViewWithError:(NSError *)error {
    if (error.code == -1011) {
        [self setNoResultTitle:@"Whoops!\nTerjadi kendala pada server"];
        [self setNoResultDesc:@"Harap coba lagi"];
    } else if (error.code == -1009) {
        [self setNoResultTitle:@"Whoops!\nTidak ada koneksi Internet"];
        [self setNoResultDesc:@"Cek koneksi Internet Anda"];
    } else if (error.code == -999) {
        [self setNoResultTitle:@"Whoops!\nTerjadi kendala pada koneksi Internet"];
        [self setNoResultDesc:@"Harap coba lagi"];
    } else {
        [self setNoResultTitle:@"Whoops!\nTerjadi kendala pada server"];
        [self setNoResultDesc:@"Harap coba lagi"];
    }
    
    [self setNoResultImage:NO_RESULT_ICON];
    [_button.layer setCornerRadius:3.0];
    [self hideButton:NO];
    [self setNoResultButtonTitle:@"Coba Lagi"];
}

#pragma mark - Setter
-(void)setNoResultImage:(NSString *)fileName{
    [_imageView setImage:[UIImage imageNamed:fileName]];
}

-(void)setNoResultTitle:(NSString *)title{
    CGFloat titleSize = NO_RESULT_TITLE_SIZE;
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.lineSpacing = 7.0;
    style.alignment = NSTextAlignmentCenter;
    
    NSDictionary *attributes = @{
                                 NSFontAttributeName            : [UIFont fontWithName:@"GothamMedium" size:titleSize],
                                 NSParagraphStyleAttributeName  : style,
                                 };
    
    _titleLabel.attributedText = [[NSAttributedString alloc] initWithString:title attributes:attributes];
    
}

-(void)setNoResultDesc:(NSString *)desc{
    CGFloat descSize = NO_RESULT_DESC_SIZE;
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.lineSpacing = 4.0;
    style.alignment = NSTextAlignmentCenter;
    
    NSDictionary *attributes = @{
                                 NSFontAttributeName            : [UIFont fontWithName:@"GothamBook" size:descSize],
                                 NSParagraphStyleAttributeName  : style,
                                 };
    
    _descLabel.attributedText = [[NSAttributedString alloc] initWithString:desc attributes:attributes];
    
}

-(void)setNoResultButtonTitle:(NSString *)btnTitle{
    CGFloat btnSize = NO_RESULT_BUTTON_TITLE_SIZE;
    _button.titleLabel.font = [UIFont fontWithName:@"GothamMedium" size:btnSize];
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
