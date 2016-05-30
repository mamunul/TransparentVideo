//
//  MediaManager.h
//  Fireworks
//
//  Created by Mo DeJong on 10/3/15.
//  Copyright © 2015 helpurock. All rights reserved.
//
//  This object makes it possible to manage Media objects and resources
//  as view controllers change.

#import <UIKit/UIKit.h>
#import "AutoTimer.h"

#import "MediaManager.h"

#import "AVAnimatorView.h"
#import "AVAnimatorMedia.h"
#import "AVAsset2MvidResourceLoader.h"
#import "AVAssetJoinAlphaResourceLoader.h"
#import "AVMvidFrameDecoder.h"

#import "AVAnimatorMediaPrivate.h"

#include <stdlib.h>

@class AVAsset2MvidResourceLoader;
@class AVAnimatorMedia;
@class AVAssetJoinAlphaResourceLoader;

@interface MediaManager : NSObject


@property (nonatomic, retain) AVAssetJoinAlphaResourceLoader *L12Loader;
@property (nonatomic, retain) AVAnimatorMedia *L12Media;

// constructor

+ (MediaManager*) mediaManager;

//- (void) makeLoaders;
- (void) loadVideoFiles:(NSString*) rgbFile AlphaFile:(NSString*) alphaFile;

- (void) startAsyncLoading:(UIView*) fieldContainerLocal;

// Check to see if all loaders are ready now

- (BOOL) allLoadersReady;

// Return array of all active media objects

- (NSArray*) getAllMedia;

// Return array of all alpha channel fireworks media

- (NSArray*) getMedia;

-(void)updateVideoFrame:(CGRect) rect;

@end

