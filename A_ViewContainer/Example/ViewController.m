//
//  ViewController.m
//  A_ViewContainer
//
//  Created by Animax Deng on 7/25/15.
//  Copyright (c) 2015 Animax Deng. All rights reserved.
//

#import "ViewController.h"
#import "A_MultipleViewContainer.h"
#import "A_ViewBaseController.h"

#import "DemoLabelViewController.h"

@interface ViewController ()

@end

@implementation ViewController {
    A_MultipleViewContainer *container;
    __weak IBOutlet UIView *centerView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
}
- (void)viewDidAppear:(BOOL)animated {
    container = [A_MultipleViewContainer A_InstallTo:centerView];
    [container A_AddChild:[DemoLabelViewController createWithNumber:0]];
    [container A_AddChild:[DemoLabelViewController createWithNumber:1]];
    [container A_AddChild:[DemoLabelViewController createWithNumber:2]];
    [container A_AddChild:[DemoLabelViewController createWithNumber:3]];
    [container A_AddChild:[DemoLabelViewController createWithNumber:4]];
    [container A_AddChild:[DemoLabelViewController createWithNumber:5]];
}


@end
