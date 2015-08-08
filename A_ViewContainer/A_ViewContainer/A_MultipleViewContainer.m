//
//  A_ViewBaseContainer.m
//  A_ViewContainer
//
//  Created by Animax Deng on 7/25/15.
//  Copyright (c) 2015 Animax Deng. All rights reserved.
//

#import "A_MultipleViewContainer.h"
#import "A_ViewBaseController.h"

#pragma mark - Controlers manager
@interface A_ControllersManager: NSObject

@property (strong, nonatomic) NSMutableArray *subControllers;

@end

@implementation A_ControllersManager {
    NSInteger _currectIndex;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.subControllers = [[NSMutableArray alloc] init];
        _currectIndex = 0;
    }
    return self;
}

- (A_ViewBaseController *)getNext {
    if (_subControllers.count == 0) return [[A_ViewBaseController alloc] init];
    
    NSInteger index = _currectIndex;
    if (index < _subControllers.count - 1) {
        index++;
    }
    else {
        index = 0;
    }
    return _subControllers[index];
}
- (A_ViewBaseController *)getPrevious {
    if (_subControllers.count == 0) return [[A_ViewBaseController alloc] init];
    
    NSInteger index = _currectIndex;
    if (index > 0) {
        index--;
    }
    else {
        index = _subControllers.count - 1;
    }
    return _subControllers[index];
}
- (A_ViewBaseController *)getCurrent {
    if (_subControllers.count == 0) return [[A_ViewBaseController alloc] init];
    
    if (_currectIndex > _subControllers.count - 1) {
        return _subControllers[0];
    }
    else {
        return [_subControllers objectAtIndex:_currectIndex];
    }
}

- (void)navigateToNext {
    if (_currectIndex < _subControllers.count - 1) {
        _currectIndex++;
    }
    else {
        _currectIndex = 0;
    }
}
- (void)naviageToPrevious {
    if (_currectIndex > 0) {
        _currectIndex--;
    }
    else {
        _currectIndex = _subControllers.count - 1;
    }
}

@end

#pragma mark - Container setting
@implementation A_ContainerSetting {
    A_MultipleViewStyle _style;
}

+ (A_ContainerSetting*)A_DeafultSetting{
    A_ContainerSetting *setting = [[A_ContainerSetting alloc] init];
    setting.scaleOfCurrent = .8f;
    setting.scaleOfEdge = .4f;
    setting.sideDisplacement = 1.0f;
    
    return setting;
}

- (void)addStyle:(A_MultipleViewStyle)style {
    _style |= style;
}
- (void)removeStyle:(A_MultipleViewStyle)style {
    _style &= ~style;
}
- (void)triggerStyle:(A_MultipleViewStyle)style {
    _style ^= style;
}

- (BOOL)hasStyle:(A_MultipleViewStyle)style {
    return _style & style;
}
- (A_MultipleViewStyle)currentStyle {
    return _style;
}


@end

#pragma mark - Multiple View Container
@interface A_MultipleViewContainer () <UIGestureRecognizerDelegate>

@property (strong, nonatomic) A_ControllersManager *controllerManager;
@property (strong, nonatomic) A_ContainerSetting *setting;

@property (atomic) BOOL needsRefresh;

@end

@implementation A_MultipleViewContainer {
    NSLayoutConstraint *_leftPosition;
    NSLayoutConstraint *_centerPosition;
    NSLayoutConstraint *_rightPosition;
    
    UIView *owner;
    
    BOOL _isAnimationRunning;
    BOOL _isSwitching;
    CGPoint _startTouchPoint;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.controllerManager = [[A_ControllersManager alloc] init];
        
        self.clipsToBounds = YES;
        self.layer.masksToBounds = YES;
        _isSwitching = NO;
        _needsRefresh = YES;
    }
    return self;
}

+ (A_MultipleViewContainer *)A_InstallTo:(UIView *)container {
    return [self A_InstallTo:container setting:nil];
}
+ (A_MultipleViewContainer *)A_InstallTo:(UIView *)container setting:(A_ContainerSetting *)setting {
    A_MultipleViewContainer *control = [[A_MultipleViewContainer alloc] init];
    
    if (setting) {
        [control setSetting:[setting copy]];
    } else {
        [control setSetting:[A_ContainerSetting A_DeafultSetting]];
    }
    
    [control setBackgroundColor:[UIColor yellowColor]];
    
    [container addSubview:control];
    
    control.translatesAutoresizingMaskIntoConstraints = NO;
    [control.superview addConstraint:[NSLayoutConstraint constraintWithItem:control attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:control.superview attribute:NSLayoutAttributeTop multiplier:1.0f constant:0.f]];
    [control.superview addConstraint:[NSLayoutConstraint constraintWithItem:control attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:control.superview attribute:NSLayoutAttributeLeft multiplier:1.0f constant:0.f]];
    [control.superview addConstraint:[NSLayoutConstraint constraintWithItem:control attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:control.superview attribute:NSLayoutAttributeRight multiplier:1.0f constant:0.f]];
    [control.superview addConstraint:[NSLayoutConstraint constraintWithItem:control attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:control.superview attribute:NSLayoutAttributeBottom multiplier:1.0f constant:0.f]];
    
    [container layoutIfNeeded];
    
    return control;
}

- (BOOL)A_AddChild:(A_ViewBaseController *)controller {
    if (![controller isKindOfClass:[A_ViewBaseController class]]) { return NO; }
    
    [self.controllerManager.subControllers addObject:controller];
    _needsRefresh = YES;
    return YES;
}
- (BOOL)A_AddChildren:(NSArray *)controllers {
    for (id item in controllers) {
        if (![item isKindOfClass:[A_ViewBaseController class]]) { return NO; }
    }
    
    [self.controllerManager.subControllers addObjectsFromArray:controllers];
    _needsRefresh = YES;
    return YES;
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    if (_needsRefresh) {
        [self A_Display];
    }
}

+ (A_MultipleViewContainer *)A_InstallTo:(UIView *)container controllers:(NSArray *)controllers {
    return [self A_InstallTo:container controllers:controllers setting:nil];
}
+ (A_MultipleViewContainer *)A_InstallTo:(UIView *)container controllers:(NSArray *)controllers setting:(A_ContainerSetting *)setting {
    A_MultipleViewContainer *control = [[A_MultipleViewContainer alloc] init];
    
    if (setting) {
        [control setSetting:[setting copy]];
    } else {
        [control setSetting:[A_ContainerSetting A_DeafultSetting]];
    }
    
    [control setBackgroundColor:[UIColor yellowColor]];
    
    [container addSubview:control];
    
    if (controllers) {
        [control.controllerManager setSubControllers:[[NSMutableArray alloc] initWithArray:controllers]];
    }
    
    control.translatesAutoresizingMaskIntoConstraints = NO;
    [control.superview addConstraint:[NSLayoutConstraint constraintWithItem:control attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:control.superview attribute:NSLayoutAttributeTop multiplier:1.0f constant:0.f]];
    [control.superview addConstraint:[NSLayoutConstraint constraintWithItem:control attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:control.superview attribute:NSLayoutAttributeLeft multiplier:1.0f constant:0.f]];
    [control.superview addConstraint:[NSLayoutConstraint constraintWithItem:control attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:control.superview attribute:NSLayoutAttributeRight multiplier:1.0f constant:0.f]];
    [control.superview addConstraint:[NSLayoutConstraint constraintWithItem:control attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:control.superview attribute:NSLayoutAttributeBottom multiplier:1.0f constant:0.f]];
    
    [container layoutIfNeeded];
    [control A_Display];
    
    return control;
}

#pragma mark - disaplying
- (void) addController: (A_ViewBaseController *)controller {
    [self addSubview:controller.view];
    
    [controller.view setBackgroundColor:[UIColor blueColor]];
    
    controller.view.translatesAutoresizingMaskIntoConstraints = NO;
    [self addConstraint:[NSLayoutConstraint constraintWithItem:controller.view attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1.0f constant:0.f]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:controller.view attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottom multiplier:1.0f constant:0.f]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:controller.view attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeft multiplier:1.0f constant:0.f]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:controller.view attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeRight multiplier:1.0f constant:0.f]];
}
- (void) A_Display {
    _needsRefresh = NO;
    
    [self addController:[_controllerManager getPrevious]];
    [self addController:[_controllerManager getNext]];
    [self addController:[_controllerManager getCurrent]];
    
    [self layoutIfNeeded];
    [_controllerManager getCurrent].view.layer.transform = CATransform3DMakeScale(_setting.scaleOfCurrent, _setting.scaleOfCurrent, 1);
    
    CALayer *previous = [_controllerManager getPrevious].view.layer;
    previous.transform = CATransform3DMakeScale(_setting.scaleOfEdge, _setting.scaleOfEdge, 1);
    previous.anchorPoint = CGPointMake(previous.anchorPoint.x + _setting.sideDisplacement, previous.anchorPoint.y);
    
    CALayer *next = [_controllerManager getNext].view.layer;
    next.transform = CATransform3DMakeScale(_setting.scaleOfEdge, _setting.scaleOfEdge, 1);
    next.anchorPoint = CGPointMake(next.anchorPoint.x - _setting.sideDisplacement, next.anchorPoint.y);
}

#pragma mark - animation methods


#pragma mark - touch event
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    
    CGPoint touchPoint = [[touches anyObject] locationInView: self];
    if ([self pointInEdgeArea:touchPoint]) {
        _startTouchPoint = touchPoint;
        _isSwitching = YES;
    } else {
        _isSwitching = NO;
    }
    
    
    NSLog(@"%@",[NSValue valueWithCGPoint:touchPoint]);
}
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesMoved:touches withEvent:event];
    if (!_isSwitching) return;
    
    CGPoint movingTouchPoint = [[touches anyObject] locationInView: self];
    CGFloat movingDistance = _startTouchPoint.x - movingTouchPoint.x;
    
    if (fabs(movingDistance) < [self getHalfWidth]) return;
    
    if (movingDistance > 0) {
        NSLog(@"right to left");
    } else {
        NSLog(@"left to right");
    }
    
}
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesEnded:touches withEvent:event];
    
    _isSwitching = NO;
}
- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesCancelled:touches withEvent:event];
    
    _isSwitching = NO;
}

#pragma mark - helper methods
- (CGFloat)getCurrentWidth {
    return self.bounds.size.width;
}
- (CGFloat)getHalfWidth {
    return self.bounds.size.width/2.0f;
}
- (CGFloat)getRecognisingEdgeWidth {
    return self.bounds.size.width * 0.1f;
}
- (BOOL)pointInEdgeArea: (CGPoint)point {
    CGFloat height = self.bounds.size.height;
    
    return (point.x <= [self getRecognisingEdgeWidth] || point.x >= ([self getCurrentWidth] - [self getRecognisingEdgeWidth])) &&
        point.y <= height * 0.9f && point.y >= height * 0.1f ;
}

@end




