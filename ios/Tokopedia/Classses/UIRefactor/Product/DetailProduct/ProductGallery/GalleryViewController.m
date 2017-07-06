    //
//  FGalleryViewController.m
//  FGallery
//
//  Created by Grant Davis on 5/19/10.
//  Copyright 2011 Grant Davis Interactive, LLC. All rights reserved.
//

#import "GalleryViewController.h"
#define kThumbnailSize 75
#define kThumbnailSpacing 4


@interface GalleryViewController (Private)

// general
- (void)buildViews;
- (void)destroyViews;
- (void)layoutViews;
- (void)moveScrollerToCurrentIndexWithAnimation:(BOOL)animation;
- (void)updateScrollSize;
- (void)resizeImageViewsWithRect:(CGRect)rect;
- (void)resetImageViewZoomLevels;


- (void)positionInnerContainer;
- (void)positionScroller;
- (void)positionToolbar;
- (void)resizeThumbView;

// thumbnails
- (void)toggleThumbnailViewWithAnimation:(BOOL)animation;
- (void)showThumbnailViewWithAnimation:(BOOL)animation;
- (void)hideThumbnailViewWithAnimation:(BOOL)animation;
- (void)buildThumbsViewPhotos;

- (void)arrangeThumbs;
- (void)loadAllThumbViewPhotos;

- (void)preloadThumbnailImages;
- (void)unloadFullsizeImageWithIndex:(NSUInteger)index;

- (void)scrollingHasEnded;

- (void)handleSeeAllTouch:(id)sender;
- (void)handleThumbClick:(id)sender;

- (GalleryPhoto*)createGalleryPhotoForIndex:(NSUInteger)index;

- (void)loadThumbnailImageWithIndex:(NSUInteger)index;
- (void)loadFullsizeImageWithIndex:(NSUInteger)index;

@end



@implementation GalleryViewController {
    BOOL useNetwork;
}
@synthesize currentIndex = _currentIndex;
@synthesize thumbsView = _thumbsView;
@synthesize useThumbnailView = _useThumbnailView;
@synthesize beginsInThumbnailView = _beginsInThumbnailView;

#pragma mark - Public Methods

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil withStartingIndex:(int)startIndex
{
	if((self = [super initWithNibName:nil bundle:nil])) {
        // set defaults
        _useThumbnailView                   = YES;
		
		// create storage objects
		_currentIndex						= 0;
        _startingIndex                      = startIndex;
		_photoLoaders						= [[NSMutableDictionary alloc] init];
		_photoViews							= [[NSMutableArray alloc] init];
		_photoThumbnailViews				= [[NSMutableArray alloc] init];
    }
    
	return self;
}

- (id)initWithPhotoSource:(NSObject<GalleryViewControllerDelegate>*)photoSrc withStartingIndex:(int)startIndex usingNetwork:(BOOL)usingNetwork canDownload:(BOOL)canDownload {
    self.canDownload = canDownload;
    return [self initWithPhotoSource:photoSrc withStartingIndex:startIndex usingNetwork:usingNetwork];
}

- (id)initWithPhotoSource:(NSObject<GalleryViewControllerDelegate>*)photoSrc withStartingIndex:(int)startIndex usingNetwork:(BOOL)usingNetwork {
    useNetwork = usingNetwork;
    return [self initWithPhotoSource:photoSrc withStartingIndex:startIndex];
}

- (id)initWithPhotoSource:(NSObject<GalleryViewControllerDelegate>*)photoSrc withStartingIndex:(int)startIndex
{
	if((self = [self initWithNibName:nil bundle:nil withStartingIndex:startIndex])) {
		_photoSource = photoSrc;
        btnCancel = [UIButton buttonWithType:UIButtonTypeCustom];
        [btnCancel addTarget:self action:@selector(actionCancel:) forControlEvents:UIControlEventTouchUpInside];
        btnCancel.backgroundColor = [UIColor clearColor];
        btnCancel.autoresizingMask = UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin;
        [btnCancel setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//        [btnCancel setTitle:@"X" forState:UIControlStateNormal];
        [btnCancel setImage:[UIImage imageNamed:@"icon_close_white.png"] forState:UIControlStateNormal];
        btnCancel.frame = CGRectMake([[UIScreen mainScreen] bounds].size.width-49, 0, 49, 49);
        
        lblTitle = [[TopAlignedLabel alloc] initWithFrame:CGRectMake(10, 10, btnCancel.frame.origin.x-10, 4*btnCancel.bounds.size.height)];
        lblTitle.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleTopMargin;
        lblTitle.font = [UIFont largeTheme];
        lblTitle.backgroundColor = [UIColor clearColor];
        lblTitle.textColor = [UIColor whiteColor];
        lblTitle.numberOfLines = 0;
        
        UIView *contentHeader = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, 70)];
        CAGradientLayer *gradient = [CAGradientLayer layer];
        gradient.frame = contentHeader.bounds;
        gradient.colors = [NSArray arrayWithObjects:(id)[[UIColor colorWithRed:0 green:0 blue:0 alpha:0.3f] CGColor], (id)[[UIColor clearColor] CGColor], nil];
        [contentHeader.layer insertSublayer:gradient atIndex:0];
        [contentHeader addSubview:lblTitle];
        [contentHeader addSubview:btnCancel];
        [self.view addSubview:contentHeader];
        
        
        UIView *contentDownload;
        if(self.canDownload) {
            btnDownload = [UIButton buttonWithType:UIButtonTypeCustom];
            btnDownload.titleLabel.font = [UIFont largeTheme];
            [btnDownload addTarget:self action:@selector(actionDownload:) forControlEvents:UIControlEventTouchUpInside];
            btnDownload.backgroundColor = [UIColor whiteColor];
            btnDownload.layer.cornerRadius = 5.0f;
            btnDownload.layer.shadowRadius = 3.0f;
            btnDownload.layer.shadowOpacity = 1.0f;
            btnDownload.layer.shadowColor = [UIColor blackColor].CGColor;
            btnDownload.layer.shadowOffset = CGSizeMake(0, 0);
            btnDownload.layer.masksToBounds = YES;
            btnDownload.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleWidth;
            [btnDownload setTitle:@"Download" forState:UIControlStateNormal];
            [btnDownload setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            
            
            contentDownload = [[UIView alloc] initWithFrame:CGRectMake(0, [[UIScreen mainScreen] bounds].size.height-70, [[UIScreen mainScreen] bounds].size.width, 70)];
            btnDownload.frame = CGRectMake((contentDownload.bounds.size.width-100)/2.0f, 30, 100, 30);

            CAGradientLayer *gradient = [CAGradientLayer layer];
            gradient.frame = contentDownload.bounds;
            gradient.colors = [NSArray arrayWithObjects:(id)[[UIColor clearColor] CGColor], (id)[[UIColor colorWithRed:0 green:0 blue:0 alpha:0.3f] CGColor], nil];
            [contentDownload.layer insertSublayer:gradient atIndex:0];
            [self.view addSubview:contentDownload];
            [contentDownload addSubview:btnDownload];
        }
        
        [self.view addSubview:contentDownload];
        
        
        
        
        UISwipeGestureRecognizer *swipeBottom = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(actionCancel:)];
        swipeBottom.direction = UISwipeGestureRecognizerDirectionDown | UISwipeGestureRecognizerDirectionUp;
        [self.view addGestureRecognizer:swipeBottom];
        [self.view setUserInteractionEnabled:YES];
	}
    
	return self;
}


- (void)loadView
{
    // create public objects first so they're available for custom configuration right away. positioning comes later.
    _container							= [[UIView alloc] initWithFrame:CGRectZero];
    _innerContainer						= [[UIView alloc] initWithFrame:CGRectZero];
    _scroller							= [[UIScrollView alloc] initWithFrame:CGRectZero];
    _thumbsView							= [[UIScrollView alloc] initWithFrame:CGRectZero];
    _container.backgroundColor			= [UIColor blackColor];
    
    // listen for container frame changes so we can properly update the layout during auto-rotation or going in and out of fullscreen
    [_container addObserver:self forKeyPath:@"frame" options:NSKeyValueObservingOptionNew context:nil];
    
    // setup scroller
    _scroller.delegate							= self;
    _scroller.pagingEnabled						= YES;
    _scroller.showsVerticalScrollIndicator		= NO;
    _scroller.showsHorizontalScrollIndicator	= NO;
    
    // make things flexible
    _container.autoresizesSubviews				= NO;
    _innerContainer.autoresizesSubviews			= NO;
    _scroller.autoresizesSubviews				= NO;
    _container.autoresizingMask					= UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    // setup thumbs view
    _thumbsView.backgroundColor					= [UIColor whiteColor];
    _thumbsView.hidden							= YES;
    _thumbsView.contentInset					= UIEdgeInsetsMake( kThumbnailSpacing, kThumbnailSpacing, kThumbnailSpacing, kThumbnailSpacing);
    
	// set view
	self.view                                   = _container;
	
	// add items to their containers
	[_container addSubview:_innerContainer];
	[_container addSubview:_thumbsView];
	[_innerContainer addSubview:_scroller];
    
    [self reloadGallery];
}


- (void)viewDidUnload {
    [self destroyViews];

    _container = nil;
    _innerContainer = nil;
    _scroller = nil;
    _thumbsView = nil;
    
    [super viewDidUnload];
}


- (void)destroyViews {
    // remove previous photo views
    for (UIView *view in _photoViews) {
        [view removeFromSuperview];
    }
    [_photoViews removeAllObjects];
    
    // remove previous thumbnails
    for (UIView *view in _photoThumbnailViews) {
        [view removeFromSuperview];
    }
    [_photoThumbnailViews removeAllObjects];
    
    // remove photo loaders
    NSArray *photoKeys = [_photoLoaders allKeys];
    for (int i=0; i<[photoKeys count]; i++) {
        GalleryPhoto *photoLoader = [_photoLoaders objectForKey:[photoKeys objectAtIndex:i]];
        photoLoader.delegate = nil;
        [photoLoader unloadFullsize];
        [photoLoader unloadThumbnail];
    }
    [_photoLoaders removeAllObjects];
}


- (void)reloadGallery
{
    _currentIndex = _startingIndex;
    _isThumbViewShowing = NO;
    
    // remove the old
    [self destroyViews];
    
    // build the new
    if ([_photoSource numberOfPhotosForPhotoGallery:self] > 0) {
        // create the image views for each photo
        [self buildViews];
        
        // create the thumbnail views
        [self buildThumbsViewPhotos];
        
        // start loading thumbs
        [self preloadThumbnailImages];
        
        // start on first image
        [self gotoImageByIndex:_currentIndex animated:NO];
        
        // layout
        [self layoutViews];
    }
}

- (GalleryPhoto *)currentPhoto
{
    return [_photoLoaders objectForKey:[NSString stringWithFormat:@"%i", (int)_currentIndex]];
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.useThumbnailView = _useThumbnailView;
	
    // toggle into the thumb view if we should start there
    if (_beginsInThumbnailView && _useThumbnailView) {
        [self showThumbnailViewWithAnimation:NO];
        [self loadAllThumbViewPhotos];
    }
    
	[self layoutViews];
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:NO];
	
	// init with next on first run.
    if( _currentIndex == -1 ) {}
	else [self gotoImageByIndex:_currentIndex animated:NO];
}


- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}


- (void)resizeImageViewsWithRect:(CGRect)rect
{
	// resize all the image views
	NSUInteger i, count = [_photoViews count];
	float dx = 0;
	for (i = 0; i < count; i++) {
		GalleryPhotoView * photoView = [_photoViews objectAtIndex:i];
		photoView.frame = CGRectMake(dx, 0, rect.size.width, rect.size.height );
		dx += rect.size.width;
	}
}


- (void)resetImageViewZoomLevels
{
	// resize all the image views
	NSUInteger i, count = [_photoViews count];
	for (i = 0; i < count; i++) {
		GalleryPhotoView * photoView = [_photoViews objectAtIndex:i];
		[photoView resetZoom];
	}
}


- (void)removeImageAtIndex:(NSUInteger)index
{
	// remove the image and thumbnail at the specified index.
	GalleryPhotoView *imgView = [_photoViews objectAtIndex:index];
 	GalleryPhotoView *thumbView = [_photoThumbnailViews objectAtIndex:index];
	GalleryPhoto *photo = [_photoLoaders objectForKey:[NSString stringWithFormat:@"%i", (int)index]];
	
	[photo unloadFullsize];
	[photo unloadThumbnail];
	
	[imgView removeFromSuperview];
	[thumbView removeFromSuperview];
	
	[_photoViews removeObjectAtIndex:index];
	[_photoThumbnailViews removeObjectAtIndex:index];
	[_photoLoaders removeObjectForKey:[NSString stringWithFormat:@"%i", (int)index]];
	
	[self layoutViews];
}


- (void)gotoImageByIndex:(NSUInteger)index animated:(BOOL)animated
{
	NSUInteger numPhotos = [_photoSource numberOfPhotosForPhotoGallery:self];
	
	// constrain index within our limits
    if( index >= numPhotos ) index = numPhotos - 1;
	
	
	if( numPhotos == 0 ) {
		
		// no photos!
		_currentIndex = -1;
	}
	else {
		
		// clear the fullsize image in the old photo
		[self unloadFullsizeImageWithIndex:_currentIndex];
		
		_currentIndex = index;
		[self moveScrollerToCurrentIndexWithAnimation:animated];
		
		if( !animated )	{
			[self preloadThumbnailImages];
			[self loadFullsizeImageWithIndex:index];
		}
	}
    
    [self updateTitle];
}


- (void)layoutViews
{
	[self positionInnerContainer];
	[self positionScroller];
	[self resizeThumbView];
	[self positionToolbar];
	[self updateScrollSize];
	[self resizeImageViewsWithRect:_scroller.frame];
	[self arrangeThumbs];
	[self moveScrollerToCurrentIndexWithAnimation:NO];
    [self updateTitle];
}

#pragma mark - Method
- (void)updateTitle
{
    if([_photoSource numberOfPhotosForPhotoGallery:self] > 0 )
    {
        if([_photoSource respondsToSelector:@selector(photoGallery:captionForPhotoAtIndex:)])
        {
            [lblTitle setCustomAttributedText:[_photoSource photoGallery:self captionForPhotoAtIndex:_currentIndex]];
//            lblTitle.text = @"Testong aj";
            if(lblTitle.text.length>0 && lblTitle.layer.shadowOpacity != 0.5) {
                lblTitle.layer.shadowColor = [UIColor blackColor].CGColor;
                lblTitle.layer.shadowOffset = CGSizeMake(0, 0);
                lblTitle.layer.shadowOpacity = 0.8;
                lblTitle.layer.shadowRadius = 3.0;
                lblTitle.layer.masksToBounds = NO;
            }
        }
    }
}

- (void)actionCancel:(id)sender
{
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:NO];
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

- (void)actionDownload:(id)sender
{
    // Save it to the camera roll / saved photo album
    UIImageWriteToSavedPhotosAlbum(((GalleryPhotoView *) [_photoViews objectAtIndex:_currentIndex]).imageView.image, nil, nil, nil);
    StickyAlertView *alert = [[StickyAlertView alloc] initWithSuccessMessages:@[@"Berhasil mengunduh gambar ini"] delegate:self];
    [alert show];
}

#pragma mark - Private Methods
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	if([keyPath isEqualToString:@"frame"]) 
	{
		[self layoutViews];
	}
}


- (void)positionInnerContainer
{
	CGRect screenFrame = [[UIScreen mainScreen] bounds];
	CGRect innerContainerRect;
	
	if( self.interfaceOrientation == UIInterfaceOrientationPortrait || self.interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown )
	{//portrait
		innerContainerRect = CGRectMake( 0, _container.frame.size.height - screenFrame.size.height, _container.frame.size.width, screenFrame.size.height );
	}
	else 
	{// landscape
		innerContainerRect = CGRectMake( 0, _container.frame.size.height - screenFrame.size.width, _container.frame.size.width, screenFrame.size.width );
	}
	
	_innerContainer.frame = innerContainerRect;
}


- (void)positionScroller
{
	CGRect screenFrame = [[UIScreen mainScreen] bounds];
	CGRect scrollerRect;
	
	if( self.interfaceOrientation == UIInterfaceOrientationPortrait || self.interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown )
	{//portrait
		scrollerRect = CGRectMake( 0, 0, screenFrame.size.width, screenFrame.size.height );
	}
	else
	{//landscape
		scrollerRect = CGRectMake( 0, 0, screenFrame.size.height, screenFrame.size.width );
	}
	
	_scroller.frame = scrollerRect;
}


- (void)positionToolbar
{
}


- (void)resizeThumbView
{
    int barHeight = 0;
    if (self.navigationController.navigationBar.barStyle == UIBarStyleBlackTranslucent) {
        barHeight = self.navigationController.navigationBar.frame.size.height;
    }
	_thumbsView.frame = CGRectMake( 0, barHeight, _container.frame.size.width, _container.frame.size.height-barHeight );
}



- (void)updateScrollSize
{
	float contentWidth = _scroller.frame.size.width * [_photoSource numberOfPhotosForPhotoGallery:self];
	[_scroller setContentSize:CGSizeMake(contentWidth, _scroller.frame.size.height)];
}


- (void)moveScrollerToCurrentIndexWithAnimation:(BOOL)animation
{
	int xp = _scroller.frame.size.width * _currentIndex;
	[_scroller scrollRectToVisible:CGRectMake(xp, 0, _scroller.frame.size.width, _scroller.frame.size.height) animated:animation];
	_isScrolling = animation;
}


// creates all the image views for this gallery
- (void)buildViews
{
	NSUInteger i, count = [_photoSource numberOfPhotosForPhotoGallery:self];
	for (i = 0; i < count; i++) {
		GalleryPhotoView *photoView = [[GalleryPhotoView alloc] initWithFrame:CGRectZero];
		photoView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		photoView.autoresizesSubviews = YES;
		[_scroller addSubview:photoView];
		[_photoViews addObject:photoView];
	}
}


- (void)buildThumbsViewPhotos
{
	NSUInteger i, count = [_photoSource numberOfPhotosForPhotoGallery:self];
	for (i = 0; i < count; i++) {
		
		GalleryPhotoView *thumbView = [[GalleryPhotoView alloc] initWithFrame:CGRectZero target:self action:@selector(handleThumbClick:)];
		[thumbView setContentMode:UIViewContentModeScaleAspectFill];
		[thumbView setClipsToBounds:YES];
		[thumbView setTag:i];
		[_thumbsView addSubview:thumbView];
		[_photoThumbnailViews addObject:thumbView];
	}
}



- (void)arrangeThumbs
{
	float dx = 0.0;
	float dy = 0.0;
	// loop through all thumbs to size and place them
	NSUInteger i, count = [_photoThumbnailViews count];
	for (i = 0; i < count; i++) {
		GalleryPhotoView *thumbView = [_photoThumbnailViews objectAtIndex:i];
		[thumbView setBackgroundColor:[UIColor grayColor]];
		
		// create new frame
		thumbView.frame = CGRectMake( dx, dy, kThumbnailSize, kThumbnailSize);
		
		// increment position
		dx += kThumbnailSize + kThumbnailSpacing;
		
		// check if we need to move to a different row
		if( dx + kThumbnailSize + kThumbnailSpacing > _thumbsView.frame.size.width - kThumbnailSpacing )
		{
			dx = 0.0;
			dy += kThumbnailSize + kThumbnailSpacing;
		}
	}
	
	// set the content size of the thumb scroller
	[_thumbsView setContentSize:CGSizeMake( _thumbsView.frame.size.width - ( kThumbnailSpacing*2 ), dy + kThumbnailSize + kThumbnailSpacing )];
}


- (void)toggleThumbnailViewWithAnimation:(BOOL)animation
{
    if (_isThumbViewShowing) {
        [self hideThumbnailViewWithAnimation:animation];
    }
    else {
        [self showThumbnailViewWithAnimation:animation];
    }
}


- (void)showThumbnailViewWithAnimation:(BOOL)animation
{
    _isThumbViewShowing = YES;
    
    [self arrangeThumbs];
    [self.navigationItem.rightBarButtonItem setTitle:NSLocalizedString(@"Close", @"")];
    
    if (animation) {
        // do curl animation
        [UIView beginAnimations:@"uncurl" context:nil];
        [UIView setAnimationDuration:.666];
        [UIView setAnimationTransition:UIViewAnimationTransitionCurlDown forView:_thumbsView cache:YES];
        [_thumbsView setHidden:NO];
        [UIView commitAnimations];
    }
    else {
        [_thumbsView setHidden:NO];
    }
}


- (void)hideThumbnailViewWithAnimation:(BOOL)animation
{
    _isThumbViewShowing = NO;
    [self.navigationItem.rightBarButtonItem setTitle:NSLocalizedString(@"See all", @"")];
    
    if (animation) {
        // do curl animation
        [UIView beginAnimations:@"curl" context:nil];
        [UIView setAnimationDuration:.666];
        [UIView setAnimationTransition:UIViewAnimationTransitionCurlUp forView:_thumbsView cache:YES];
        [_thumbsView setHidden:YES];
        [UIView commitAnimations];
    }
    else {
        [_thumbsView setHidden:NO];
    }
}


- (void)handleSeeAllTouch:(id)sender
{
	// show thumb view
	[self toggleThumbnailViewWithAnimation:YES];
	
	// tell thumbs that havent loaded to load
	[self loadAllThumbViewPhotos];
}


- (void)handleThumbClick:(id)sender
{
	GalleryPhotoView *photoView = (GalleryPhotoView *)[(UIButton*)sender superview];
	[self hideThumbnailViewWithAnimation:YES];
	[self gotoImageByIndex:photoView.tag animated:NO];
}


#pragma mark - Image Loading


- (void)preloadThumbnailImages
{
	NSUInteger index = _currentIndex;
	NSUInteger count = [_photoViews count];
    
	// make sure the images surrounding the current index have thumbs loading
	NSUInteger nextIndex = index + 1;
	NSUInteger prevIndex = index - 1;
	
	// the preload count indicates how many images surrounding the current photo will get preloaded.
	// a value of 2 at maximum would preload 4 images, 2 in front of and two behind the current image.
	NSUInteger preloadCount = 1;
	
	GalleryPhoto *photo;
	
	// check to see if the current image thumb has been loaded
	photo = [_photoLoaders objectForKey:[NSString stringWithFormat:@"%i", (int)index]];
	
	if( !photo )
	{
		[self loadThumbnailImageWithIndex:index];
		photo = [_photoLoaders objectForKey:[NSString stringWithFormat:@"%i", (int)index]];
	}
	
	if( !photo.hasThumbLoaded && !photo.isThumbLoading )
	{
		[photo loadThumbnail];
	}
	
	NSUInteger curIndex = prevIndex;
	while( curIndex > -1 && curIndex > prevIndex - preloadCount )
	{
		photo = [_photoLoaders objectForKey:[NSString stringWithFormat:@"%i", (int)curIndex]];
		
		if( !photo ) {
			[self loadThumbnailImageWithIndex:curIndex];
			photo = [_photoLoaders objectForKey:[NSString stringWithFormat:@"%i", (int)curIndex]];
		}
		
		if( !photo.hasThumbLoaded && !photo.isThumbLoading )
		{
			[photo loadThumbnail];
		}
		
		curIndex--;
	}
	
	curIndex = nextIndex;
	while( curIndex < count && curIndex < nextIndex + preloadCount )
	{
		photo = [_photoLoaders objectForKey:[NSString stringWithFormat:@"%i", (int)curIndex]];
		
		if( !photo ) {
			[self loadThumbnailImageWithIndex:curIndex];
			photo = [_photoLoaders objectForKey:[NSString stringWithFormat:@"%i", (int)curIndex]];
		}
		
		if( !photo.hasThumbLoaded && !photo.isThumbLoading )
		{
			[photo loadThumbnail];
		}
		
		curIndex++;
	}
}


- (void)loadAllThumbViewPhotos
{
	NSUInteger i, count = [_photoSource numberOfPhotosForPhotoGallery:self];
	for (i=0; i < count; i++) {
		
		[self loadThumbnailImageWithIndex:i];
	}
}


- (void)loadThumbnailImageWithIndex:(NSUInteger)index
{
	GalleryPhoto *photo = [_photoLoaders objectForKey:[NSString stringWithFormat:@"%i", (int)index]];
	
	if( photo == nil )
		photo = [self createGalleryPhotoForIndex:index];
	
	[photo loadThumbnail];
}


- (void)loadFullsizeImageWithIndex:(NSUInteger)index
{
	GalleryPhoto *photo = [_photoLoaders objectForKey:[NSString stringWithFormat:@"%i", (int)index]];
	
	if( photo == nil )
		photo = [self createGalleryPhotoForIndex:index];
	
	[photo loadFullsize];
}


- (void)unloadFullsizeImageWithIndex:(NSUInteger)index
{
	if (index < [_photoViews count]) {		
		GalleryPhoto *loader = [_photoLoaders objectForKey:[NSString stringWithFormat:@"%i", (int)index]];
		[loader unloadFullsize];
		
		GalleryPhotoView *photoView = [_photoViews objectAtIndex:index];
		photoView.imageView.image = loader.thumbnail;
	}
}


- (GalleryPhoto *)createGalleryPhotoForIndex:(NSUInteger)index
{
	GalleryPhoto *photo;
	UIImage *thumbImage;
    UIImage *fullImage;
    
    if(useNetwork) {
        photo = [[GalleryPhoto alloc] initWithThumbnailUrl:[_photoSource photoGallery:self urlForPhotoSize:FGalleryPhotoSizeFullsize atIndex:index] fullsizeUrl:[_photoSource photoGallery:self urlForPhotoSize:FGalleryPhotoSizeFullsize atIndex:index] delegate:self];
    }
    else {
        thumbImage = fullImage = [_photoSource photoGallery:index];
        photo = [[GalleryPhoto alloc] initWithThumbnail:thumbImage fullImage:fullImage delegate:self];
    }
	photo.tag = index;
	[_photoLoaders setObject:photo forKey: [NSString stringWithFormat:@"%i", (int)index]];
	
	return photo;
}


- (void)scrollingHasEnded {
	
	_isScrolling = NO;
	
	NSUInteger newIndex = floor( _scroller.contentOffset.x / _scroller.frame.size.width );
	
	// don't proceed if the user has been scrolling, but didn't really go anywhere.
	if( newIndex == _currentIndex )
		return;
	
	// clear previous
	[self unloadFullsizeImageWithIndex:_currentIndex];
	
	_currentIndex = newIndex;
    [self updateTitle];
	[self loadFullsizeImageWithIndex:_currentIndex];
	[self preloadThumbnailImages];
}


#pragma mark - GalleryPhoto Delegate Methods


- (void)galleryPhoto:(GalleryPhoto*)photo willLoadThumbnailFromPath:(NSString*)path
{

}


- (void)galleryPhoto:(GalleryPhoto *)photo willLoadThumbnailFromUrl:(NSString*)url
{
}


- (void)galleryPhoto:(GalleryPhoto *)photo didLoadThumbnail:(UIImage*)image
{
    if(((int) photo.tag) < 0) {
        return;
    }
	// grab the associated image view
	GalleryPhotoView *photoView = [_photoViews objectAtIndex:photo.tag];
	
	// if the gallery photo hasn't loaded the fullsize yet, set the thumbnail as its image.
	if( !photo.hasFullsizeLoaded )
		photoView.imageView.image = photo.thumbnail;

	// grab the thumbail view and set its image
	GalleryPhotoView *thumbView = [_photoThumbnailViews objectAtIndex:photo.tag];
	thumbView.imageView.image = image;
}



- (void)galleryPhoto:(GalleryPhoto *)photo didLoadFullsize:(UIImage*)image
{
	// only set the fullsize image if we're currently on that image
	if(_currentIndex == photo.tag && _currentIndex>=0)
	{
		GalleryPhotoView *photoView = [_photoViews objectAtIndex:photo.tag];
		photoView.imageView.image = photo.fullsize;
	}
	// otherwise, we don't need to keep this image around
	else [photo unloadFullsize];
}


#pragma mark - UIScrollView Methods


- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
	_isScrolling = YES;
}
 

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
	if( !decelerate )
	{
		[self scrollingHasEnded];
	}
}


- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
	[self scrollingHasEnded];
}


#pragma mark - Memory Management Methods

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
	
	NSLog(@"[FGalleryViewController] didReceiveMemoryWarning! clearing out cached images...");
	// unload fullsize and thumbnail images for all our images except at the current index.
	NSArray *keys = [_photoLoaders allKeys];
	NSUInteger i, count = [keys count];
    if (_isThumbViewShowing==YES) {
        for (i = 0; i < count; i++)
        {
            GalleryPhoto *photo = [_photoLoaders objectForKey:[keys objectAtIndex:i]];
            [photo unloadFullsize];
            
            // unload main image thumb
            GalleryPhotoView *photoView = [_photoViews objectAtIndex:i];
            photoView.imageView.image = nil;
        }
    } else {
        for (i = 0; i < count; i++)
        {
            if( i != _currentIndex )
            {
                GalleryPhoto *photo = [_photoLoaders objectForKey:[keys objectAtIndex:i]];
                [photo unloadFullsize];
                [photo unloadThumbnail];
                
                // unload main image thumb
                GalleryPhotoView *photoView = [_photoViews objectAtIndex:i];
                photoView.imageView.image = nil;
                
                // unload thumb tile
                photoView = [_photoThumbnailViews objectAtIndex:i];
                photoView.imageView.image = nil;
            }
        }
    }
}


- (void)dealloc {
	
	// remove KVO listener
	[_container removeObserver:self forKeyPath:@"frame"];
	
	// Cancel all photo loaders in progress
	NSArray *keys = [_photoLoaders allKeys];
	NSUInteger i, count = [keys count];
	for (i = 0; i < count; i++) {
		GalleryPhoto *photo = [_photoLoaders objectForKey:[keys objectAtIndex:i]];
		photo.delegate = nil;
		[photo unloadThumbnail];
		[photo unloadFullsize];
	}
	
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
	_photoSource = nil;
    _innerContainer = nil;
    _thumbsView = nil;
    _scroller = nil;
	
	[_photoLoaders removeAllObjects];
    _photoLoaders = nil;
	
	[_photoThumbnailViews removeAllObjects];
    _photoThumbnailViews = nil;
	
	[_photoViews removeAllObjects];
    _photoViews = nil;
	
}


@end


/**
 *	This section overrides the auto-rotate methods for UINaviationController and UITabBarController 
 *	to allow the tab bar to rotate only when a FGalleryController is the visible controller. Sweet.
 */

@implementation UINavigationController (FGallery)

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	if([self.visibleViewController isKindOfClass:[GalleryViewController class]])
	{
        return YES;
	}

	// To preserve the UINavigationController's defined behavior,
	// walk its stack.  If all of the view controllers in the stack
	// agree they can rotate to the given orientation, then allow it.
	BOOL supported = YES;
	for(UIViewController *sub in self.viewControllers)
	{
		if(![sub shouldAutorotateToInterfaceOrientation:interfaceOrientation])
		{
			supported = NO;
			break;
		}
	}	
	if(supported)
		return YES;
	
	// we need to support at least one type of auto-rotation we'll get warnings.
	// so, we'll just support the basic portrait.
	return ( interfaceOrientation == UIInterfaceOrientationPortrait ) ? YES : NO;
}


- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
	// see if the current controller in the stack is a gallery
	if([self.visibleViewController isKindOfClass:[GalleryViewController class]])
	{
		GalleryViewController *galleryController = (GalleryViewController*)self.visibleViewController;
		[galleryController resetImageViewZoomLevels];
	}
}

@end




@implementation UITabBarController (FGallery)


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // only return yes if we're looking at the gallery
    if( [self.selectedViewController isKindOfClass:[UINavigationController class]])
    {
        UINavigationController *navController = (UINavigationController*)self.selectedViewController;
        
        // see if the current controller in the stack is a gallery
        if([navController.visibleViewController isKindOfClass:[GalleryViewController class]])
        {
            return YES;
        }
    }
	
	// we need to support at least one type of auto-rotation we'll get warnings.
	// so, we'll just support the basic portrait.
	return ( interfaceOrientation == UIInterfaceOrientationPortrait ) ? YES : NO;
}


- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
	if([self.selectedViewController isKindOfClass:[UINavigationController class]])
	{
		UINavigationController *navController = (UINavigationController*)self.selectedViewController;
		
		// see if the current controller in the stack is a gallery
		if([navController.visibleViewController isKindOfClass:[GalleryViewController class]])
		{
			GalleryViewController *galleryController = (GalleryViewController*)navController.visibleViewController;
			[galleryController resetImageViewZoomLevels];
		}
	}
}


@end



