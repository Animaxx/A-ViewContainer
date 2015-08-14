//
//  A_ViewBaseController.m
//  A_ViewContainer
//
//  Created by Animax Deng on 7/25/15.
//  Copyright (c) 2015 Animax Deng. All rights reserved.
//

#import "A_ViewBaseController.h"
#import "A_MultipleViewContainer.h"

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

- (UIImage *)capView {
    UIGraphicsBeginImageContext(self.view.frame.size);
    
    [self.view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *outputImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return outputImage;
}

#pragma mark - lift cycle
- (NSArray *)A_ExtraCenterToSideAnimation: (A_ContainerSetting *)setting direction:(A_ControllerDirectionEnum)direction {
    return @[];
}
- (NSArray *)A_ExtraSideToCenterAnimation: (A_ContainerSetting *)setting direction:(A_ControllerDirectionEnum)direction {
    return @[];
}
- (NSArray *)A_ExtraSideToOutAnimation: (A_ContainerSetting *)setting direction:(A_ControllerDirectionEnum)direction {
    return @[];
}

//TODO: Operation for finished animation

#pragma mark - Override
- (void)A_ViewWillAppearInCenter {
    
}
- (void)A_ViewDIdAppearInCenter {
    
}



@end


