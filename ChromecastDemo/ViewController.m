//
//  ViewController.m
//  ChromecastDemo
//
//  Created by Mary  on 8/25/16.
//  Copyright © 2016 3ss. All rights reserved.
//

#import "ViewController.h"
#import "KalturaPlayerAdapter.h"

@interface ViewController () <KalturaPlayerAdapterDelegate>

@property (weak, nonatomic) IBOutlet UIView *playerPlaceholderView;
@property (weak, nonatomic) IBOutlet UINavigationBar *navigationBar;
@property (nonatomic, strong) KalturaPlayerAdapter *playerAdapter;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _playerAdapter = [[KalturaPlayerAdapter alloc] initWithRenderingView:self.playerPlaceholderView];
    self.playerAdapter.delegate = self;
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
    [self.playerAdapter playVideoWithIdentifier:vidoeIdentifier];
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}



#pragma mark - KalturaPlayerAdapterDelegate
#pragma mark -

- (void)updateWithChromecastBarButton:(ChromecastBarButtonItem *)chromecastBarButton {
    chromecastBarButton.imageInsets = UIEdgeInsetsMake(0, 10, 0, -10);
    UINavigationItem *navItem = self.navigationBar.items.firstObject;
    [navItem setRightBarButtonItem:chromecastBarButton];
    [navItem setTitle:@"Chromecast Demo App"];
}


- (void)displayDeviceListAlertViewController:(UIAlertController *)deviceList {
    [self presentViewController:deviceList animated:YES completion:nil];
}

- (void)playerAdapterDidPlayToEnd {
    
}

- (void)playerAdapterDidPause {
    
}

- (void)playerAdapterDidResume {
    
}

@end
