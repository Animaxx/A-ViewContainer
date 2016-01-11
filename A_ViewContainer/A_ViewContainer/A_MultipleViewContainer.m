//
//  A_ViewBaseContainer.m
//  A_ViewContainer
//
//  Created by Animax Deng on 7/25/15.
//  Copyright (c) 2015 Animax Deng. All rights reserved.
//

#import "A_MultipleViewContainer.h"
#import "A_ViewBaseController.h"


typedef enum {
    _containerOperationType_noOperation = 0,
    _containerOperationType_moveToNext,
    _containerOperationType_moveToPrevious,
} _containerOperationType;

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

- (int)count {
    return (int)_subControllers.count;
}

- (A_ViewBaseController *)getAfterNext {
    if (_subControllers.count == 0) return [[A_ViewBaseController alloc] init];
    
    NSInteger index = _currectIndex;
    if (index < _subControllers.count - 2) {
        index+=2;
    }
    else {
        if (index < _subControllers.count - 1) {
            index = 1;
        } else if (_subControllers.count >= 2) {
            index = 2;
        } else {
            //TODO: after next
            return [[A_ViewBaseController alloc] init];
        }
    }
    return _subControllers[index];
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
- (A_ViewBaseController *)getAfterPrevious {
    if (_subControllers.count == 0) return [[A_ViewBaseController alloc] init];
    
    NSInteger index = _currectIndex;
    if (index > 1) {
        index-=2;
    }
    else if (_subControllers.count > 2) {
        index = _subControllers.count - 2;
    } else {
        //TODO: get after previous
        return [[A_ViewBaseController alloc] init];
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

- (CALayer *)getAfterNextLayer {
    return [self getAfterNext].view.layer;
}
- (CALayer *)getNextLayer {
    return [self getNext].view.layer;
}
- (CALayer *)getPreviousLayer {
    return [self getPrevious].view.layer;
}
- (CALayer *)getAfterPreviousLayer {
    return [self getAfterPrevious].view.layer;
}
- (CALayer *)getCurrentLayer {
    return [self getCurrent].view.layer;
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

- (BOOL)removeController: (A_ViewBaseController *)controller {
    if ([self.subControllers containsObject:controller]) {
        A_ViewBaseController *current = [self getCurrent];
        if (controller == current) {
            _currectIndex = 0;
            [self.subControllers removeObject:controller];
        } else {
            [self.subControllers removeObject:controller];
            _currectIndex = [self.subControllers indexOfObject:current];
        }
        
        return YES;
    } else {
        return NO;
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
    setting.sideTransparence = 0.5f;
    setting.enableInCardRecognizer = YES;
    
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
@interface A_ViewBaseController()

- (void)setInvisible:(BOOL)state withAnimation:(BOOL)animation;

- (NSDictionary *)centerToSideAttributes: (A_ContainerSetting *)setting direction:(A_ControllerDirectionEnum)direction;
- (NSDictionary *)sideToCenterAttributes: (A_ContainerSetting *)setting direction:(A_ControllerDirectionEnum)direction;
- (NSDictionary *)sideToOutAttributes: (A_ContainerSetting *)setting direction:(A_ControllerDirectionEnum)direction;

@end


@interface multipleContainerSelectorModel: NSObject

@property (weak, nonatomic) id selOwner;
@property (assign, nonatomic) SEL selector;

@end

@implementation multipleContainerSelectorModel

+ (multipleContainerSelectorModel *)crate:(id)owner sel:(SEL)sel {
    multipleContainerSelectorModel *model = [[multipleContainerSelectorModel alloc] init];
    model.selOwner = owner;
    model.selector = sel;
    return model;
}

@end


#pragma mark - Multiple View Container
@interface A_MultipleViewContainer () <UIGestureRecognizerDelegate>

@property (strong, nonatomic) A_ControllersManager *controllerManager;
@property (strong, nonatomic) A_ContainerSetting *setting;

@property (atomic) BOOL needsRefresh;

@property (nonatomic, retain) UIColor *fillColor;
@property (nonatomic, retain) NSArray *framesToCutOut;

@end



@implementation A_MultipleViewContainer {
    NSLayoutConstraint *_leftPosition;
    NSLayoutConstraint *_centerPosition;
    NSLayoutConstraint *_rightPosition;
    
    UIView *owner;
    
    // TODO: get rid of animationRuning boolean
    BOOL _isAnimationRunning;
    BOOL _isSwitching;
    CGPoint _startTouchPoint;
    _containerOperationType _currentOperation;
    
    CADisplayLink *reverseDisplaylink;
    CADisplayLink *forwardDisplaylink;
    
    NSMutableDictionary *_cacheAnimationAttributes;
    NSMutableDictionary *_switchedCallbackSelector;
    
    NSMutableArray <multipleContainerSelectorModel *>* _selectors;
    
    UISwipeGestureRecognizer *swipeRightRecognizer;
    UISwipeGestureRecognizer *swipeLeftRecognizer;
}

@dynamic subControlers;

- (NSArray<A_ViewBaseController *> *)subControlers {
    return self.controllerManager.subControllers;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self commonInit];
    }
    return self;
}
- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        [self commonInit];
    }
    return self;
}
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    return self;
}

//- (void)awakeFromNib {
//    [super awakeFromNib];
//}
- (void)dealloc {
    if (reverseDisplaylink) {
        [reverseDisplaylink invalidate];
        reverseDisplaylink = nil;
    }
    
    if (forwardDisplaylink) {
        [forwardDisplaylink invalidate];
        forwardDisplaylink = nil;
    }
}

- (void)A_CleanAllSwitchedEvents {
    [_selectors removeAllObjects];
}
- (void)A_CleanAllControllers {
    [self.controllerManager.subControllers removeAllObjects];
    
    self.controllerManager = nil;
    self.controllerManager = [[A_ControllersManager alloc] init];
}

- (void)commonInit {
    self.controllerManager = [[A_ControllersManager alloc] init];
    _selectors = [[NSMutableArray alloc] init];
    
    self.clipsToBounds = YES;
    self.layer.masksToBounds = YES;
    _isSwitching = NO;
    _needsRefresh = YES;
    _currentOperation = _containerOperationType_noOperation;
    _cacheAnimationAttributes = [[NSMutableDictionary alloc] init];
    _switchedCallbackSelector = [[NSMutableDictionary alloc] init];
    _setting = [A_ContainerSetting A_DeafultSetting];
    
    [self setBackgroundColor:[UIColor clearColor]];
}

- (void)handleSwipeRight:(UISwipeGestureRecognizer *)gestureRecognizer {
    if (_isSwitching) return;
    [self moveToPrevious];
    [self forwardAnimation];
}
- (void)handleSwipeLeft:(UISwipeGestureRecognizer *)gestureRecognizer {
    if (_isSwitching) return;
    [self moveToNext];
    [self forwardAnimation];
}

+ (A_MultipleViewContainer *)A_InstallTo:(UIView *)container {
    return [self A_InstallTo:container setting:nil];
}
+ (A_MultipleViewContainer *)A_InstallTo:(UIView *)container setting:(A_ContainerSetting *)setting {
    A_MultipleViewContainer *control = [[A_MultipleViewContainer alloc] init];
    
    if (setting) {
        [control setSetting:setting];
    }
    
    [container insertSubview:control atIndex:0];
    
    control.translatesAutoresizingMaskIntoConstraints = NO;
    [control.superview addConstraint:[NSLayoutConstraint constraintWithItem:control attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:control.superview attribute:NSLayoutAttributeTop multiplier:1.0f constant:0.f]];
    [control.superview addConstraint:[NSLayoutConstraint constraintWithItem:control attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:control.superview attribute:NSLayoutAttributeLeft multiplier:1.0f constant:0.f]];
    [control.superview addConstraint:[NSLayoutConstraint constraintWithItem:control attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:control.superview attribute:NSLayoutAttributeRight multiplier:1.0f constant:0.f]];
    [control.superview addConstraint:[NSLayoutConstraint constraintWithItem:control attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:control.superview attribute:NSLayoutAttributeBottom multiplier:1.0f constant:0.f]];
    
    [container layoutIfNeeded];
    
    return control;
}

- (A_ViewBaseController *)A_GetCurrentController {
    return [self.controllerManager getCurrent];
}
- (A_ViewBaseController *)A_GetNextController {
    A_ViewBaseController *next = [self.controllerManager getNext];
    A_ViewBaseController *current = [self.controllerManager getCurrent];
    
    if (current == next) {
        return nil;
    } else {
        return next;
    }
}
- (A_ViewBaseController *)A_GetPreviousController {
    A_ViewBaseController *next = [self.controllerManager getNext];
    A_ViewBaseController *previous = [self.controllerManager getPrevious];
    
    if (previous == next) {
        return nil;
    } else {
        return previous;
    }
}

- (BOOL)A_AddChild:(A_ViewBaseController *)controller {
    if (!controller || ![controller isKindOfClass:[A_ViewBaseController class]]) { return NO; }
    
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
- (BOOL)A_RemoveChild:(A_ViewBaseController *)controller {
    if (![controller isKindOfClass:[A_ViewBaseController class]]) { return NO; }
    
    return [self.controllerManager removeController:controller];
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    if (_needsRefresh) {
        [self A_Display];
    }
}

- (void)A_AddSwitchedEvent:(SEL)selector owner:(id)selOwner{
    [_selectors addObject:[multipleContainerSelectorModel crate:selOwner sel:selector]];
}
- (void)A_RemoveSwitchedEvent:(id)selOwner {
    NSMutableArray <multipleContainerSelectorModel *>* newevents = [[NSMutableArray alloc] init];
    
    for (multipleContainerSelectorModel *item in _selectors) {
        if (item && item.selOwner && ![item.selOwner isEqual:selOwner]) {
            [newevents addObject:item];
        }
    }
    
    _selectors = nil;
    _selectors = newevents;
}

#pragma mark - disaplying
- (void)addController: (A_ViewBaseController *)controller underCurrentView:(BOOL)under{
    if (under) {
        [self insertSubview:controller.view belowSubview:[_controllerManager getCurrent].view];
    } else {
        [self addSubview:controller.view];
    }
    
    controller.view.translatesAutoresizingMaskIntoConstraints = NO;
    [self addConstraint:[NSLayoutConstraint constraintWithItem:controller.view attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1.0f constant:0.f]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:controller.view attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottom multiplier:1.0f constant:0.f]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:controller.view attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeft multiplier:1.0f constant:0.f]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:controller.view attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeRight multiplier:1.0f constant:0.f]];
}
- (void)A_Display {
    _needsRefresh = NO;
    
    for (UIView *item in self.subviews) {
        [item removeFromSuperview];
    }
    
    if ([_controllerManager count] >= 3) {
        [self addController:[_controllerManager getPrevious] underCurrentView:YES];

        CALayer *previous = [_controllerManager getPreviousLayer];
        [self setAttributes:[[_controllerManager getPrevious] centerToSideAttributes:_setting direction:A_ControllerDirectionToLeft] to:previous];
    }
    if ([_controllerManager count] >= 2) {
        [self addController:[_controllerManager getNext] underCurrentView:YES];
        
        CALayer *next = [_controllerManager getNextLayer];
        [self setAttributes:[[_controllerManager getNext] centerToSideAttributes:_setting direction:A_ControllerDirectionToRight] to:next];
    }
    if ([_controllerManager count] >= 1) {
        [self addController:[_controllerManager getCurrent] underCurrentView:NO];
        
        [self bringSubviewToFront:[_controllerManager getCurrent].view];
        
        [_controllerManager getCurrent].view.layer.transform = CATransform3DMakeScale(_setting.scaleOfCurrent, _setting.scaleOfCurrent, 1);
    }
    
    [self layoutIfNeeded];
    
    [self callSwitchedEvents];
}

#pragma mark - animation methods
- (void)moveToNext {
    if ([_controllerManager count] <= 1) return;
    
    _currentOperation = _containerOperationType_moveToNext;
    
    // Bring the next view to the front
    [self bringSubviewToFront:[_controllerManager getNext].view];
    
    // Next to center animation
    CALayer *next = [_controllerManager getNextLayer];
    [self setAnimationAttributes:[[_controllerManager getNext] sideToCenterAttributes:_setting direction:A_ControllerDirectionToLeft] to:next forKey:@"nextToCenterAnimation"];
    
    next.speed = .0f;
    
    // Center to previous
    CALayer *current = [_controllerManager getCurrentLayer];
    if ([_controllerManager count] > 2) {
        [self setAnimationAttributes:[[_controllerManager getCurrent] centerToSideAttributes:_setting direction:A_ControllerDirectionToLeft] to:current forKey:@"centerToPreviousAnimation"];
    } else {
        [self setAnimationAttributes:[[_controllerManager getCurrent] sideToOutAttributes:_setting direction:A_ControllerDirectionToLeft] to:current forKey:@"centerToPreviousAnimation"];
    }
    
    current.speed = .0f;
    
    if ([_controllerManager count] > 2) {
        // Previous out
        CALayer *previous = [_controllerManager getPreviousLayer];
        [self setAnimationAttributes:[[_controllerManager getPrevious] sideToOutAttributes:_setting direction:A_ControllerDirectionToLeft] to:previous forKey:@"previousOutAnimation"];
        previous.speed = .0f;
    }
}
- (void)moveToPrevious {
    if ([_controllerManager count] <= 2) return;
    
    _currentOperation = _containerOperationType_moveToPrevious;
    
    // Bring the next view to the front
    [self bringSubviewToFront:[_controllerManager getPrevious].view];
    
    // Previous to center animation
    CALayer *previous = [_controllerManager getPreviousLayer];
    [self setAnimationAttributes:[[_controllerManager getPrevious] sideToCenterAttributes:_setting direction:A_ControllerDirectionToRight] to:previous forKey:@"previousToCenterAnimation"];

    // Center to next
    CALayer *current = [_controllerManager getCurrentLayer];
    [self setAnimationAttributes:[[_controllerManager getCurrent] centerToSideAttributes:_setting direction:A_ControllerDirectionToRight] to:current forKey:@"centerToNextAnimation"];

    // Next out
    CALayer *next = [_controllerManager getNextLayer];
    [self setAnimationAttributes:[[_controllerManager getNext] sideToOutAttributes:_setting direction:A_ControllerDirectionToRight] to:next forKey:@"nextOutAnimation"];
    
    // change to speed
    next.speed = .0f;
    current.speed = .0f;
    previous.speed = .0f;
}

// Reverset Animations
- (void)reverseAnimation {
    [self clearDisplayLink:NO];
    [self bringSubviewToFront:[_controllerManager getCurrent].view];
    
    reverseDisplaylink = [CADisplayLink displayLinkWithTarget:self selector:@selector(reversingAnimation:)];
    [reverseDisplaylink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
}
- (void)reversingAnimation:(CADisplayLink *)link {
    CALayer *next = [_controllerManager getNextLayer];
    CALayer *current = [_controllerManager getCurrentLayer];
    CALayer *previous = [_controllerManager getPreviousLayer];
    
    if (next.timeOffset <= 0.03 && current.timeOffset <= 0.03 && previous.timeOffset <= 0.03 ) {
        [self clearDisplayLink:YES];
    }
    
    if (next.timeOffset > 0.034) {
        next.timeOffset -= 0.034;
    } else {
        next.timeOffset = .0f;
    }
    if (current.timeOffset > 0.034) {
        current.timeOffset -= 0.034;
    } else {
        current.timeOffset = .0f;
    }
    if (previous.timeOffset > 0.034) {
        previous.timeOffset -= 0.034;
    }else {
        previous.timeOffset = .0f;
    }
}

// Forard Animations
- (void)forwardAnimation {
    [self clearDisplayLink:NO];
    
    forwardDisplaylink = [CADisplayLink displayLinkWithTarget:self selector:@selector(forwardingAnimation:)];
    [forwardDisplaylink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
}
- (void)forwardingAnimation:(CADisplayLink *)link {
    CALayer *next = [_controllerManager getNextLayer];
    CALayer *current = [_controllerManager getCurrentLayer];
    CALayer *previous = [_controllerManager getPreviousLayer];
    
    if (next.timeOffset >= 1.0 && current.timeOffset >= 1.0 && previous.timeOffset >= 1.0 ) {
        [self animationFinished];
    }
    
    if (next.timeOffset < 1.0f) {
        next.timeOffset += 0.1;
    } else {
        next.timeOffset = 1.0f;
    }
    if (current.timeOffset < 1.0f) {
        current.timeOffset += 0.1;
    } else {
        current.timeOffset = 1.0f;
    }
    if (previous.timeOffset < 1.0f) {
        previous.timeOffset += 0.1;
    }else {
        previous.timeOffset = 1.0f;
    }
}

// clear manual animation
- (void)clearDisplayLink:(BOOL)removeAnimation {
    if (reverseDisplaylink) {
        [reverseDisplaylink invalidate];
        reverseDisplaylink = nil;
        _currentOperation = _containerOperationType_noOperation;
    }
    if (forwardDisplaylink) {
        [forwardDisplaylink invalidate];
        forwardDisplaylink = nil;
        _currentOperation = _containerOperationType_noOperation;
    }
    
    if (removeAnimation) {
        [[_controllerManager getNextLayer] removeAllAnimations];
        [[_controllerManager getCurrentLayer] removeAllAnimations];
        [[_controllerManager getPreviousLayer] removeAllAnimations];
        
        [_controllerManager getNextLayer].timeOffset = 0.0f;
        [_controllerManager getCurrentLayer].timeOffset = 0.0f;
        [_controllerManager getPreviousLayer].timeOffset = 0.0f;
        
        [_controllerManager getNextLayer].speed = 1.0f;
        [_controllerManager getCurrentLayer].speed = 1.0f;
        [_controllerManager getPreviousLayer].speed = 1.0f;
    }
}
- (void)animationFinished {
    switch (_currentOperation) {
        case _containerOperationType_moveToNext: {
            // Stop next to center animation
            [self setFinalAttributes:[[_controllerManager getNext] sideToCenterAttributes:_setting direction:A_ControllerDirectionToLeft] to: [_controllerManager getNextLayer] forKey:@"nextToCenterAnimation"];

            
            // Stop center to previous animation
            if ([_controllerManager count] > 2) {
                [self setFinalAttributes:[[_controllerManager getCurrent] centerToSideAttributes:_setting direction:A_ControllerDirectionToLeft] to: [_controllerManager getCurrentLayer] forKey:@"centerToPreviousAnimation"];
                
                // Stop previous out animation
                [self setFinalAttributes:[[_controllerManager getPrevious] sideToOutAttributes:_setting direction:A_ControllerDirectionToLeft] to: [_controllerManager getPreviousLayer] forKey:@"previousOutAnimation"];
                ;
                
                // Removes previous
                A_ViewBaseController *outPrevious = [_controllerManager getPrevious];
                [outPrevious.view removeFromSuperview];
            }
            
            // Bring new next controller
            [[_controllerManager getCurrent] A_ViewDidMoveToSide];
            
            [_controllerManager navigateToNext];
            [self addController:[_controllerManager getNext] underCurrentView:YES];
            [self clearDisplayLink:YES];
            
            [[_controllerManager getCurrent] A_ViewDidAppearInCenter];
             
            CALayer *newNextLayer = [_controllerManager getNextLayer];
            [self setAttributes:[[_controllerManager getNext] sideToOutAttributes:_setting direction:A_ControllerDirectionToRight] to:newNextLayer];
            
            [CATransaction begin]; {
                [CATransaction setCompletionBlock:^{
                    [self setFinalAttributes:[[_controllerManager getNext] centerToSideAttributes:_setting direction:A_ControllerDirectionToRight] to: newNextLayer forKey:@"newNextAnimation"];
                }];
                
                [self setAnimationAttributes:[[_controllerManager getNext] centerToSideAttributes:_setting direction:A_ControllerDirectionToRight] to:newNextLayer forKey:@"newNextAnimation"];
                newNextLayer.speed = 6.0f;
            }
            [CATransaction commit];
        }
            break;
        case _containerOperationType_moveToPrevious: {
            // Stop previous to center animation
            [self setFinalAttributes:[[_controllerManager getPrevious] sideToCenterAttributes:_setting direction:A_ControllerDirectionToRight] to: [_controllerManager getPreviousLayer] forKey:@"previousToCenterAnimation"];
            
            // Stop center to previous animation
            [self setFinalAttributes:[[_controllerManager getCurrent] centerToSideAttributes:_setting direction:A_ControllerDirectionToRight] to: [_controllerManager getCurrentLayer] forKey:@"centerToPreviousAnimation"];
            
            // Stop next out animation
            [self setFinalAttributes:[[_controllerManager getNext] centerToSideAttributes:_setting direction:A_ControllerDirectionToRight] to: [_controllerManager getNextLayer] forKey:@"nextOutAnimation"];
            
            // Remove next
            A_ViewBaseController *outNext = [_controllerManager getNext];
            [outNext.view removeFromSuperview];

            
            // Bring new previous controller
            [[_controllerManager getCurrent] A_ViewDidMoveToSide];
            
            [_controllerManager naviageToPrevious];
            [self addController:[_controllerManager getPrevious] underCurrentView:YES];
            [self clearDisplayLink:YES];
            
            [[_controllerManager getCurrent] A_ViewDidAppearInCenter];
            
            CALayer *newPreviousLayer = [_controllerManager getPreviousLayer];
            [self setAttributes:[[_controllerManager getPrevious] sideToOutAttributes:_setting direction:A_ControllerDirectionToLeft] to:newPreviousLayer];
            
            [CATransaction begin]; {
                [CATransaction setCompletionBlock:^{
                    [self setFinalAttributes:[[_controllerManager getPrevious] centerToSideAttributes:_setting direction:A_ControllerDirectionToLeft] to: newPreviousLayer forKey:@"newPreviousAnimation"];
                }];

                [self setAnimationAttributes:[[_controllerManager getPrevious] centerToSideAttributes:_setting direction:A_ControllerDirectionToLeft] to:newPreviousLayer forKey:@"newPreviousAnimation"];
                newPreviousLayer.speed = 6.0f;
            }
            [CATransaction commit];
            
        }
            break;
        default:
            break;
    }
    
    [self callSwitchedEvents];
}

- (void)callSwitchedEvents {
    [[_controllerManager getPrevious].view removeGestureRecognizer:swipeRightRecognizer];
    [[_controllerManager getPrevious].view removeGestureRecognizer:swipeLeftRecognizer];
    [[_controllerManager getNext].view removeGestureRecognizer:swipeRightRecognizer];
    [[_controllerManager getNext].view removeGestureRecognizer:swipeLeftRecognizer];
    
    if (!swipeRightRecognizer) {
        swipeRightRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeRight:)];
        swipeRightRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
    }
    [[_controllerManager getCurrent].view addGestureRecognizer:swipeRightRecognizer];
    
    if (!swipeLeftRecognizer) {
        swipeLeftRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeLeft:)];
        swipeLeftRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
    }
    [[_controllerManager getCurrent].view addGestureRecognizer:swipeLeftRecognizer];
    
    // Call the switched event
    for (multipleContainerSelectorModel *item in _selectors) {
        if (item.selOwner && [item.selOwner respondsToSelector:item.selector]) {
            [item.selOwner performSelector:item.selector withObject:self];
        }
    }
}

#pragma mark -

#pragma mark - touch event
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    
    CGPoint touchPoint = [[touches anyObject] locationInView: self];
    
    int touchPosition = [self pointInEdgeArea:touchPoint];
    if (touchPosition == 1 || touchPosition == 2) {
        _startTouchPoint = touchPoint;
        _isSwitching = YES;
        [self clearDisplayLink:YES];
        if (touchPosition == 1) {
            [self moveToPrevious];
        }
        if (touchPosition == 2) {
            [self moveToNext];
        }
    } else {
        _isSwitching = NO;
    }
}
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesMoved:touches withEvent:event];
    if (!_isSwitching) return;

    CGFloat movingDistance = fabs(_startTouchPoint.x - [[touches anyObject] locationInView: self].x);
    if (movingDistance <=0) return;
    
    CGFloat halfWidth = [self getHalfWidth];
//    if (movingDistance > halfWidth) {
//        [self forwardAnimation];
//        _isSwitching = NO;
//        return;
//    }
    
    CALayer *next = [_controllerManager getNextLayer];
    CALayer *current = [_controllerManager getCurrentLayer];
    CALayer *previous = [_controllerManager getPreviousLayer];
    
    CGFloat progress = movingDistance / halfWidth; // (halfWidth + [self getQuarterWidth]);
    
    next.timeOffset = progress;
    current.timeOffset = progress;
    previous.timeOffset = progress;
    
}
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesEnded:touches withEvent:event];
    if (!_isSwitching) return;
    
    CGFloat movingDistance = fabs(_startTouchPoint.x - [[touches anyObject] locationInView: self].x);
    
    if (movingDistance > [self getQuarterWidth]) {
        [self forwardAnimation];
    } else {
        [self reverseAnimation];
    }
    _isSwitching = NO;
}
- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesCancelled:touches withEvent:event];
    if (!_isSwitching) return;
    
    [self reverseAnimation];
    _isSwitching = NO;
}

#pragma mark - helper methods
- (CGFloat)getCurrentWidth {
    return self.bounds.size.width;
}
- (CGFloat)getHalfWidth {
    return self.bounds.size.width/2.0f;
}
- (CGFloat)getQuarterWidth {
    return self.bounds.size.width/8.0f;
}
- (CGFloat)getRecognisingEdgeWidth {
    return self.bounds.size.width * 0.1f;
}

- (void)setAnimationAttributes:(NSDictionary *)dictionary to:(CALayer *)layer forKey:(NSString *)key {
    [_cacheAnimationAttributes setObject:dictionary forKey:key];
    
    NSMutableArray *animations = [[NSMutableArray alloc] init];
    
    CAAnimationGroup *animationGroup = [CAAnimationGroup animation];
    animationGroup.beginTime = 0.0f;
    animationGroup.duration = 1.0f;
    animationGroup.fillMode = kCAFillModeBoth;
    animationGroup.removedOnCompletion = YES;
    
    if ([_setting hasStyle:A_MultipleViewStyleBounce]) {
        for (NSString *key in dictionary) {
            CAKeyframeAnimation *animationItem = [self getBounceAnimation:key Duration:1.0f Start:[layer valueForKeyPath:key] End:[dictionary objectForKey:key]];
            animationItem.additive = NO;
            [animations addObject:animationItem];
        }
    } else {
        for (NSString *key in dictionary) {
            CABasicAnimation *animationItem = [CABasicAnimation animationWithKeyPath:key];
            animationItem.toValue = [dictionary objectForKey:key];
            animationItem.additive = NO;
            [animations addObject:animationItem];
        }
    }
    
    animationGroup.animations = animations;
    [layer addAnimation:animationGroup forKey:key];
}
- (void)setFinalAttributes:(NSDictionary *)dictionary to:(CALayer *)layer forKey:(NSString *)key {
    [self setAttributes:dictionary to:layer];
    [layer removeAnimationForKey:key];
}
- (void)setAttributes:(NSDictionary *)dictionary to:(CALayer *)layer {
    for (NSString *key in dictionary) {
        [layer setValue:[dictionary objectForKey:key] forKeyPath:key];
    }
}

// return 1 - touching in left; 2 - touching in right;
- (int)pointInEdgeArea: (CGPoint)point {
    CGFloat height = self.bounds.size.height;
    
    if (point.y <= height * 0.8f && point.y >= height * 0.2f) {
        if (point.x <= [self getRecognisingEdgeWidth]) {
            return 1;
        } else if ( point.x >= ([self getCurrentWidth] - [self getRecognisingEdgeWidth]) ){
            return 2;
        }
    }
    return 0;
//    return (point.x <= [self getRecognisingEdgeWidth] || point.x >= ([self getCurrentWidth] - [self getRecognisingEdgeWidth])) &&
//        point.y <= height * 0.9f && point.y >= height * 0.1f ;
}

#pragma mark - Bounce animation
// From A_Animation in A_IOSHelper project
typedef double(^viewContainerKeyframeCalculatingBlock)(double t, double b, double c, double d);
-(CAKeyframeAnimation*)getBounceAnimation:(NSString*)keypath Duration:(double)duration Start:(id)start End:(id)end {
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:keypath];
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    animation.duration = duration;
    NSInteger steps = duration * 60; /* FPS */
    
    if ([start isKindOfClass:NSNumber.class] && [end isKindOfClass:NSNumber.class]) {
        animation.values = [self _getFloatValues:steps Start:[start doubleValue] End:[end doubleValue]];
    } else if (CFGetTypeID((__bridge CFTypeRef)start) == CGColorGetTypeID()) {
        CGColorRef endColor;
        if ([end isKindOfClass:[UIColor class]]) {
            endColor = ((UIColor*)end).CGColor;
        } else {
            endColor = (__bridge CGColorRef)end;
        }
        animation.values = [self _getColorValues:steps Start:(CGColorRef)start End:endColor];
    } else if (([start isKindOfClass:NSValue.class] && [end isKindOfClass:NSValue.class]) && strcmp([start objCType], [end  objCType]) == 0) {
        if (strcmp([start objCType], @encode(CATransform3D)) == 0) {
            animation.values = [self _getCATransform3DValues:steps Start:[start CATransform3DValue] End:[end CATransform3DValue]];
        }
        if (strcmp([start objCType], @encode(CGRect)) == 0) {
            animation.values = [self _getRectValues:steps Start:[start CGRectValue] End:[end CGRectValue]];
        }
        if (strcmp([start objCType], @encode(CGPoint)) == 0) {
            animation.values = [self _getPointValues:steps Start:[start CGPointValue] End:[end CGPointValue]];
        }
        if (strcmp([start objCType], @encode(CGSize)) == 0) {
            animation.values = [self _getSizeValues:steps Start:[start CGSizeValue] End:[end CGSizeValue]];
        }
    }
    return animation;
}

-(viewContainerKeyframeCalculatingBlock)_keyframeBlock {
    return ^double(double t, double b, double c, double d) {
        if ((t/=d) < (1/2.75)) {
            return c*(7.5625*t*t) + b;
        } else if (t < (2/2.75)) {
            t-=(1.5/2.75);
            return c*(7.5625*t*t + .75) + b;
        } else if (t < (2.5/2.75)) {
            t-=(2.25/2.75);
            return c*(7.5625*t*t + .9375) + b;
        } else {
            t-=(2.625/2.75);
            return c*(7.5625*t*t + .984375) + b;
        }
    };
}
-(NSArray*)_getFloatValues:(NSInteger)steps Start:(CGFloat)start End:(CGFloat)end {
    viewContainerKeyframeCalculatingBlock _calculatingBlock = [self _keyframeBlock];
    NSMutableArray* _values = [[NSMutableArray alloc] initWithCapacity:steps];
    
    double _v = 0.0;
    for (int i=0; i<steps; i++) {
        _v = _calculatingBlock((double)(steps * 1.0 / (double)(steps) * i), 0.0, 100.0, (double)steps);
        [_values addObject:@(start + (_v / 100.0) * (end - start))];
    }
    
    return _values;
}
-(NSArray*)_getPointValues:(NSInteger)steps Start:(CGPoint)start End:(CGPoint)end {
    viewContainerKeyframeCalculatingBlock _calculatingBlock = [self _keyframeBlock];

    NSMutableArray* _values = [[NSMutableArray alloc] initWithCapacity:steps];
    
    double _v = 0.0;
    for (int i=0; i<steps; i++) {
        _v = _calculatingBlock((double)(steps * 1.0 / (double)(steps) * i), 0.0, 100.0, (double)steps);
        
        CGPoint point = {
            .x = start.x + (_v / 100.0) * (end.x - start.x),
            .y = start.y + (_v / 100.0) * (end.y - start.y),
        };
        [_values addObject:[NSValue valueWithCGPoint:point]];
    }
    
    return _values;
}
-(NSArray*)_getSizeValues:(NSInteger)steps Start:(CGSize)start End:(CGSize)end {
    viewContainerKeyframeCalculatingBlock _calculatingBlock = [self _keyframeBlock];
    NSMutableArray* _values = [[NSMutableArray alloc] initWithCapacity:steps];
    
    double _v = 0.0;
    for (int i=0; i<steps; i++) {
        _v = _calculatingBlock((double)(steps * 1.0 / (double)(steps) * i), 0.0, 100.0, (double)steps);
        
        CGSize size = {
            .width = start.width + (_v / 100.0) * (end.width - start.width),
            .height  = start.height + (_v / 100.0) * (end.height - start.height),
        };
        [_values addObject:[NSValue valueWithCGSize:size]];
    }
    
    return _values;
}
-(NSArray*)_getRectValues:(NSInteger)steps Start:(CGRect)start End:(CGRect)end {
    viewContainerKeyframeCalculatingBlock _calculatingBlock = [self _keyframeBlock];
    NSMutableArray* _values = [[NSMutableArray alloc] initWithCapacity:steps];
    
    double _v = 0.0;
    for (int i=0; i<steps; i++) {
        _v = _calculatingBlock((double)(steps * 1.0 / (double)(steps) * i), 0.0, 100.0, (double)steps);
        
        CGRect rect = {
            .origin.x = start.origin.x + (_v / 100.0) * (end.origin.x - start.origin.x),
            .origin.y = start.origin.y + (_v / 100.0) * (end.origin.y - start.origin.y),
            .size.width = start.size.width + (_v / 100.0) * (end.size.width - start.size.width),
            .size.height = start.size.height + (_v / 100.0) * (end.size.height - start.size.height),
        };
        [_values addObject:[NSValue valueWithCGRect:rect]];
    }
    
    return _values;
}
-(NSArray*)_getColorValues:(NSInteger)steps Start:(CGColorRef)start End:(CGColorRef)end {
    viewContainerKeyframeCalculatingBlock _calculatingBlock = [self _keyframeBlock];
    NSMutableArray* _values = [[NSMutableArray alloc] initWithCapacity:steps];
    
    const CGFloat* startColors = CGColorGetComponents( start );
    const CGFloat* endColors = CGColorGetComponents( end );
    
    
    double _v = 0.0;
    for (NSInteger i = 1; i < steps; i++) {
        _v = _calculatingBlock((double)(steps * 1.0 / (double)(steps) * i), 0.0, 100.0, (double)steps);
        
        UIColor *color = [UIColor
                          colorWithRed:(startColors[0] + (_v / 100.0) * (endColors[0] - startColors[0]))
                          green:(startColors[1] + (_v / 100.0) * (endColors[1] - startColors[1]))
                          blue:(startColors[2] + (_v / 100.0) * (endColors[2] - startColors[2]))
                          alpha:(startColors[3] + (_v / 100.0) * (endColors[3] - startColors[3]))];
        [_values addObject:(id)color.CGColor];
    }
    return _values;
}
-(NSArray*)_getCATransform3DValues:(NSInteger)steps Start:(CATransform3D)start End:(CATransform3D)end {
    viewContainerKeyframeCalculatingBlock _calculatingBlock = [self _keyframeBlock];
    NSMutableArray* _values = [[NSMutableArray alloc] initWithCapacity:steps];
    
    double _v = 0.0;
    for (int i=0; i<steps; i++) {
        _v = _calculatingBlock((double)(steps * 1.0 / (double)(steps) * i), 0.0, 100.0, (double)steps);
        
        CATransform3D transform3d = {
            .m11 = start.m11 + (_v / 100.0) * (end.m11 - start.m11),
            .m12 = start.m12 + (_v / 100.0) * (end.m12 - start.m12),
            .m13 = start.m13 + (_v / 100.0) * (end.m13 - start.m13),
            .m14 = start.m14 + (_v / 100.0) * (end.m14 - start.m14),
            .m21 = start.m21 + (_v / 100.0) * (end.m21 - start.m21),
            .m22 = start.m22 + (_v / 100.0) * (end.m22 - start.m22),
            .m23 = start.m23 + (_v / 100.0) * (end.m23 - start.m23),
            .m24 = start.m24 + (_v / 100.0) * (end.m24 - start.m24),
            .m31 = start.m31 + (_v / 100.0) * (end.m31 - start.m31),
            .m32 = start.m32 + (_v / 100.0) * (end.m32 - start.m32),
            .m33 = start.m33 + (_v / 100.0) * (end.m33 - start.m33),
            .m34 = start.m34 + (_v / 100.0) * (end.m34 - start.m34),
            .m41 = start.m41 + (_v / 100.0) * (end.m41 - start.m41),
            .m42 = start.m42 + (_v / 100.0) * (end.m42 - start.m42),
            .m43 = start.m43 + (_v / 100.0) * (end.m43 - start.m43),
            .m44 = start.m44 + (_v / 100.0) * (end.m44 - start.m44),
        };
        [_values addObject:[NSValue valueWithCATransform3D:transform3d]];
    }
    
    return _values;
}



@end




