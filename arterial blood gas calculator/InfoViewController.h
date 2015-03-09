//
//  InfoViewController.h
//  arterial blood gas calculator
//
//  Created by Larry Liu on 3/8/15.
//  Copyright (c) 2015 Larry Liu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface InfoViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIButton *infoButton;
@property (weak, nonatomic) IBOutlet UILabel *infoLabel;

-(id) initInfo;
@end
