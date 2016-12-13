//
//  OneViewController.m
//  FullscreenPopGesture
//
//  Created by Sobf Sunshinking on 16/12/12.
//  Copyright © 2016年 SOBF. All rights reserved.
//

#import "OneViewController.h"
#import "TwoViewController.h"
#import "UINavigationController+FullscreenPopGesture.h"
@interface OneViewController ()

@end

@implementation OneViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"one";
    self.view.backgroundColor = [UIColor cyanColor];
    UIButton * button = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 44, 44)];
    [button setTitle:@"pop" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(pop) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem * back = [[UIBarButtonItem alloc]initWithCustomView:button];
    self.navigationItem.leftBarButtonItem = back;

   }
-(void)pop{
    [self.navigationController popViewControllerAnimated:NO];
}
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    TwoViewController * two = [[TwoViewController alloc]init];
    two.ss_navgiationBarIsHidden = YES;
    two.ss_MaxAllowedInitialDistanceToLeftEdge = 200;
    [self.navigationController pushViewController:two animated:NO];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
