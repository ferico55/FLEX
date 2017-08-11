//
//  MHVerticalTabBarButton.m
//  MHVerticalTabBarController
//
//  Created by Marshall Huss on 1/3/13.
//  Copyright (c) 2013 mwhuss. All rights reserved.
//

#import "MHVerticalTabBarButton.h"
#import "UIColor+Theme.h"

@implementation MHVerticalTabBarButton

- (id)initWithTabBarItem:(UITabBarItem *)tabBarItem {
    if (tabBarItem.image) {
        self = [self initWithTitle:tabBarItem.title image:tabBarItem.image selectedImage:nil];
    }
    else {
        self = [self initWithTitle:tabBarItem.title image:tabBarItem.finishedUnselectedImage selectedImage:tabBarItem.finishedSelectedImage];
    }
    return self;
}

- (id)initWithTitle:(NSString *)title image:(UIImage *)image selectedImage:(UIImage *)selectedImage {
    self = [super init];
    if (self) {
        [self commonInit];
        [_titleLabel setCustomAttributedText:title];
        _imageView.image = image;
        _imageView.highlightedImage = selectedImage;
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit {
    _titleLabel = [[UILabel alloc] init];
    _titleLabel.backgroundColor = [UIColor clearColor];
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    _titleLabel.numberOfLines = 0;
    
    _imageView = [[UIImageView alloc] init];
    _imageView.contentMode = UIViewContentModeScaleAspectFit;
    
    _titleOffset = CGSizeZero;
    _imageOffset = CGSizeZero;
    
}

- (void)setSelected:(BOOL)selected {
    _imageView.highlighted = selected;
}

- (void)setLabelAttributes:(NSDictionary *)labelAttributes {
    _labelAttributes = labelAttributes;
    if (self.titleLabel.text) {
        self.titleLabel.attributedText = [[NSAttributedString alloc] initWithString:self.titleLabel.text attributes:_labelAttributes];
    }
}

- (void)setImageOffset:(CGSize)imageOffset {
    _imageOffset = imageOffset;
    [self setNeedsLayout];
}

- (void)setTitleOffset:(CGSize)titleOffset {
    _titleOffset = titleOffset;
    [self setNeedsLayout];
}

- (void)layoutSubviews {

    if (_isCategoryNavigation) {
        _imageView.contentMode = UIViewContentModeScaleAspectFit;

        
        _imageView.frame = CGRectMake(22, 10, 35, 35);
        
        CGRect titleLabelOffset = _imageView.frame;
        titleLabelOffset.size.width = self.bounds.size.width;
        titleLabelOffset.origin.x = 0;
        _titleLabel.frame = CGRectOffset(titleLabelOffset, 0, _imageView.frame.size.height);
        
        _titleLabel.font = [UIFont microTheme];
        _titleLabel.textColor = [UIColor tpPrimaryBlackText];
        _titleLabel.numberOfLines = 2;
        _titleLabel.adjustsFontSizeToFitWidth = YES;
        _titleLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
        
    } else{
        if ([_titleLabel.attributedText length] > 0) {
            if (CGSizeEqualToSize(_titleOffset, CGSizeZero)) {
                _titleLabel.frame = CGRectOffset(self.bounds, 0, 0);
            }
            else {
                _titleLabel.frame = CGRectOffset(self.bounds, self.titleOffset.width, self.titleOffset.height);
            }
            
            _imageView.frame = CGRectMake(5, self.bounds.size.height/2-5, 8, 8);
            
        }
        else {
            _imageView.frame = self.bounds;
        }

    }
    
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, self.frame.size.height, self.frame.size.width, 0.5)];
    lineView.backgroundColor = [UIColor colorWithRed:(188.0/255.0f) green:(187/255.0f) blue:(193.0/255.0f) alpha:0.5f];

    [self addSubview:lineView];
    
    [self addSubview:_imageView];
    [self addSubview:_titleLabel];
}


@end
