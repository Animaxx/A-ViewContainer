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
    CGPoint _viewPoint;
}

#define profileEdgeZoomRate(scaleOfEdge)  scaleOfEdge * 0.5f
#define profileEdgeRotateAngle 80.0 * M_PI / 180.0
#define perspectDistance 500

- (void)viewDidLoad {
    [super viewDidLoad];
    _viewPoint = self.view.layer.position;
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
- (NSDictionary *)centerToSideAttributes: (A_ContainerSetting *)setting direction:(A_ControllerDirectionEnum)direction {
    NSMutableDictionary *animationSet = [[NSMutableDictionary alloc] init];
    
    switch (direction) {
        case A_ControllerDirectionToLeft: {
            [animationSet setObject:[NSValue valueWithCGPoint:CGPointMake(0.5f + setting.sideDisplacement, self.view.layer.anchorPoint.y)] forKey:@"anchorPoint"];
            
            if ([setting hasStyle:A_MultipleViewStyleRotate]) {
                CATransform3D transform = CATransform3DMakeScale(profileEdgeZoomRate(setting.scaleOfEdge), profileEdgeZoomRate(setting.scaleOfEdge), 1);
                transform = CATransform3DRotate(transform, profileEdgeRotateAngle, 0.0, 1.0, 0);
                transform = CATransform3DPerspect(transform, CGPointMake(0, 0), perspectDistance);
                
                [animationSet setObject:[NSValue valueWithCATransform3D:transform] forKey:@"transform"];
//                [animationSet setObject:[NSValue valueWithCGPoint:CGPointMake(self.view.layer.position.x - (self.view.layer.bounds.size.width / 2.8), self.view.layer.position.y)] forKey:@"position"];
            } else {
                [animationSet setObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(setting.scaleOfEdge, setting.scaleOfEdge, 1)] forKey:@"transform"];
            }
        }
            break;
        case A_ControllerDirectionToRight: {
            [animationSet setObject:[NSValue valueWithCGPoint:CGPointMake(0.5f - setting.sideDisplacement, self.view.layer.anchorPoint.y)] forKey:@"anchorPoint"];
            
            if ([setting hasStyle:A_MultipleViewStyleRotate]) {
                CATransform3D transform = CATransform3DMakeScale(profileEdgeZoomRate(setting.scaleOfEdge), profileEdgeZoomRate(setting.scaleOfEdge), 1);
                transform = CATransform3DRotate(transform, -(profileEdgeRotateAngle), 0.0, 1.0, 0);
                transform = CATransform3DPerspect(transform, CGPointMake(0, 0), perspectDistance);
                
                [animationSet setObject:[NSValue valueWithCATransform3D:transform] forKey:@"transform"];
//                [animationSet setObject:[NSValue valueWithCGPoint:CGPointMake(self.view.layer.position.x + (self.view.layer.bounds.size.width / 2.8), self.view.layer.position.y)] forKey:@"position"];
            } else {
                [animationSet setObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(setting.scaleOfEdge, setting.scaleOfEdge, 1)] forKey:@"transform"];
            }
        }
            break;
        default:
            break;
    }
    
    return animationSet;
}
- (NSDictionary *)sideToCenterAttributes: (A_ContainerSetting *)setting direction:(A_ControllerDirectionEnum)direction {
    NSMutableDictionary *animationSet = [[NSMutableDictionary alloc] init];

    [animationSet setObject:[NSValue valueWithCGPoint:CGPointMake(0.5f, self.view.layer.anchorPoint.y)] forKey:@"anchorPoint"];
    [animationSet setObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(setting.scaleOfCurrent, setting.scaleOfCurrent, 1)] forKey:@"transform"];
//    [animationSet setObject:[NSValue valueWithCGPoint:self.view.layer.position] forKey:@"position"];
    
    return animationSet;
}
- (NSDictionary *)sideToOutAttributes: (A_ContainerSetting *)setting direction:(A_ControllerDirectionEnum)direction {
    NSMutableDictionary *animationSet = [[NSMutableDictionary alloc] init];
    
    switch (direction) {
        case A_ControllerDirectionToLeft:
            [animationSet setObject:[NSValue valueWithCGPoint:CGPointMake(0.5f + (setting.sideDisplacement * 2.0), self.view.layer.anchorPoint.y)] forKey:@"anchorPoint"];
            break;
        case A_ControllerDirectionToRight:
            [animationSet setObject:[NSValue valueWithCGPoint:CGPointMake(0.5f - (setting.sideDisplacement * 2.0), self.view.layer.anchorPoint.y)] forKey:@"anchorPoint"];
            break;
        default:
            break;
    }
    [animationSet setObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(setting.scaleOfEdge, setting.scaleOfEdge, 1)] forKey:@"transform"];
    
    return animationSet;
}

- (NSArray *)A_ExtraCenterToSideAnimation: (A_ContainerSetting *)setting direction:(A_ControllerDirectionEnum)direction {
    return @[];
}
- (NSArray *)A_ExtraSideToCenterAnimation: (A_ContainerSetting *)setting direction:(A_ControllerDirectionEnum)direction {
    return @[];
}
- (NSArray *)A_ExtraSideToOutAnimation: (A_ContainerSetting *)setting direction:(A_ControllerDirectionEnum)direction {
    return @[];
}

#pragma mark - Override
- (void)A_ViewWillAppearInCenter {
    
}
- (void)A_ViewDIdAppearInCenter {
    
}

#pragma mark - Animation function
CATransform3D CATransform3DMakePerspective(CGPoint center, float disZ) {
    CATransform3D transToCenter = CATransform3DMakeTranslation(-center.x, -center.y, 0);
    CATransform3D transBack = CATransform3DMakeTranslation(center.x, center.y, 0);
    CATransform3D scale = CATransform3DIdentity;
    scale.m34 = -1.0f/disZ;
    return CATransform3DConcat(CATransform3DConcat(transToCenter, scale), transBack);
}
CATransform3D CATransform3DPerspect(CATransform3D t, CGPoint center, float disZ) {
    return CATransform3DConcat(t, CATransform3DMakePerspective(center, disZ));
}

CATransform3D CATransform3DMake(CGFloat m11, CGFloat m12, CGFloat m13, CGFloat m14,
                                CGFloat m21, CGFloat m22, CGFloat m23, CGFloat m24,
                                CGFloat m31, CGFloat m32, CGFloat m33, CGFloat m34,
                                CGFloat m41, CGFloat m42, CGFloat m43, CGFloat m44)
{
    CATransform3D t;
    t.m11 = m11; t.m12 = m12; t.m13 = m13; t.m14 = m14;
    t.m21 = m21; t.m22 = m22; t.m23 = m23; t.m24 = m24;
    t.m31 = m31; t.m32 = m32; t.m33 = m33; t.m34 = m34;
    t.m41 = m41; t.m42 = m42; t.m43 = m43; t.m44 = m44;
    return t;
}


@end


