//
//  KalturaPlayerAdapter.m
//  ChromecastDemo
//
//  Created by Mary  on 8/25/16.
//  Copyright © 2016 3ss. All rights reserved.
//

#import "KalturaPlayerAdapter.h"


//#import "MTChromecastBarButtonItem.h"


@interface KalturaPlayerAdapter () <KPViewControllerDelegate, KCastProviderDelegate>

@property (nonatomic, strong) KPPlayerConfig *playerConfig;
@property (nonatomic, strong) KPViewController *playerVC;
@property (nonatomic, strong) KCastProvider *castProvider;
@property (nonatomic) BOOL isCasting;
@property (nonatomic) BOOL shouldStartCasting;
@property (nonatomic, weak, readonly) UIView *renderingView;

@end


@implementation KalturaPlayerAdapter

@synthesize renderingView = _renderingView;

#pragma mark - Lifecycle
#pragma mark -

- (instancetype)initWithRenderingView:(UIView *)renderingView {
    self = [super init];
    if (self) {
        _renderingView = renderingView;
        static NSString * const serverUrlString = @"http://cdnapi.kaltura.com/html5/html5lib/v2.46/mwEmbedFrame.php";
        static NSString * const uiConfigId = @"34339251";
        static NSString * const partnerId = @"2093031";
        KPPlayerConfig *config = config = [[KPPlayerConfig alloc] initWithServer:serverUrlString
                                                                        uiConfID:uiConfigId
                                                                       partnerId:partnerId];

        [config addConfigKey:@"autoPlay" withValue:@"true"];
        [config addConfigKey:@"fullScreenBtn.visible" withValue:@"false"];
        [config addConfigKey:@"chromecast.plugin" withValue:@"true"];
        [config addConfigKey:@"chromecast.useKalturaPlayer" withValue:@"true"];
        [config addConfigKey:@"chromecast.applicationID" withValue:@"C43947A1"];
        [config addConfigKey:@"controlBarContainer.plugin" withValue:@"true"];
        [config addConfigKey:@"controlBarContainer.hover" withValue:@"true"];
        self.playerConfig = config;
        
        self.castProvider = [[KCastProvider alloc] init];
        self.castProvider.delegate = self;
        [self.castProvider startScan:@"C43947A1"];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(applicationDidEnterBackgroundNotificationHandler)
                                                     name:UIApplicationDidEnterBackgroundNotification
                                                   object:nil];
    }
    return self;
}



- (void)playVideoWithIdentifier:(NSString *)videoIdentifier {
    if (self.playerVC) {
        if (self.isCasting) {
            [self.castProvider disconnectFromDeviceWithLeave];

            // self.shouldStartCasting = YES;
        }
        self.playerConfig.entryId = videoIdentifier;
        [self.playerVC changeConfiguration:self.playerConfig];
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
    [self stopCasting];
    self.castProvider.delegate = nil;
    self.castProvider = nil;
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
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            //            if (self.shouldStartCasting) {
            //                [self connectToDevice:self.castProvider.selectedDevice];
            //                self.shouldStartCasting = NO;
            //            }
        });
    }
}

- (void)kPlayer:(KPViewController *)player playerPlaybackStateDidChange:(KPMediaPlaybackState)state {
    [self logState:state forPlayer:player];
    switch (state) {
        case KPMediaPlaybackStatePlaying: {
            [self.delegate playerAdapterDidResume];
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





#pragma mark - KCastProviderDelegate

- (void)castProvider:(KCastProvider *)provider devicesInRange:(BOOL)foundDevices {
    NSLog(@"%@ >> castProvider:devicesInRange:.", self.class);
    [self changeChromecastBarButtonState:provider];
}

- (void)castProvider:(KCastProvider *)provider didDeviceComeOnline:(KCastDevice *)device {
    NSLog(@"%@ >> castProvider:didDeviceComeOnline:.", self.class);
    [self changeChromecastBarButtonState:provider];
}

- (void)castProvider:(KCastProvider *)provider didDeviceGoOffline:(KCastDevice *)device {
    NSLog(@"%@ >> castProvider:didDeviceGoOffline:.", self.class);
    [self changeChromecastBarButtonState:provider];
}

- (void)didConnectToDevice:(KCastProvider *)provider {
    NSLog(@"%@ >> didConnectToDevice:.", self.class);
    self.playerVC.castProvider = self.castProvider;
    [self changeChromecastBarButtonState:provider];
}

- (void)didDisconnectFromDevice:(KCastProvider *)provider {
    NSLog(@"%@ >> didDisconnectFromDevice:.", self.class);
    [self stopCasting];
}

- (void)castProvider:(KCastProvider *)provider didFailToConnectToDevice:(NSError *)error {
    NSLog(@"%@ >> castProvider:didFailToConnectToDevice:.", self.class);
    [self changeChromecastBarButtonState:provider];
}

- (void)castProvider:(KCastProvider *)provider didFailToDisconnectFromDevice:(NSError *)error {
    NSLog(@"%@ >> castProvider:didFailToDisconnectFromDevice:.", self.class);
    [self changeChromecastBarButtonState:provider];
}

- (void)castProvider:(KCastProvider *)provider mediaRemoteControlReady:(id<KCastMediaRemoteControl>)mediaRemoteControl {
    NSLog(@"%@ >> castProvider:mediaRemoteControlReady:.", self.class);
    self.isCasting = YES;
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



- (void)chromecastBarButtonTouchUpInside:(id)sender {
    UIAlertController* deviceList = [UIAlertController alertControllerWithTitle:@"Select a device for casting"
                                                                        message:nil
                                                                 preferredStyle:UIAlertControllerStyleActionSheet];
    
    NSArray *devices = self.castProvider.devices;
    if (devices && devices.count > 0) {
        for (KCastDevice *device in devices) {
            UIAlertAction *action = [UIAlertAction new];
            if (self.castProvider.isConnected && [device.routerId isEqualToString:self.castProvider.selectedDevice.routerId]) {
                action = [UIAlertAction actionWithTitle:[NSString stringWithFormat:@"%@ - Disconnect", device.routerName] style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
                    [self disconnectFromDevice:device];
                }];
            }
            else {
                action = [UIAlertAction actionWithTitle:device.routerName style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    [self connectToDevice:device];
                }];
            }
            [deviceList addAction:action];
        }
        
    }
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [deviceList dismissViewControllerAnimated:YES completion:nil];
    }];
    [deviceList addAction:cancelAction];
    
    [self.delegate displayDeviceListAlertViewController:deviceList];
}

- (void)disconnectFromDevice:(KCastDevice *)device {
    [self stopCasting];
}

- (void)stopCasting {
    [self.castProvider disconnectFromDeviceWithLeave];
    self.isCasting = NO;
    [self changeChromecastBarButtonState:self.castProvider];
}

- (void)connectToDevice:(KCastDevice *)device {
    [self stopCasting];
    [self.castProvider connectToDevice:device];
}

- (void)changeChromecastBarButtonState:(KCastProvider *)provider {
    ChromecastBarButtonItem *chromecastButton;
    if (provider.devices.count > 0) {
        if (provider.isConnected) {
            chromecastButton = [self createChromecastBarButtonItemWithState:ChromecastBarButtonItemStateCastConnected];
        }
        else {
            chromecastButton = [self createChromecastBarButtonItemWithState:ChromecastBarButtonItemStateCastAvailable];
        }
    }
    else {
        chromecastButton = [self createChromecastBarButtonItemWithState:ChromecastBarButtonItemStateCastUnavailable];
    }
    [self.delegate updateWithChromecastBarButton:chromecastButton];
}


- (ChromecastBarButtonItem *)createChromecastBarButtonItemWithState:(ChromecastBarButtonItemState)state {
    ChromecastBarButtonItem *chromecastBarButton = [[ChromecastBarButtonItem alloc] initWithState:state style:UIBarButtonItemStylePlain target:self action:@selector(chromecastBarButtonTouchUpInside:)];
    chromecastBarButton.imageInsets = UIEdgeInsetsMake(0, 10, 0, -10);
    return chromecastBarButton;
}

- (void)applicationDidEnterBackgroundNotificationHandler {
    [self stopCasting];
}

@end
