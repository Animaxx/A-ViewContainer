//
//  DemoLabelViewController.m
//  A_ViewContainer
//
//  Created by Animax Deng on 7/25/15.
//  Copyright (c) 2015 Animax Deng. All rights reserved.
//

#import "DemoLabelViewController.h"

@interface DemoLabelViewController ()

@property (weak, nonatomic) IBOutlet UILabel *labelText;

@end

@implementation DemoLabelViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.labelText setText:[NSString stringWithFormat:@"DEMO %d", _numberTag]];
}

+ (DemoLabelViewController *)createWithNumber:(int)number {
    DemoLabelViewController *controller = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:NSStringFromClass([self class])];
    controller.numberTag = number;
    [controller.view setBackgroundColor:[[UIColor blackColor] colorWithAlphaComponent:(number+1)/10.0f]];
    
    return controller;
}


@end
