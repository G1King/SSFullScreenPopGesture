//
//  ViewController.m
//  FullscreenPopGesture
//
//  Created by Sobf Sunshinking on 16/12/12.
//  Copyright © 2016年 SOBF. All rights reserved.
//

#import "ViewController.h"
#import "OneViewController.h"
#import "TwoViewController.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    UIButton * right = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 44, 44)];
    [right setTitle:@"push" forState:UIControlStateNormal];
    [right setTitleColor: [UIColor cyanColor] forState:UIControlStateNormal];
    [right addTarget:self action:@selector(push:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem * righr = [[UIBarButtonItem alloc]initWithCustomView:right];
    self.navigationItem.rightBarButtonItem = righr;
    
}
-(void)push:(UIViewController*)vc{
    OneViewController * one = [[OneViewController alloc]init];
    
    [self.navigationController pushViewController:one animated:NO];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
