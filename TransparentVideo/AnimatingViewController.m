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

@interface AnimatingViewController (){

	MediaManager *mediaManager;
	int i ;

}

@property (nonatomic, retain) IBOutlet UIView *fieldContainer;

@end

@implementation AnimatingViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    mediaManager = [MediaManager mediaManager];
    [mediaManager loadVideoFiles:@"mask_rgb_CRF_30_24BPP.m4v" AlphaFile:@"mask_alpha_CRF_30_24BPP.m4v"];
	[mediaManager startAsyncLoading:_fieldContainer];
	
	i = 0;
	
	
	
	
	
	[NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(updateFrame) userInfo:nil repeats:YES];

	
   
}

-(void)updateFrame{
	
	CGRect rect = CGRectMake(0, i++, 100, 100);

	[mediaManager updateVideoFrame:rect];


}



@end
