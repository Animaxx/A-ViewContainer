//
//  A_ViewBaseContainer.m
//  A_ViewContainer
//
//  Created by Animax Deng on 7/25/15.
//  Copyright (c) 2015 Animax Deng. All rights reserved.
//

#import "A_MultipleViewContainer.h"
#import "A_ViewBaseController.h"

#pragma mark - Enum 
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
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.controllerManager = [[A_ControllersManager alloc] init];
        
        self.clipsToBounds = YES;
        self.layer.masksToBounds = YES;
        _isSwitching = NO;
        _needsRefresh = YES;
        _currentOperation = _containerOperationType_noOperation;
        
        [self setFillColor:[UIColor colorWithWhite:0.0f alpha:0.8f]];
        [self setFramesToCutOut:@[[NSValue valueWithCGRect:CGRectMake(50, 50, 10, 10)],[NSValue valueWithCGRect:CGRectMake(0, 0, 200, 200)]]];
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

#pragma mark - disaplying
- (void)addController: (A_ViewBaseController *)controller {
    [self addSubview:controller.view];
    
    controller.view.translatesAutoresizingMaskIntoConstraints = NO;
    [self addConstraint:[NSLayoutConstraint constraintWithItem:controller.view attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1.0f constant:0.f]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:controller.view attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottom multiplier:1.0f constant:0.f]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:controller.view attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeft multiplier:1.0f constant:0.f]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:controller.view attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeRight multiplier:1.0f constant:0.f]];
}
- (void)A_Display {
    _needsRefresh = NO;
    
    
    [[_controllerManager getPrevious] setInvisible:YES withAnimation:NO];
    [[_controllerManager getNext] setInvisible:YES withAnimation:NO];
    [[_controllerManager getCurrent] setInvisible:YES withAnimation:NO];
    
    [self addController:[_controllerManager getPrevious]];
    [self addController:[_controllerManager getNext]];
    [self addController:[_controllerManager getCurrent]];
    
    
    [self bringSubviewToFront:[_controllerManager getCurrent].view];
    
    [self layoutIfNeeded];
    [_controllerManager getCurrent].view.layer.transform = CATransform3DMakeScale(_setting.scaleOfCurrent, _setting.scaleOfCurrent, 1);
    
    CALayer *previous = [_controllerManager getPrevious].view.layer;
    previous.transform = CATransform3DMakeScale(_setting.scaleOfEdge, _setting.scaleOfEdge, 1);
    previous.anchorPoint = CGPointMake(previous.anchorPoint.x + _setting.sideDisplacement, previous.anchorPoint.y);
    
    CALayer *next = [_controllerManager getNext].view.layer;
    next.transform = CATransform3DMakeScale(_setting.scaleOfEdge, _setting.scaleOfEdge, 1);
    next.anchorPoint = CGPointMake(next.anchorPoint.x - _setting.sideDisplacement, next.anchorPoint.y);
    
    [[_controllerManager getPrevious] setInvisible:NO withAnimation:YES];
    [[_controllerManager getNext] setInvisible:NO withAnimation:YES];
    [[_controllerManager getCurrent] setInvisible:NO withAnimation:YES];
}

#pragma mark - animation methods
- (void)moveToNext {
    _currentOperation = _containerOperationType_moveToNext;
    
    // Next to center animation
    CALayer *next = [_controllerManager getNextLayer];
    CAAnimationGroup *nextToCenterGroup = [CAAnimationGroup animation];
    [nextToCenterGroup setRemovedOnCompletion: YES];
    nextToCenterGroup.beginTime = 0.0f;
    nextToCenterGroup.duration = 1.0f;
//    nextToCenterGroup.removedOnCompletion = NO;
    nextToCenterGroup.fillMode = kCAFillModeBoth;
    
    CABasicAnimation *nextAnchor = [CABasicAnimation animationWithKeyPath:@"anchorPoint"];
    nextAnchor.toValue = [NSValue valueWithCGPoint:CGPointMake(0.5f, next.anchorPoint.y)];
    nextAnchor.additive = NO;
    
    CABasicAnimation *nextScale = [CABasicAnimation animationWithKeyPath:@"transform"];
    nextScale.toValue = [NSValue valueWithCATransform3D:CATransform3DMakeScale(_setting.scaleOfCurrent, _setting.scaleOfCurrent, 1)];
    nextScale.additive = NO;
    
    nextToCenterGroup.animations = @[nextAnchor,nextScale];
    [next addAnimation:nextToCenterGroup forKey:@"nextToCenterAnimation"];
    
    // Center to previous
    CALayer *current = [_controllerManager getCurrentLayer];
    CAAnimationGroup *centerToPreviousGroup = [CAAnimationGroup animation];
    [centerToPreviousGroup setRemovedOnCompletion: YES];
    centerToPreviousGroup.beginTime = 0.0f;
    centerToPreviousGroup.duration = 1.0f;
//    centerToPreviousGroup.removedOnCompletion = NO;
    centerToPreviousGroup.fillMode = kCAFillModeBoth;
    
    CABasicAnimation *currentAnchor = [CABasicAnimation animationWithKeyPath:@"anchorPoint"];
    currentAnchor.toValue = [NSValue valueWithCGPoint:CGPointMake(0.5f + _setting.sideDisplacement, current.anchorPoint.y)];
    currentAnchor.additive = NO;
    CABasicAnimation *currentScale = [CABasicAnimation animationWithKeyPath:@"transform"];
    currentScale.toValue = [NSValue valueWithCATransform3D:CATransform3DMakeScale(_setting.scaleOfEdge, _setting.scaleOfEdge, 1)];
    currentScale.additive = NO;
    
    centerToPreviousGroup.animations = @[currentAnchor,currentScale];
    [current addAnimation:centerToPreviousGroup forKey:@"centerToPreviousAnimation"];
    
    // Previous out
    CALayer *previous = [_controllerManager getPreviousLayer];
    CAAnimationGroup *previousOutGroup = [CAAnimationGroup animation];
    [previousOutGroup setRemovedOnCompletion: YES];
    previousOutGroup.beginTime = 0.0f;
    previousOutGroup.duration = 1.0f;
//    previousOutGroup.removedOnCompletion = NO;
    previousOutGroup.fillMode = kCAFillModeBoth;
    
    CABasicAnimation *previousAnchor = [CABasicAnimation animationWithKeyPath:@"anchorPoint"];
    previousAnchor.toValue = [NSValue valueWithCGPoint:CGPointMake(0.5f + (_setting.sideDisplacement * 2.0), previous.anchorPoint.y)];
    previousAnchor.additive = NO;
    
    previousOutGroup.animations = @[previousAnchor];
    [previous addAnimation:previousOutGroup forKey:@"previousOutAnimation"];
    
    // change to speed
    next.speed = .0f;
    current.speed = .0f;
    previous.speed = .0f;
    
}
- (void)moveToPrevious {
    _currentOperation = _containerOperationType_moveToPrevious;
}

- (void)addAfterNext {
    [self addController:[_controllerManager getAfterNext]];
    CALayer *afterNext = [_controllerManager getNextLayer];
    afterNext.transform = CATransform3DMakeScale(_setting.scaleOfEdge, _setting.scaleOfEdge, 1);
    afterNext.anchorPoint = CGPointMake(afterNext.anchorPoint.x - (_setting.sideDisplacement*2), afterNext.anchorPoint.y);
    
    CAAnimationGroup *afterNextGroup = [CAAnimationGroup animation];
    [afterNextGroup setRemovedOnCompletion: YES];
    afterNextGroup.beginTime = 0.0f;
    afterNextGroup.duration = 0.2f;
    afterNextGroup.removedOnCompletion = NO;
    afterNextGroup.fillMode = kCAFillModeBoth;
    afterNextGroup.delegate = self;
    [afterNextGroup setValue:@"afterNextComeAnimation" forKey:@"animationName"];
    
    CABasicAnimation *afterNextAnchor = [CABasicAnimation animationWithKeyPath:@"anchorPoint"];
    afterNextAnchor.toValue = [NSValue valueWithCGPoint:CGPointMake(0.5f + (_setting.sideDisplacement * 2.0), afterNext.anchorPoint.y)];
    afterNextAnchor.additive = NO;
    
    afterNextGroup.animations = @[afterNextAnchor];
    [afterNext addAnimation:afterNextGroup forKey:@"afterNextComeAnimation"];
}

// Reverset Animations
- (void)reverseAnimation {
    [self clearDisplayLink:NO];
    
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
        next.timeOffset += 0.034;
    } else {
        next.timeOffset = 1.0f;
    }
    if (current.timeOffset < 1.0f) {
        current.timeOffset += 0.034;
    } else {
        current.timeOffset = 1.0f;
    }
    if (previous.timeOffset < 1.0f) {
        previous.timeOffset += 0.034;
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
        
        [_controllerManager getNextLayer].speed = 1.0f;
        [_controllerManager getCurrentLayer].speed = 1.0f;
        [_controllerManager getPreviousLayer].speed = 1.0f;
    }
}

- (void)animationFinished {
    switch (_currentOperation) {
        case _containerOperationType_moveToNext: {
            // Stop next to center animation
            CALayer *nextLayer = [_controllerManager getNextLayer];
            nextLayer.anchorPoint = CGPointMake(0.5f, nextLayer.anchorPoint.y);
            nextLayer.transform = CATransform3DMakeScale(_setting.scaleOfCurrent, _setting.scaleOfCurrent, 1);
            [nextLayer removeAnimationForKey:@"nextToCenterAnimation"];
            
            // Stop center to previous animation
            CALayer *currentLayer = [_controllerManager getCurrentLayer];
            currentLayer.anchorPoint = CGPointMake(0.5f + _setting.sideDisplacement, currentLayer.anchorPoint.y);
            currentLayer.transform = CATransform3DMakeScale(_setting.scaleOfEdge, _setting.scaleOfEdge, 1);
            [currentLayer removeAnimationForKey:@"centerToPreviousAnimation"];
            
            // Stop previous out animation
            CALayer *previousOutLayer = [_controllerManager getPreviousLayer];
            previousOutLayer.anchorPoint = CGPointMake(0.5f - (_setting.sideDisplacement*2), previousOutLayer.anchorPoint.y);
            [previousOutLayer removeAnimationForKey:@"previousOutAnimation"];
            
            // Remoe previous
            A_ViewBaseController *outPrevious = [_controllerManager getPrevious];
            [outPrevious.view removeFromSuperview];
            
            [self clearDisplayLink:YES];
            
            // Bring new next controller
            [_controllerManager navigateToNext];
            [self addController:[_controllerManager getNext]];
            
            CALayer *newNextLayer = [_controllerManager getNextLayer];
            newNextLayer.transform = CATransform3DMakeScale(_setting.scaleOfEdge, _setting.scaleOfEdge, 1);
            newNextLayer.anchorPoint = CGPointMake(0.5f - _setting.sideDisplacement*2, newNextLayer.anchorPoint.y);
            
            [CATransaction begin]; {
                [CATransaction setCompletionBlock:^{
                    newNextLayer.anchorPoint = CGPointMake(newNextLayer.anchorPoint.x + _setting.sideDisplacement, newNextLayer.anchorPoint.y);
                }];
                
                CABasicAnimation *newNextAnchor = [CABasicAnimation animationWithKeyPath:@"anchorPoint"];
                newNextAnchor.toValue = [NSValue valueWithCGPoint:CGPointMake(0.5f - _setting.sideDisplacement, newNextLayer.anchorPoint.y)];
                newNextAnchor.beginTime = 0.0f;
                newNextAnchor.duration = 0.1f;
                newNextAnchor.fillMode = kCAFillModeBoth;
                [newNextLayer addAnimation:newNextAnchor forKey:nil];
            }
            [CATransaction commit];
        }
            break;
        case _containerOperationType_moveToPrevious:
            
            break;
        default:
            break;
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
    CGFloat halfWidth = [self getHalfWidth];
    
    CALayer *next = [_controllerManager getNextLayer];
    CALayer *current = [_controllerManager getCurrentLayer];
    CALayer *previous = [_controllerManager getPreviousLayer];
    
    if (movingDistance > 0) {
        next.timeOffset = movingDistance / halfWidth;
        current.timeOffset = movingDistance / halfWidth;
        previous.timeOffset = movingDistance / halfWidth;
    }
    
}
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesEnded:touches withEvent:event];
    if (!_isSwitching) return;
    
    CGFloat movingDistance = fabs(_startTouchPoint.x - [[touches anyObject] locationInView: self].x);
    
    if (movingDistance > [self getQuarterWidth]) {
//        [_controllerManager getNextLayer].speed = 1.0f;
//        [_controllerManager getCurrentLayer].speed = 1.0f;
//        [_controllerManager getPreviousLayer].speed = 1.0f;
        
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
    return self.bounds.size.width/4.0f;
}
- (CGFloat)getRecognisingEdgeWidth {
    return self.bounds.size.width * 0.1f;
}

// return 1 - touching left; 2 - touching right;
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

@end




