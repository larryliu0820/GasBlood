//
//  InfoViewController.m
//  arterial blood gas calculator
//
//  Created by Larry Liu on 3/8/15.
//  Copyright (c) 2015 Larry Liu. All rights reserved.
//

#import "InfoViewController.h"

@interface InfoViewController ()

@end

@implementation InfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
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
- (IBAction)dismissInfo:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (id) initInfo {
    self = [super init];
    CGFloat widthMargin = 30;
    CGFloat heightMargin = 20;
    CGFloat width = [[UIScreen mainScreen] bounds].size.width;
    CGFloat height = [[UIScreen mainScreen] bounds].size.height;
    // Do any additional setup after loading the view from its nib.
    _infoButton.frame = CGRectMake(width - widthMargin - _infoButton.frame.size.width, _infoButton.frame.origin.y, _infoButton.frame.size.width, _infoButton.frame.size.height);
    _infoLabel.frame = CGRectMake(widthMargin, _infoLabel.frame.origin.y, width - 2 * widthMargin, height - _infoLabel.frame.origin.y - heightMargin);

    return self;
}

@end
