//
//  MHVerticalTabBar.m
//  MHVerticalTabBarController
//
//  Created by Marshall Huss on 1/3/13.
//  Copyright (c) 2013 mwhuss. All rights reserved.
//

#import "MHVerticalTabBar.h"
#import "MHVerticalTabBarButton.h"


@implementation MHVerticalTabBar

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self commonInit];
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
    _animationDuration = 0.2;

    self.backgroundColor = [UIColor colorWithRed:243/255.0 green:243/255.0 blue:243/255.0 alpha:1.0];
    
    CGRect rect =
    CGRectMake(0,
               0,
               110.0,
               110.0);
    _selectedBackgroundView = [[UIView alloc] initWithFrame:rect];
    _selectedBackgroundView.backgroundColor = [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1.0];
    [self addSubview:_selectedBackgroundView];
    
    _labelAttributes = @{
        NSForegroundColorAttributeName : [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:1.0],
        NSFontAttributeName : FONT_GOTHAM_BOOK_13
    };
    
    _tabBarItemHeight = 44;
    _showResetButton = false;
}

-(void)setShowResetButton:(BOOL)showResetButton{
    if (showResetButton) {
        UIButton *resetButton = [[UIButton alloc] initWithFrame:CGRectMake(5, self.frame.size.height - 45 - 60, self.frame.size.width - 10, 30)];
        [resetButton setTitle:@"Reset" forState:UIControlStateNormal];
        [resetButton setBackgroundColor:[UIColor whiteColor]];
        [resetButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        resetButton.titleLabel.font = FONT_GOTHAM_BOOK_12;
        UIColor *color = [UIColor colorWithRed:(188.0/255.0f) green:(187/255.0f) blue:(193.0/255.0f) alpha:1.0f];
        resetButton.layer.borderColor = color.CGColor;
        resetButton.layer.borderWidth = 1;
        resetButton.layer.cornerRadius = 5;
        [resetButton addTarget:self action:@selector(tapResetButton:) forControlEvents:UIControlEventTouchUpInside];
        
        [self addSubview:resetButton];
        [self bringSubviewToFront:resetButton];
    }
}

-(void)tapResetButton:(UIButton*)button{
    if ([_tabBarDelegate respondsToSelector:@selector(didTapResetButton:)]) {
        [_tabBarDelegate didTapResetButton:button];
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];

    CGFloat width = CGRectGetWidth(self.bounds);

    _selectedBackgroundView.frame =
    CGRectMake(0,
               _tabBarItemHeight * self.selectedIndex,
               width,
               _tabBarItemHeight);
    
    [self.tabBarButtons enumerateObjectsUsingBlock:^(MHVerticalTabBarButton *button, NSUInteger idx, BOOL *stop) {
        button.frame = CGRectMake(0, _tabBarItemHeight * idx, width, _tabBarItemHeight);

    }];
}

- (void)setLabelAttributes:(NSDictionary *)labelAttributes {
    _labelAttributes = labelAttributes;
    [_tabBarButtons enumerateObjectsUsingBlock:^(MHVerticalTabBarButton *button, NSUInteger idx, BOOL *stop) {
        button.labelAttributes = _labelAttributes;
    }];
}

-(void)setTabBarItemHeight:(CGFloat)tabBarItemHeight {
    _tabBarItemHeight = tabBarItemHeight;
    self.contentSize = CGSizeMake(0, _tabBarItemHeight * [_items count]);
}

- (void)setItems:(NSArray *)items {
    _items = items;
    
    CGFloat width = CGRectGetWidth(self.bounds);
    
    [self.tabBarButtons makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    self.contentSize = CGSizeMake(0, _tabBarItemHeight * [items count]);
    
    NSMutableArray *buttons = [NSMutableArray arrayWithCapacity:[items count]];
    [items enumerateObjectsUsingBlock:^(UITabBarItem *tabBarItem, NSUInteger idx, BOOL *stop) {
        
        MHVerticalTabBarButton *button = [[MHVerticalTabBarButton alloc] initWithTabBarItem:tabBarItem];
        
        [button addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
        button.labelAttributes = self.labelAttributes;
        
        [self addSubview:button];
        [buttons addObject:button];
    }];
    
    self.tabBarButtons = buttons;
    [self setNeedsLayout];
}

- (void)setSelectedIndex:(NSUInteger)selectedIndex {
    [self setSelectedIndex:selectedIndex animated:NO];
}

- (void)setSelectedIndex:(NSUInteger)selectedIndex animated:(BOOL)animated {
    if (selectedIndex > [self.tabBarButtons count] || [self.tabBarButtons count] == 0) return;
    
    _selectedIndex = selectedIndex;
    
    NSTimeInterval duration = animated ? _animationDuration : 0.0;
    
    [UIView animateWithDuration:duration animations:^{
        [self.tabBarButtons enumerateObjectsUsingBlock:^(MHVerticalTabBarButton *button, NSUInteger idx, BOOL *stop) {
            button.selected = NO;
        }];
        
        MHVerticalTabBarButton *button = self.tabBarButtons[_selectedIndex];
        button.selected = YES;
        
        _selectedBackgroundView.center = button.center;
    }];
}

- (void)setSelectedBackgroundImage:(UIImage *)selectedBackgroundImage {
    [self.selectedBackgroundView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    self.selectedBackgroundView.backgroundColor = [UIColor clearColor];
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:selectedBackgroundImage];
    imageView.frame = CGRectMake(0, 0, selectedBackgroundImage.size.width, selectedBackgroundImage.size.height);
    [self.selectedBackgroundView addSubview:imageView];
}

- (void)buttonPressed:(MHVerticalTabBarButton *)button {
    NSUInteger index = [self.tabBarButtons indexOfObject:button];
    [self setSelectedIndex:index animated:YES];
    
    if ([self.tabBarDelegate respondsToSelector:@selector(tabBar:didSelectItem:)]) {
        [self.tabBarDelegate tabBar:self didSelectItem:self.items[_selectedIndex]];
    }
}

@end
