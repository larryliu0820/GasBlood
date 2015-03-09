//
//  ViewController.h
//  arterial blood gas calculator
//
//  Created by Larry Liu on 3/3/15.
//  Copyright (c) 2015 Larry Liu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController<UIApplicationDelegate> {
    IBOutletCollection(UITextField) NSArray *textFields;
}

-(IBAction) textFieldDidEndEditing : (id) sender;

@property (nonatomic, strong) IBOutletCollection(UITextField) NSArray *textFields;
@property (weak, nonatomic) IBOutlet UITextView *resultTextView;

@property (weak, nonatomic) IBOutlet UIButton *clearButton;
@property (weak, nonatomic) IBOutlet UIButton *calculateButton;

@property (nonatomic, readwrite) CGFloat pH;
@property (nonatomic, readwrite) CGFloat PaCO2;
@property (nonatomic, readwrite) CGFloat HCO3;
@property (nonatomic, readwrite) CGFloat Alb;
@property (nonatomic, readwrite) CGFloat Na;
@property (nonatomic, readwrite) CGFloat K;
@property (nonatomic, readwrite) CGFloat Cl;

@property (nonatomic, strong) IBOutletCollection(UILabel) NSArray *rightLabels;

@property (nonatomic, retain) UIAlertView *alertView;

@property (weak, nonatomic) IBOutlet UILabel *disclaimLabel;

@property (weak, nonatomic) IBOutlet UIButton *infoButton;

@property (nonatomic, retain) UIViewController *infoViewController;

@end

