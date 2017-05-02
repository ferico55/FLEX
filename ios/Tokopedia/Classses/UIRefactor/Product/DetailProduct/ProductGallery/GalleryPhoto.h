//
//  GalleryPhoto.h
//  FGallery
//
//  Created by Grant Davis on 5/20/10.
//  Copyright 2011 Grant Davis Interactive, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>


@protocol GalleryPhotoDelegate;

@interface GalleryPhoto : NSObject {
	BOOL _useNetwork;
	BOOL _isThumbLoading;
	BOOL _hasThumbLoaded;
	
	BOOL _isFullsizeLoading;
	BOOL _hasFullsizeLoaded;
	
	NSMutableData *_thumbData;
	NSMutableData *_fullsizeData;
	
	NSURLConnection *_thumbConnection;
	NSURLConnection *_fullsizeConnection;
	
	NSString *_thumbUrl;
	NSString *_fullsizeUrl;
	
	UIImage *_thumbnail;
	UIImage *_fullsize;
	
	__unsafe_unretained NSObject <GalleryPhotoDelegate> *_delegate;
	NSUInteger tag;
}


- (id)initWithThumbnailUrl:(NSString*)thumb fullsizeUrl:(NSString*)fullsize delegate:(NSObject<GalleryPhotoDelegate> *)delegate;
- (id)initWithThumbnail:(UIImage *)thumb fullImage:(UIImage *)fullImage delegate:(NSObject<GalleryPhotoDelegate> *)delegate;

- (void)loadThumbnail;
- (void)loadFullsize;

- (void)unloadFullsize;
- (void)unloadThumbnail;

@property NSUInteger tag;

@property (readonly) BOOL isThumbLoading;
@property (readonly) BOOL hasThumbLoaded;

@property (readonly) BOOL hasFullsizeLoaded;

@property (nonatomic,readonly) UIImage *thumbnail;
@property (nonatomic,readonly) UIImage *fullsize;

@property (nonatomic,assign) NSObject<GalleryPhotoDelegate> *delegate;

@end


@protocol GalleryPhotoDelegate

@required
- (void)galleryPhoto:(GalleryPhoto *)photo didLoadThumbnail:(UIImage*)image;
- (void)galleryPhoto:(GalleryPhoto *)photo didLoadFullsize:(UIImage*)image;

@optional
- (void)galleryPhoto:(GalleryPhoto *)photo willLoadThumbnailFromUrl:(NSString*)url;
- (void)galleryPhoto:(GalleryPhoto *)photo willLoadFullsizeFromUrl:(NSString*)url;

- (void)galleryPhoto:(GalleryPhoto *)photo willLoadThumbnailFromPath:(NSString*)path;
- (void)galleryPhoto:(GalleryPhoto *)photo willLoadFullsizeFromPath:(NSString*)path;

@end
