//
//  FGalleryViewController.h
//  FGallery
//
//  Created by Grant Davis on 5/19/10.
//  Copyright 2011 Grant Davis Interactive, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "GalleryPhotoView.h"
#import "GalleryPhoto.h"
#import "TopAlignedLabel.h"


typedef enum
{
	FGalleryPhotoSizeThumbnail,
	FGalleryPhotoSizeFullsize
} GalleryPhotoSize;

@protocol GalleryViewControllerDelegate;

@interface GalleryViewController : UIViewController <UIScrollViewDelegate, GalleryPhotoDelegate> {
    TopAlignedLabel *lblTitle;
    UIButton *btnDownload, *btnCancel;
	BOOL _isScrolling;
	BOOL _isThumbViewShowing;
	
	NSInteger _currentIndex;
	
	UIView *_container; // used as view for the controller
	UIView *_innerContainer; // sized and placed to be fullscreen within the container
	UIScrollView *_thumbsView;
	UIScrollView *_scroller;
	
	NSMutableDictionary *_photoLoaders;
	NSMutableArray *_photoThumbnailViews;
	NSMutableArray *_photoViews;
	__unsafe_unretained NSObject <GalleryViewControllerDelegate> *_photoSource;
}

- (IBAction)actionDownload:(id)sender;
- (IBAction)actionCancel:(id)sender;
- (id)initWithPhotoSource:(NSObject<GalleryViewControllerDelegate>*)photoSrc withStartingIndex:(int)startIndex usingNetwork:(BOOL)usingNetwork;
- (id)initWithPhotoSource:(NSObject<GalleryViewControllerDelegate>*)photoSrc withStartingIndex:(int)startIndex;
- (void)gotoImageByIndex:(NSUInteger)index animated:(BOOL)animated;
- (void)removeImageAtIndex:(NSUInteger)index;
- (void)reloadGallery;
- (GalleryPhoto*)currentPhoto;

@property NSInteger currentIndex;
@property NSInteger startingIndex;
@property (nonatomic,readonly) UIView* thumbsView;
@property (nonatomic) BOOL useThumbnailView;
@property (nonatomic) BOOL beginsInThumbnailView;
@property (nonatomic) BOOL canDownload;

@end


@protocol GalleryViewControllerDelegate

@required
- (int)numberOfPhotosForPhotoGallery:(GalleryViewController *)gallery;

@optional
- (NSString*)photoGallery:(GalleryViewController *)gallery captionForPhotoAtIndex:(NSUInteger)index;
- (UIImage *)photoGallery:(NSUInteger)index;
- (NSString*)photoGallery:(GalleryViewController *)gallery urlForPhotoSize:(GalleryPhotoSize)size atIndex:(NSUInteger)index;

@end
