//
//  ViewController.m
//  aaa
//
//  Created by wany on 15/7/7.
//  Copyright (c) 2015年 wany. All rights reserved.

//

#import "ViewController.h"
#import "UIViewController+MRCUMAnalytics.h"
@interface ViewController ()

@end

@implementation ViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.view.backgroundColor = [UIColor greenColor];
}
-(void)viewWillAppear:(BOOL)animated{
    //这句不能少，否则无法成功
    [super viewWillAppear:animated];

    NSLog(@"viewWillAppear");
    
}

@end



