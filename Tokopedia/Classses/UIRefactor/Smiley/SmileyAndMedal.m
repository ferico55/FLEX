//
//  SmileyAndMedal.m
//  Tokopedia
//
//  Created by Tokopedia on 8/7/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "SmileyAndMedal.h"

#define CBadgeSpeedGood @"badge-speed-good"
#define CBadgeSpeedBad @"badge-speed-bad"
#define CBadgeSpeedNeutral @"badge-speed-neutral"

enum emoticonTag {
    CTagMerah = 1,
    CTagKuning = 2,
    CTagHijau = 3
};




@implementation SmileyAndMedal
#pragma mark - Method
+ (void)setIconResponseSpeed:(NSString *)strResponse withImage:(id)imgSpeed largeImage:(BOOL)isLarge {
    UIImage *image = nil;
    if([strResponse isEqualToString:CBadgeSpeedGood]) {
        image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:isLarge? @"icon_speed_fast_large":@"icon_speed_fast" ofType:@"png"]];
    }
    else if([strResponse isEqualToString:CBadgeSpeedBad]) {
        image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:isLarge? @"icon_speed_bad_large":@"icon_speed_bad" ofType:@"png"]];
    }
    else if([strResponse isEqualToString:CBadgeSpeedNeutral]) {
        image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:isLarge? @"icon_speed_neutral_large":@"icon_speed_neutral" ofType:@"png"]];
    }
    else {
        image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:isLarge? @"icon_speed_grey_large":@"icon_speed_grey" ofType:@"png"]];
    }
    
    
    
    if([imgSpeed isMemberOfClass:[UIImageView class]]) {
        ((UIImageView *) imgSpeed).image = image;
    }
    else if([imgSpeed isMemberOfClass:[UIButton class]]){
        [((UIButton *) imgSpeed) setImage:image forState:UIControlStateNormal];
    }
}

+ (UIImage *)generateImage:(UIImage *)image withCount:(int)count {
    UIView *tempView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, image.size.width*count, image.size.height)];
    
    for(int i=0;i<count;i++) {
        [tempView addSubview:[[[UIImageView alloc] initWithFrame:CGRectMake(i*image.size.width, 0, image.size.width, image.size.height)] initWithImage:image]];
    }
    
    UIGraphicsBeginImageContextWithOptions(tempView.bounds.size, 0, 0.0);
    [tempView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage * img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return img;
}

+ (void)generateMedalWithLevel:(NSString *)level withSet:(NSString *)set withImage:(id)image isLarge:(BOOL)isLarge {
    int intLevel = level==nil || [level isEqualToString:@""]? 0:[level intValue];
    int intSet = set==nil || [set isEqualToString:@""]? 0:[set intValue];
    UIImage *tempImage = nil;
    BOOL isArrayObject = ([image isKindOfClass:[NSArray class]] || [image isKindOfClass:[NSMutableArray class]]);
    
    switch (intSet) {
        case 0:
        {
            tempImage = isArrayObject? [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:isLarge? @"icon_medal":@"icon_medal14" ofType:@"png"]] : [SmileyAndMedal generateImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:isLarge? @"icon_medal":@"icon_medal14" ofType:@"png"]] withCount:1];
        }
            break;
        case 1:
        {
            tempImage = isArrayObject? [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:isLarge? @"icon_medal_bronze":@"icon_medal_bronze14" ofType:@"png"]] : [SmileyAndMedal generateImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:isLarge? @"icon_medal_bronze":@"icon_medal_bronze14" ofType:@"png"]] withCount:intLevel];
        }
            break;
        case 2:
        {
            tempImage = isArrayObject? [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:isLarge? @"icon_medal_silver":@"icon_medal_silver14" ofType:@"png"]] : [SmileyAndMedal generateImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:isLarge? @"icon_medal_silver":@"icon_medal_silver14" ofType:@"png"]] withCount:intLevel];
        }
            break;
        case 3:
        {
            tempImage = isArrayObject? [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:isLarge? @"icon_medal_gold":@"icon_medal_gold14" ofType:@"png"]] : [SmileyAndMedal generateImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:isLarge? @"icon_medal_gold":@"icon_medal_gold14" ofType:@"png"]] withCount:intLevel];
        }
            break;
        default:
        {
            tempImage = isArrayObject? [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:isLarge? @"icon_medal_diamond_one":@"icon_medal_diamond_one14" ofType:@"png"]] : [SmileyAndMedal generateImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:isLarge? @"icon_medal_diamond_one":@"icon_medal_diamond_one14" ofType:@"png"]] withCount:intLevel];
        }
            break;
    }
    
    
    if([image isMemberOfClass:[UIButton class]]) {
        [((UIButton *) image) setImage:tempImage forState:UIControlStateNormal];
    }
    else if(isArrayObject) {
        if (intLevel == 0 && intSet == 0) {
            for (UIImageView *imageView in image) imageView.image = nil;
            UIImageView *imageView = [image objectAtIndex:0];
            imageView.image = tempImage;
        } else {
            for(int i=0;i<((NSArray *) image).count;i++) {
                UIImageView *temporaryImage = ((NSArray *) image)[i];
                if(i < intLevel) {
                    temporaryImage.image = tempImage;
                }
                else
                    temporaryImage.image = nil;
            }
        }
    }
    else if([image isMemberOfClass:[UIImageView class]]){
        ((UIImageView *) image).image = tempImage;
    }
    else if([image isKindOfClass:[UIButton class]]) {
        [((UIButton *) image) setImage:tempImage forState:UIControlStateNormal];
    }
}

- (id)initButtonContentPopUp:(NSString *)strTitle withImage:(UIImage *)image withFrame:(CGRect)rectFrame withTextColor:(UIColor *)textColor
{
    if ([strTitle isKindOfClass:[NSNumber class]]) {
        strTitle = [NSString stringWithFormat:@"%zd", [strTitle integerValue]];
    }
    UIButton *tempBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    tempBtn.frame = rectFrame;
    [tempBtn setImage:image forState:UIControlStateNormal];
    [tempBtn setTitle:strTitle forState:UIControlStateNormal];
    [tempBtn setTitleColor:textColor forState:UIControlStateNormal];
    tempBtn.titleLabel.font = [UIFont fontWithName:@"GothamBook" size:13.0f];
    
    //    CGSize imageSize = tempBtn.imageView.bounds.size;
    //    CGSize titleSize = tempBtn.titleLabel.bounds.size;
    //    CGFloat totalHeight = (imageSize.height + titleSize.height + spacing);
    
    //    tempBtn.imageEdgeInsets = UIEdgeInsetsMake(- (totalHeight - imageSize.height), 0.0, 0.0, - titleSize.width);
    tempBtn.titleEdgeInsets = UIEdgeInsetsMake(15.0, 0.0, 0.0, 0.0);
    
    return (id)tempBtn;
}

- (void)showPopUpSmiley:(UIView *)viewContentPopUp andPadding:(int)paddingRightLeftContent withReputationNetral:(NSString *)strNetral withRepSmile:(NSString *)strGood withRepSad:(NSString *)strSad withDelegate:(id<SmileyDelegate>)delegate{
    viewContentPopUp.backgroundColor = [UIColor clearColor];
    
    UIButton *btnMerah = (UIButton *)[self initButtonContentPopUp:strSad withImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"icon_sad" ofType:@"png"]] withFrame:CGRectMake(paddingRightLeftContent/2.0f, 0, CWidthItemPopUp, CHeightItemPopUp) withTextColor:[UIColor colorWithRed:244/255.0f green:67/255.0f blue:54/255.0f alpha:1.0f]];
    UIButton *btnKuning = (UIButton *)[self initButtonContentPopUp:strNetral withImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"icon_netral" ofType:@"png"]] withFrame:CGRectMake(btnMerah.frame.origin.x+btnMerah.bounds.size.width, 0, CWidthItemPopUp, CHeightItemPopUp) withTextColor:[UIColor colorWithRed:255/255.0f green:193/255.0f blue:7/255.0f alpha:1.0f]];
    UIButton *btnHijau = (UIButton *)[self initButtonContentPopUp:strGood withImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"icon_smile" ofType:@"png"]] withFrame:CGRectMake(btnKuning.frame.origin.x+btnKuning.bounds.size.width, 0, CWidthItemPopUp, CHeightItemPopUp) withTextColor:[UIColor colorWithRed:0 green:128/255.0f blue:0 alpha:1.0f]];
    
    btnMerah.tag = CTagMerah;
    btnKuning.tag = CTagKuning;
    btnHijau.tag = CTagHijau;
    
    [btnMerah addTarget:delegate action:@selector(actionVote:) forControlEvents:UIControlEventTouchUpInside];
    [btnKuning addTarget:delegate action:@selector(actionVote:) forControlEvents:UIControlEventTouchUpInside];
    [btnHijau addTarget:delegate action:@selector(actionVote:) forControlEvents:UIControlEventTouchUpInside];
    
    [viewContentPopUp addSubview:btnMerah];
    [viewContentPopUp addSubview:btnKuning];
    [viewContentPopUp addSubview:btnHijau];
}
@end
