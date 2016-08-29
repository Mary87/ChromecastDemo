//
//  KalturaPlayerAdapter.h
//  ChromecastDemo
//
//  Created by Mary  on 8/25/16.
//  Copyright © 2016 3ss. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <KALTURAPlayerSDK/KPViewController.h>
#import "KalturaPlayerAdapterDelegate.h"

@interface KalturaPlayerAdapter : NSObject

@property (nonatomic, weak) id<KalturaPlayerAdapterDelegate> delegate;

- (instancetype)initWithRenderingView:(UIView *)renderingView;
- (void)playVideoWithIdentifier:(NSString *)videoIdentifier;

@end
