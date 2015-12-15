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
    A_MultipleViewStyleBounce           = 1 << 1,
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

// Transparence of side view. Default is 0.5f
@property (nonatomic) CGFloat sideTransparence;

+ (A_ContainerSetting*)A_DeafultSetting;

- (BOOL)hasStyle:(A_MultipleViewStyle)style;
- (A_MultipleViewStyle)currentStyle;

@end


#pragma mark - Multiple view container
@interface A_MultipleViewContainer : UIView

@property (readonly, strong, nonatomic) A_ContainerSetting *setting;
@property (readonly, strong, nonatomic) NSArray<A_ViewBaseController *> *subControlers;

//+ (A_MultipleViewContainer *)A_InstallTo:(UIView *)container controllers:(NSArray *)controllers;
+ (A_MultipleViewContainer *)A_InstallTo:(UIView *)container;
+ (A_MultipleViewContainer *)A_InstallTo:(UIView *)container setting:(A_ContainerSetting *)setting;

- (A_ViewBaseController *)A_GetCurrentController;
- (A_ViewBaseController *)A_GetNextController;
- (A_ViewBaseController *)A_GetPreviousController;

- (BOOL)A_AddChild:(A_ViewBaseController *)controller;
- (BOOL)A_AddChildren:(NSArray *)controllers;
- (BOOL)A_RemoveChild:(A_ViewBaseController *)controller;

- (void)A_Display;
- (void)A_CleanAllSwitchedEvents;
- (void)A_CleanAllControllers;

- (void)A_AddSwitchedEvent:(SEL)selector owner:(id)selOwner;
- (void)A_RemoveSwitchedEvent:(id)selOwner;


@end
