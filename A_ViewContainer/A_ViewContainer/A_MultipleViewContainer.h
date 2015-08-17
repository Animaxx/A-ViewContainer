//
//  A_ViewBaseContainer.h
//  A_ViewContainer
//
//  Created by Animax Deng on 7/25/15.
//  Copyright (c) 2015 Animax Deng. All rights reserved.
//

#import <UIKit/UIKit.h>
@class A_ViewBaseController;

typedef NS_OPTIONS(NSUInteger, A_MultipleViewStyle)  {
    A_MultipleViewStyleNothing          = 0,
    A_MultipleViewStyleBounce        = 1 << 1,
    A_MultipleViewStyleBlur             = 1 << 2,
    A_MultipleViewStyleRotate           = 1 << 3,
    A_MultipleViewStyleExplode          = 1 << 4,
};

#pragma mark - Container setting
@interface A_ContainerSetting: NSObject

// Scale the center controller, if set it toz 1.0f means fill cover the view. Default value is .8f
@property (nonatomic) CGFloat scaleOfCurrent;

// Scale the previous and next controller. Default value is .4f
@property (nonatomic) CGFloat scaleOfEdge;

// Displacement of side view, lesser value means closer to the center. Default is 1.0f
@property (nonatomic) CGFloat sideDisplacement;

+ (A_ContainerSetting*)A_DeafultSetting;
- (void)addStyle:(A_MultipleViewStyle)style;
- (void)removeStyle:(A_MultipleViewStyle)style;
- (BOOL)hasStyle:(A_MultipleViewStyle)style;
- (A_MultipleViewStyle)currentStyle;

@end


#pragma mark - Multiple view container
@interface A_MultipleViewContainer : UIView

//+ (A_MultipleViewContainer *)A_InstallTo:(UIView *)container controllers:(NSArray *)controllers;
+ (A_MultipleViewContainer *)A_InstallTo:(UIView *)container;
+ (A_MultipleViewContainer *)A_InstallTo:(UIView *)container setting:(A_ContainerSetting *)setting;

- (BOOL)A_AddChild:(A_ViewBaseController *)controller;
- (BOOL)A_AddChildren:(NSArray *)controllers;

- (void) A_Display;


@end
