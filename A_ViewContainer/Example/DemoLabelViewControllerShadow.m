//
//  DemoLabelViewController.m
//  A_ViewContainer
//
//  Created by Animax Deng on 7/25/15.
//  Copyright (c) 2015 Animax Deng. All rights reserved.
//

#import "DemoLabelViewControllerShadow.h"

@interface DemoLabelViewControllerShadow ()

@property (weak, nonatomic) IBOutlet UILabel *labelText;

@end

@implementation DemoLabelViewControllerShadow

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.labelText setText:[NSString stringWithFormat:@"DEMO"]];
    
    // self.view.layer.cornerRadius = self.view.bounds.size.width / 2.5f;
    
    [self.view setBackgroundColor:[UIColor colorWithWhite:0.9 alpha:1]];
    self.view.layer.shadowColor = [UIColor blackColor].CGColor;
    self.view.layer.shadowOpacity = 0.6;
    self.view.layer.shadowRadius = 7;
    self.view.layer.shadowOffset = CGSizeMake(0.0f, 0.8f);
}

- (NSDictionary<NSString *,id> *)A_ExtraCenterToSideAnimation:(A_ContainerSetting *)setting direction:(A_ControllerDirectionEnum)direction {
    NSMutableDictionary<NSString *,id> *dic = [[NSMutableDictionary alloc] init];
    //[dic setObject:@(self.view.bounds.size.width / 2.5f) forKey:@"cornerRadius"];
    return dic;
}
- (NSDictionary<NSString *,id> *)A_ExtraSideToCenterAnimation:(A_ContainerSetting *)setting direction:(A_ControllerDirectionEnum)direction {
    NSMutableDictionary<NSString *,id> *dic = [[NSMutableDictionary alloc] init];
    //[dic setObject:@(0) forKey:@"cornerRadius"];
    return dic;
}

- (void)A_ViewDidAppearInCenter {
    [super A_ViewDidAppearInCenter];
}

@end
