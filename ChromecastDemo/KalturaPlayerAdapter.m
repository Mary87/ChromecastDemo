//
//  KalturaPlayerAdapter.m
//  ChromecastDemo
//
//  Created by Mary  on 8/25/16.
//  Copyright © 2016 3ss. All rights reserved.
//

#import "KalturaPlayerAdapter.h"

@interface KalturaPlayerAdapter () <KPViewControllerDelegate>

@property (nonatomic, strong) KPPlayerConfig *playerConfig;
@property (nonatomic, strong) KPViewController *playerVC;
@property (nonatomic) BOOL isCasting;
@property (nonatomic) BOOL shouldStartCasting;
@property (nonatomic, weak, readonly) UIView *renderingView;
@property (nonatomic, strong, readonly) ChromecastListener *chromecastListener;

@end


@implementation KalturaPlayerAdapter

@synthesize renderingView = _renderingView;

#pragma mark - Lifecycle
#pragma mark -

- (instancetype)initWithRenderingView:(UIView *)renderingView chromecastListener:(ChromecastListener *)chromecastListener {
    self = [super init];
    if (self) {
        _renderingView = renderingView;
        _chromecastListener = chromecastListener;
        static NSString * const serverUrlString = @"http://kgit.html5video.org/tags/v2.48.6/mwEmbedFrame.php";
        [config addConfigKey:@"autoPlay" withValue:@"true"];
        [config addConfigKey:@"fullScreenBtn.visible" withValue:@"false"];
        [config addConfigKey:@"chromecast.plugin" withValue:@"true"];
        [config addConfigKey:@"chromecast.useKalturaPlayer" withValue:@"true"];
        [config addConfigKey:@"chromecast.applicationID" withValue:@"276999A7"];
        [config addConfigKey:@"chromecast.receiverLogo" withValue:@"true"];
        [config addConfigKey:@"chromecast.logoUrl" withValue:@"http://stwww.motortrendondemand.com/wp-content/uploads/2016/08/MTOD_TV_Splash_Image.png"];
        [config addConfigKey:@"strings.mwe-chromecast-loading" withValue:@"Loading Motor Trend OnDemand"];
        [config addConfigKey:@"controlBarContainer.plugin" withValue:@"true"];
        [config addConfigKey:@"controlBarContainer.hover" withValue:@"true"];
        [config addConfigKey:@"sourceSelector.displayMode" withValue:@"size"];
        [config addConfigKey:@"sourceSelector.plugin" withValue:@"true"];
        [config addConfigKey:@"hlsjs.plugin" withValue:@"false"];
        self.playerConfig = config;
    }
    return self;
}



- (void)playVideoWithIdentifier:(NSString *)videoIdentifier {
    if (self.playerVC) {
        self.playerConfig.entryId = videoIdentifier;
        [self.playerVC changeMedia:videoIdentifier];
        return;
    }
    
    self.playerConfig.entryId = videoIdentifier;
    KPViewController *playerVC = [[KPViewController alloc] initWithConfiguration:self.playerConfig];
    playerVC.delegate = self;
    
    UIResponder *parentResponder = [self.renderingView nextResponder];
    while (parentResponder && ![parentResponder isKindOfClass:[UIViewController class]]) {
        parentResponder = [parentResponder nextResponder];
    }
    
    UIViewController *parentVC = (UIViewController *)parentResponder;
    playerVC.view.frame = self.renderingView.bounds;
    [playerVC loadPlayerIntoViewController:parentVC];
    [self.renderingView addSubview:playerVC.view];
    self.playerVC = playerVC;
}

- (void)resume {
    [self.playerVC.playerController play];
}

- (void)pause {
    [self.playerVC.playerController pause];
}

- (void)close {
    self.playerVC.castProvider = nil;
    [self closePlayer];
}

- (void)closePlayer {
    [self pause];
    [self.playerVC removePlayer];
    self.playerVC.delegate = nil;
    self.playerVC = nil;
    
    for (UIView *view in self.renderingView.subviews) {
        [view removeFromSuperview];
    }
}




#pragma mark - KPViewControllerDelegate

- (void)kPlayer:(KPViewController *)player didFailWithError:(NSError *)error {
    NSLog(@"%@ >> kPlayer:didFailWithError. Player: %@\nError: %@", [self class], player, error);
}

- (void)kPlayer:(KPViewController *)player playerFullScreenToggled:(BOOL)isFullScreen {
    NSLog(@"%@ >> kPlayer:playerFullScreenToggled:. Player: %@\nIsFullScreen: %d", [self class], player, isFullScreen);
}

- (void)kPlayer:(KPViewController *)player playerLoadStateDidChange:(KPMediaLoadState)state {
    NSLog(@"%@ >> kPlayer:playerLoadStateDidChange:. Player: %@\nState: %d", [self class], player, (int)state);
    
    if (state & KPMediaLoadStatePlayable) {
    }
}

- (void)kPlayer:(KPViewController *)player playerPlaybackStateDidChange:(KPMediaPlaybackState)state {
    [self logState:state forPlayer:player];
    switch (state) {
        case KPMediaPlaybackStatePlaying: {
            [self.delegate playerAdapterDidResume];
            if (!self.playerVC.castProvider && self.chromecastListener.castProvider) {
                self.playerVC.castProvider = self.chromecastListener.castProvider;
            }
            break;
        }
        case KPMediaPlaybackStatePaused: {
            [self.delegate playerAdapterDidPause];
            break;
        }
        case KPMediaPlaybackStateEnded: {
            [self.delegate playerAdapterDidPlayToEnd];
            break;
        }
            
        default:
            break;
    }
}





#pragma mark - Private

- (void)logState:(KPMediaPlaybackState)state forPlayer:(KPViewController *)player {
    NSLog(@"%@ >> kPlayer:playerPlaybackStateDidChange:. Player: %@\nKPMediaPlaybackStateUnknown = %d\nKPMediaPlaybackStateLoaded = %d\nKPMediaPlaybackStateReady = %d\nKPMediaPlaybackStatePlaying = %d\nKPMediaPlaybackStatePaused = %d\nKPMediaPlaybackStateEnded = %d\nKPMediaPlaybackStateInterrupted = %d\nKPMediaPlaybackStateSeekingForward = %d\nKPMediaPlaybackStateSeekingBackward = %d",
                 [self class],
                 player,
                 state == KPMediaPlaybackStateUnknown,
                 state == KPMediaPlaybackStateLoaded,
                 state == KPMediaPlaybackStateReady,
                 state == KPMediaPlaybackStatePlaying,
                 state == KPMediaPlaybackStatePaused,
                 state == KPMediaPlaybackStateEnded,
                 state == KPMediaPlaybackStateInterrupted,
                 state == KPMediaPlaybackStateSeekingForward,
                 state == KPMediaPlaybackStateSeekingBackward);
}


@end
