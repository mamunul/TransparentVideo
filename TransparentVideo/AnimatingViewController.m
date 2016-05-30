//
//  AnimatingViewController.m
//  Fireworks
//
//  Created by Mo DeJong on 10/3/15.
//  Copyright © 2015 helpurock. All rights reserved.
//

#import "AnimatingViewController.h"

#import "AppDelegate.h"

#import "AutoTimer.h"

#import "MediaManager.h"

#import "AVAnimatorView.h"
#import "AVAnimatorMedia.h"
#import "AVAsset2MvidResourceLoader.h"
#import "AVAssetJoinAlphaResourceLoader.h"
#import "AVMvidFrameDecoder.h"

#import "AVAnimatorMediaPrivate.h"

#include <stdlib.h>

@interface AnimatingViewController ()

@property (nonatomic, retain) IBOutlet UIView *fieldContainer;
@property (nonatomic, retain) NSMutableArray *fieldSubviews;
@property (nonatomic, retain) AutoTimer *startLoadingTimer;
@property (nonatomic, retain) AutoTimer *checkLoadingTimer;
@property (readwrite) BOOL shouldStopAnimation;
@end

@implementation AnimatingViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    MediaManager *mediaManager = appDelegate.mediaManager;
    [mediaManager makeLoaders];
    self.startLoadingTimer = [AutoTimer autoTimerWithTimeInterval:0.10
                                                           target:mediaManager
                                                         selector:@selector(startAsyncLoading)
                                                         userInfo:nil
                                                          repeats:FALSE];
    self.checkLoadingTimer = [AutoTimer autoTimerWithTimeInterval:1.0
                                                           target:self
                                                         selector:@selector(checkLoadingTimerCallback:)
                                                         userInfo:nil
                                                          repeats:TRUE];
}


- (void) checkLoadingTimerCallback:(NSTimer*)timer
{
    NSLog(@"checkLoadingTimerCallback");
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    MediaManager *mediaManager =appDelegate.mediaManager;
    BOOL allReady = [mediaManager allLoadersReady];
    if (allReady)
    {
        [timer invalidate];
        self.shouldStopAnimation = false;
        [self startAnimation];
    }
}


-(void) startAnimation
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    MediaManager *mediaManager = appDelegate.mediaManager;
    AVAnimatorView *fieldSubview;
    fieldSubview = [AVAnimatorView aVAnimatorViewWithFrame:CGRectMake(100, 100, 200, 200)];
    fieldSubview.contentMode = UIViewContentModeScaleAspectFit;
    [self.fieldContainer addSubview:fieldSubview];
    [self.fieldSubviews addObject:fieldSubview];
    NSArray *arr = [mediaManager getFireworkMedia];
    AVAnimatorMedia *media = arr[0];
    [self stopMediaAndRemoveView:media];
    int mediaWidth = (int)media.frameDecoder.width;
    int mediaHeight = (int)media.frameDecoder.height;
    fieldSubview.frame = CGRectMake(20, 100, mediaWidth, mediaHeight);
    [fieldSubview attachMedia:media];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(animatorDoneNotification:)
                                                 name:AVAnimatorDoneNotification
                                               object:media];
    [media startAnimator];
}

- (void) stopMediaAndRemoveView:(AVAnimatorMedia*)media
{
    id<AVAnimatorMediaRendererProtocol> renderer = media.renderer;
    AVAnimatorView *aVAnimatorView = (AVAnimatorView*) renderer;
    [media stopAnimator];
    [aVAnimatorView attachMedia:nil];
    [aVAnimatorView removeFromSuperview];
    int numBefore = (int) self.fieldSubviews.count;
    [self.fieldSubviews removeObject:aVAnimatorView];
    int numAfter = (int) self.fieldSubviews.count;
    NSAssert(numBefore == numAfter, @"numBefore == numAfter");
}

- (void)animatorDoneNotification:(NSNotification*)notification
{
    AVAnimatorMedia *media = notification.object;
    if (self.shouldStopAnimation)
    {
        [self stopMediaAndRemoveView:media];
    }
    else
    {
        [media startAnimator];
    }
}

- (CGPoint) firstTouchLocation:(UIEvent*)event
{
    for (UITouch* touch in event.allTouches)
    {
        CGPoint location = [touch locationInView:self.view];
        return location;
    }
    return CGPointMake(0, 0);
}

- (IBAction)stopAnimation:(id)sender {
    self.shouldStopAnimation = !self.shouldStopAnimation;
    if (self.shouldStopAnimation) {
        [((UIButton *)sender) setTitle:@"Start Animation" forState:UIControlStateNormal];
    }
    else
    {
        [((UIButton *)sender) setTitle:@"Stop Animation" forState:UIControlStateNormal];
        [self startAnimation];
    }
    
}

@end
