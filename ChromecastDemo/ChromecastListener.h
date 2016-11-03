//
//  ChromecastListener.h
//  ChromecastDemo
//
//  Created by Mary  on 11/3/16.
//  Copyright © 2016 3ss. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <KalturaPlayerSDK/GoogleCastProvider.h>

@protocol ChromecastListenerDelegate <NSObject>

@end

@interface ChromecastListener : NSObject

@property (nonatomic, strong, readonly) GoogleCastProvider *castProvider;
@property (nonatomic, strong) id<ChromecastListenerDelegate> delegate;

@end
