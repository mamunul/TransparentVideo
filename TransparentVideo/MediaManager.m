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

@end

@implementation MediaManager

+ (MediaManager*) mediaManager
{
    return [[MediaManager alloc] init];
}



- (void) makeH264RGBAlphaLoaders
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
    rgbResourceName = @"mask_rgb_CRF_30_24BPP.m4v";
    alphaResourceName = @"mask_alpha_CRF_30_24BPP.m4v";
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

- (void) makeLoaders
{
    [self makeH264RGBAlphaLoaders];
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
    [mArr addObjectsFromArray:[self getFireworkMedia]];
    return mArr;
}

// Return array of all alpha channel fireworks media

- (NSArray*) getFireworkMedia
{
    return @[self.L12Media];
}

- (void) startAsyncLoading
{
    for (AVAnimatorMedia *media in [self getAllMedia])
    {
        [media prepareToAnimate];
    }
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

@end
