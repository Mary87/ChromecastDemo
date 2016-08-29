//
//  ChromecastBarButtonItem.m
//  ChromecastDemo
//
//  Created by Mary  on 8/25/16.
//  Copyright © 2016 3ss. All rights reserved.
//

#import "ChromecastBarButtonItem.h"


@interface ChromecastBarButtonItem ()

@property (nonatomic) ChromecastBarButtonItemState state;

@end

@implementation ChromecastBarButtonItem

- (instancetype)initWithState:(ChromecastBarButtonItemState)state style:(UIBarButtonItemStyle)style target:(id)target action:(SEL)action {
    UIImage *buttonImage = [[UIImage alloc] init];
    switch (state) {
        case ChromecastBarButtonItemStateCastAvailable: {
            buttonImage = [UIImage imageNamed:@"cast-available-button"];
            break;
        }
        case ChromecastBarButtonItemStateCastConnected: {
            buttonImage = [UIImage imageNamed:@"cast-connected-button"];
            break;
        }
        default:
            break;
    }
    ChromecastBarButtonItem *buttonItem = [[ChromecastBarButtonItem alloc] initWithImage:buttonImage style:UIBarButtonItemStylePlain target:target action:action];
    buttonItem.state = state;
    return buttonItem;
}

@end

