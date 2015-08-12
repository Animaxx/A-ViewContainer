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
    
    CGFloat hue = ( arc4random() % 256 / 256.0 );  //  0.0 to 1.0
    CGFloat saturation = ( arc4random() % 128 / 256.0 ) + 0.5;  //  0.5 to 1.0, away from white
    CGFloat brightness = ( arc4random() % 128 / 256.0 ) + 0.5;  //  0.5 to 1.0, away from black
    UIColor *color = [UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:(number+3)/10.0f];
    [controller.view setBackgroundColor:color];
    
    return controller;
}


@end
