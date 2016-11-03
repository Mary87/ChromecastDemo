//
//  ViewController.m
//  ChromecastDemo
//
//  Created by Mary  on 8/25/16.
//  Copyright © 2016 3ss. All rights reserved.
//

#import <GoogleCast/GoogleCast.h>
#import "ViewController.h"
#import "KalturaPlayerAdapter.h"
#import "ChromecastListener.h"

@interface ViewController () <KalturaPlayerAdapterDelegate, ChromecastListenerDelegate>

@property (weak, nonatomic) IBOutlet UIView *playerPlaceholderView;
@property (weak, nonatomic) IBOutlet UINavigationBar *navigationBar;
@property (nonatomic, strong) KalturaPlayerAdapter *playerAdapter;
@property (nonatomic, strong) ChromecastListener *chromecastListener;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _chromecastListener = [[ChromecastListener alloc] init];
    _chromecastListener.delegate = self;
    UIBarButtonItem *chromecastBarButtonItem = [self createChromecastNavigationBarButton];
    UINavigationItem *navItem = self.navigationBar.items.firstObject;
    [navItem setRightBarButtonItem:chromecastBarButtonItem];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)playFirstVideoButtonTouchUpInside:(id)sender {
    [self playVideoWithIdentifier:@"0_ey97gjd9"];
}

- (IBAction)playSecondVideoButtonTouchUpInside:(id)sender {
    [self playVideoWithIdentifier:@"0_00cgwpoe"];
}

- (void)playVideoWithIdentifier:(NSString *)vidoeIdentifier {
    if (!self.playerAdapter) {
        self.playerAdapter = [[KalturaPlayerAdapter alloc] initWithRenderingView:self.playerPlaceholderView chromecastListener:self.chromecastListener];
        self.playerAdapter.delegate = self;
    }
    [self.playerAdapter playVideoWithIdentifier:vidoeIdentifier];
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}





#pragma mark - Protocols
#pragma mark - KalturaPlayerAdapterDelegate

- (void)displayDeviceListAlertViewController:(UIAlertController *)deviceList {
    [self presentViewController:deviceList animated:YES completion:nil];
}

- (void)playerAdapterDidPlayToEnd {
    
}

- (void)playerAdapterDidPause {
    
}

- (void)playerAdapterDidResume {
    
}



#pragma mark - ChromecastListenerDelegate




#pragma mark - Private
#pragma mark -

- (UIBarButtonItem *)createChromecastNavigationBarButton {
    GCKUICastButton *castButton = [[GCKUICastButton alloc] initWithFrame:CGRectMake(0, 0, 24, 24)];
    castButton.tintColor = [UIColor whiteColor];
    UIImage *activeIcon = [[UIImage imageNamed:@"cast-connected-button"]
                           imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    UIImage *inactiveIcon = [[UIImage imageNamed:@"cast-available-button"]
                             imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    NSArray *animationIcons = @[[[UIImage imageNamed:@"cast-connecting-1-button"]
                                 imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal],
                                [[UIImage imageNamed:@"cast-connecting-2-button"]
                                 imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal],
                                [[UIImage imageNamed:@"cast-connecting-3-button"]
                                 imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    [castButton setInactiveIcon:inactiveIcon activeIcon:activeIcon animationIcons:animationIcons];
    castButton.triggersDefaultCastDialog = NO;
    [castButton addTarget:self action:@selector(openCastDialog) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *chromecastBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:castButton];
    return chromecastBarButtonItem;
}

- (void)openCastDialog {
    [[GCKCastContext sharedInstance] presentCastDialog];
}

@end
