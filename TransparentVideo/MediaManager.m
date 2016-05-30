//
//  MediaManager.m
//  Fireworks
//
//  Created by Mo DeJong on 10/3/15.
//  Copyright © 2015 helpurock. All rights reserved.
//

#import "MediaManager.h"
#import "AutoTimer.h"
#import "AVFileUtil.h"
#import "AVMvidFrameDecoder.h"
#import "AVAnimatorMedia.h"
// Specific kind of resource to mvid converter to use
#import "AVAsset2MvidResourceLoader.h"

#import "AVAssetJoinAlphaResourceLoader.h"

@interface MediaManager ()
{
	NSMutableArray *fieldSubviews;
	BOOL shouldStopAnimation;
	AutoTimer *checkLoadingTimer;
	UIView* fieldContainer;
	AVAnimatorView *fieldSubview;
}

@end

@implementation MediaManager

+ (MediaManager*) mediaManager
{
    return [[MediaManager alloc] init];
}



- (void) loadVideoFiles:(NSString*) rgbFile AlphaFile:(NSString*) alphaFile
{
	NSString *rgbResourceName;
	NSString *alphaResourceName;
	NSString *rgbTmpMvidFilename;
	NSString *rgbTmpMvidPath;
	AVAssetJoinAlphaResourceLoader *resLoader;
	AVAnimatorMedia *media;
	// L12 : single firework
	//    rgbResourceName = @"1_2_rgb_CRF_30_24BPP.m4v";
	//    alphaResourceName = @"1_2_alpha_CRF_30_24BPP.m4v";
	//	 rgbTmpMvidFilename = @"1_2_rgb_CRF_30_24BPP.mvid";
	rgbResourceName = rgbFile;// @"mask_rgb_CRF_30_24BPP.m4v";
	alphaResourceName = alphaFile;// @"mask_alpha_CRF_30_24BPP.m4v";
	rgbTmpMvidFilename = @"mask_rgb_CRF_30_24BPP.mvid";
	rgbTmpMvidPath = [AVFileUtil getTmpDirPath:rgbTmpMvidFilename];
	resLoader = [AVAssetJoinAlphaResourceLoader aVAssetJoinAlphaResourceLoader];
	resLoader.movieRGBFilename = rgbResourceName;
	resLoader.movieAlphaFilename = alphaResourceName;
	resLoader.outPath = rgbTmpMvidPath;
	resLoader.alwaysGenerateAdler = TRUE;
	resLoader.serialLoading = TRUE;
	media = [AVAnimatorMedia aVAnimatorMedia];
	media.resourceLoader = resLoader;
	media.frameDecoder = [AVMvidFrameDecoder aVMvidFrameDecoder];
	NSAssert(resLoader, @"resLoader");
	NSAssert(media, @"media");
	self.L12Loader = resLoader;
	self.L12Media = media;
	return;
}

- (AVAsset2MvidResourceLoader*) loaderFor24BPPH264:(NSString*)resFilename
                                       outFilename:(NSString*)outFilename
{
    AVAsset2MvidResourceLoader *loader = [AVAsset2MvidResourceLoader aVAsset2MvidResourceLoader];
    loader.movieFilename = resFilename;
    NSString *outPath = [AVFileUtil getTmpDirPath:outFilename];
    loader.outPath = outPath;
    return loader;
}

// Return array of all active media objects

- (NSArray*) getAllMedia
{
    NSMutableArray *mArr = [NSMutableArray array];
    [mArr addObjectsFromArray:[self getMedia]];
    return mArr;
}

// Return array of all alpha channel fireworks media

- (NSArray*) getMedia
{
    return @[self.L12Media];
}

- (void) startAsyncLoading:(UIView*) fieldContainerLocal
{
    for (AVAnimatorMedia *media in [self getAllMedia])
    {
        [media prepareToAnimate];
    }
	fieldContainer = fieldContainerLocal;
	checkLoadingTimer = [AutoTimer autoTimerWithTimeInterval:1.0
														   target:self
														 selector:@selector(checkLoadingTimerCallback:)
														 userInfo:nil
														  repeats:TRUE];
}

// Check to see if all loaders are ready now

- (BOOL) allLoadersReady
{
    BOOL allReady = TRUE;
    for (AVAnimatorMedia *media in [self getAllMedia])
    {
        AVResourceLoader *loader = media.resourceLoader;
        if (loader.isReady == FALSE)
        {
            allReady = FALSE;
        }
    }
    return allReady;
}

-(void) startAnimation:(CGRect)rect
{
	
	
	
	
	NSArray *arr = [self getMedia];
	AVAnimatorMedia *media = arr[0];
	int mediaWidth = (int)media.frameDecoder.width;
	int mediaHeight = (int)media.frameDecoder.height;
	
	fieldSubview = [AVAnimatorView aVAnimatorViewWithFrame:rect];
	fieldSubview.contentMode = UIViewContentModeScaleAspectFit;
	[fieldContainer addSubview:fieldSubview];
	[fieldSubviews addObject:fieldSubview];
	
	[self stopMediaAndRemoveView:media];
 
	//    fieldSubview.frame = CGRectMake(20, 100, mediaWidth, mediaHeight);
	[fieldSubview attachMedia:media];
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(animatorDoneNotification:)
												 name:AVAnimatorDoneNotification
											   object:media];
	[media startAnimator];
}

-(void)updateVideoFrame:(CGRect) rect{

	
	dispatch_async(dispatch_get_main_queue(), ^{
		fieldSubview.frame = rect;
	});
	


}

- (void)animatorDoneNotification:(NSNotification*)notification
{
	AVAnimatorMedia *media = notification.object;
	if (shouldStopAnimation)
	{
		[self stopMediaAndRemoveView:media];
	}
	else
	{
		[media startAnimator];
	}
}

- (void) stopMediaAndRemoveView:(AVAnimatorMedia*)media
{
	id<AVAnimatorMediaRendererProtocol> renderer = media.renderer;
	AVAnimatorView *aVAnimatorView = (AVAnimatorView*) renderer;
	[media stopAnimator];
	[aVAnimatorView attachMedia:nil];
	[aVAnimatorView removeFromSuperview];
	int numBefore = (int) fieldSubviews.count;
	[fieldSubviews removeObject:aVAnimatorView];
	int numAfter = (int) fieldSubviews.count;
//	NSAssert(numBefore == numAfter, @"numBefore == numAfter");
}

- (void) checkLoadingTimerCallback:(NSTimer*)timer
{
	NSLog(@"checkLoadingTimerCallback");
	
	BOOL allReady = [self allLoadersReady];
	
	if (allReady)
	{
		[timer invalidate];
		shouldStopAnimation = false;
		
		NSArray *arr = [self getMedia];
		AVAnimatorMedia *media = arr[0];
		int mediaWidth = (int)media.frameDecoder.width;
		int mediaHeight = (int)media.frameDecoder.height;
		
		CGRect rect = CGRectMake(20, 100, mediaWidth, mediaHeight);
		
		[self startAnimation:rect];
	}
	
}

@end
