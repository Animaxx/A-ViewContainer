//
//  ViewControllerProgrammatic.m
//  A_ViewContainer
//
//  Created by Andrei Popa on 10/18/15.
//  Copyright (c) 2015 Andrei Popa. All rights reserved.
//

#import "ViewControllerProgrammatic.h"
#import "A_MultipleViewContainer.h"
#import "A_ViewBaseController.h"

#import "DemoLabelViewControllerShadow.h"

@interface ViewControllerProgrammatic ()

@end

@implementation ViewControllerProgrammatic {
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    // 1) define container view
    UIView *containerView = [[UIView alloc] init];
    containerView.frame = self.view.bounds;
    containerView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    containerView.backgroundColor = [UIColor colorWithWhite:0.77 alpha:1];
    [self.view addSubview:containerView];
    
    // 2) set settings
    A_ContainerSetting *containerSettings = [A_ContainerSetting A_DeafultSetting];
    containerSettings.scaleOfCurrentX = 0.75;
    containerSettings.scaleOfCurrentY = 0.9;
    containerSettings.scaleOfEdgeX = 0.65;
    containerSettings.scaleOfEdgeY = 0.8;
    containerSettings.sideDisplacement = 1.09;
    A_MultipleViewContainer *container = [A_MultipleViewContainer A_InstallTo:containerView
                                                                      setting:containerSettings];
    
    // 3) add children VCs
    DemoLabelViewControllerShadow *controller1 = [[DemoLabelViewControllerShadow alloc] init];
    DemoLabelViewControllerShadow *controller2 = [[DemoLabelViewControllerShadow alloc] init];
    DemoLabelViewControllerShadow *controller3 = [[DemoLabelViewControllerShadow alloc] init];
    DemoLabelViewControllerShadow *controller4 = [[DemoLabelViewControllerShadow alloc] init];
    DemoLabelViewControllerShadow *controller5 = [[DemoLabelViewControllerShadow alloc] init];
    
    NSArray *children = [NSArray arrayWithObjects:controller1, controller2, controller3, controller4, controller5, nil];
    [container A_AddChildren:children];
    
    // 4) display
    [container A_Display];
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

@end
