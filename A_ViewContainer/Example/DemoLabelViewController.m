//
//  DemoLabelViewController.m
//  A_ViewContainer
//
//  Created by Animax Deng on 7/25/15.
//  Copyright (c) 2015 Animax Deng. All rights reserved.
//

#import "DemoLabelViewController.h"

@interface DemoLabelViewController ()

@end

@implementation DemoLabelViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

+ (DemoLabelViewController *)createWithNumber:(int)number {
    DemoLabelViewController *controller = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:NSStringFromClass([self class])];
    
    [controller.view setBackgroundColor:[[UIColor blackColor] colorWithAlphaComponent:number/10]];
    
    return controller;
}


@end
