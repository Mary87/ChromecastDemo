//
//  KalturaPlayerAdapterDelegate.h
//  ChromecastDemo
//
//  Created by Mary  on 8/25/16.
//  Copyright © 2016 3ss. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ChromecastBarButtonItem.h"

@protocol KalturaPlayerAdapterDelegate <NSObject>

@required

- (void)playerAdapterDidPlayToEnd;
- (void)playerAdapterDidPause;
- (void)playerAdapterDidResume;
- (void)updateWithChromecastBarButton:(ChromecastBarButtonItem *)chromecastBarButton;
- (void)displayDeviceListAlertViewController:(UIAlertController *)deviceList;

@end
