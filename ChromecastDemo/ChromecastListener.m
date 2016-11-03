//
//  ChromecastListener.m
//  ChromecastDemo
//
//  Created by Mary  on 11/3/16.
//  Copyright © 2016 3ss. All rights reserved.
//

#import <GoogleCast/GoogleCast.h>
#import "ChromecastListener.h"

@interface ChromecastListener () <KPCastProviderDelegate>

@end

@implementation ChromecastListener

#pragma mark - Lifecycle
#pragma mark -

- (instancetype)init {
    self = [super init];
    if (self) {
        GCKCastOptions *options = [[GCKCastOptions alloc] initWithReceiverApplicationID:@"276999A7"];
        [GCKCastContext setSharedInstanceWithOptions:options];
        _castProvider = [[GoogleCastProvider alloc] init];
        _castProvider.delegate = self;
        [_castProvider addObserver:self];
        [_castProvider setLogo:[NSURL URLWithString:@"https://www.motortrendondemand.com/wp-content/uploads/2016/08/MTOD_TV_Splash_Image.png"]];
    }
    return self;
}





#pragma mark - KPCastProviderDelegate
#pragma mark - 

- (void)updateProgress:(NSTimeInterval)currentTime {
    //NSLog(@"%@ >> Cast provider has updated progress.", [self class]);
}

- (void)readyToPlay:(NSTimeInterval)streamDuration {
    NSLog(@"%@ >> Cast provider is ready to play.", [self class]);
}

- (void)castPlayerState:(NSString *)state {
    NSLog(@"%@ >> Cast player state == %@", [self class], state);
}

- (void)startCasting {
    NSLog(@"%@ >> Cast provider did start casting.", [self class]);
}

- (void)stopCasting {
    NSLog(@"%@ >> Cast provider did stop casting.", [self class]);
}

@end
