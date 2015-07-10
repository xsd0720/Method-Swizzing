//
//  ViewController.m
//  MethodSwizzing
//
//  Created by wany on 15/7/10.
//  Copyright (c) 2015年 wany. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

-(void)viewWillAppear:(BOOL)animated{
    //这句不能少，否则无法成功(具体原因有待研究)
    [super viewWillAppear:animated];
    
    NSLog(@"viewWillAppear");
    
}

@end
