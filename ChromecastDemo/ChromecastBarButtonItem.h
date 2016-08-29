//
//  ChromecastBarButtonItem.h
//  ChromecastDemo
//
//  Created by Mary  on 8/25/16.
//  Copyright © 2016 3ss. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, ChromecastBarButtonItemState) {
    /**
     *  No cast devices available - hide the icon.
     */
    ChromecastBarButtonItemStateCastUnavailable = 0,
    /**
     *  Cast devices discovered.
     */
    ChromecastBarButtonItemStateCastAvailable,
    /**
     *  Currently connecting to a device.
     */
    ChromecastBarButtonItemStateCastConnecting,
    /**
     *  Connected.
     */
    ChromecastBarButtonItemStateCastConnected
};

@interface ChromecastBarButtonItem : UIBarButtonItem

- (instancetype)initWithState:(ChromecastBarButtonItemState)state style:(UIBarButtonItemStyle)style target:(id)target action:(SEL)action;



@end
