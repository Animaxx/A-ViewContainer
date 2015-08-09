//
//  A_ViewBaseController.m
//  A_ViewContainer
//
//  Created by Animax Deng on 7/25/15.
//  Copyright (c) 2015 Animax Deng. All rights reserved.
//

#import "A_ViewBaseController.h"

@interface A_ViewBaseController ()

@end

@implementation A_ViewBaseController {
    BOOL _isInvisible;
}

- (void)viewDidLoad {
    [super viewDidLoad];
}


- (void)setInvisible:(BOOL)state withAnimation:(BOOL)animation {
    if (_isInvisible == state) {
        return;
    }
    
    _isInvisible = state;
    if (_isInvisible) {
        if (animation) {
            [UIView animateWithDuration:0.5f animations:^{
                [self.view setAlpha:0.0f];
            }];
        } else {
            [self.view setAlpha: 0.0f];
        }
    } else {
        if (animation) {
            [UIView animateWithDuration:0.5f animations:^{
                [self.view setAlpha:1.0f];
            }];
        } else {
            [self.view setAlpha: 1.0f];
        }
        
    }
}


@end
