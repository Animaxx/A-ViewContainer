//
//  A_ViewBaseController.h
//  A_ViewContainer
//
//  Created by Animax Deng on 7/25/15.
//  Copyright (c) 2015 Animax Deng. All rights reserved.
//

#import <UIKit/UIKit.h>

@class A_ContainerSetting;

typedef enum {
    A_ControllerDirectionToLeft         = 0,
    A_ControllerDirectionToRight        = 1,
} A_ControllerDirectionEnum;

@interface A_ViewBaseController : UIViewController

#pragma mark - Override
- (void)A_ViewDidAppearInCenter;

- (NSArray *)A_ExtraCenterToSideAnimation: (A_ContainerSetting *)setting direction:(A_ControllerDirectionEnum)direction;
- (NSArray *)A_ExtraSideToCenterAnimation: (A_ContainerSetting *)setting direction:(A_ControllerDirectionEnum)direction;
- (NSArray *)A_ExtraSideToOutAnimation: (A_ContainerSetting *)setting direction:(A_ControllerDirectionEnum)direction;

@end
