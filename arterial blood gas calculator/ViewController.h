//
//  ViewController.h
//  arterial blood gas calculator
//
//  Created by Larry Liu on 3/3/15.
//  Copyright (c) 2015 Larry Liu. All rights reserved.
//

#import <UIKit/UIKit.h>
@interface ViewController : UIViewController<UIAlertViewDelegate,UIApplicationDelegate, UITableViewDelegate,UITableViewDataSource> {
    IBOutletCollection(UITextField) NSArray *textFields;
    
    int selectedIndex;
    NSMutableArray *titleArray;
    NSArray *subtitleArray;
    NSArray *textArray;
}

@property (nonatomic, strong) IBOutletCollection(UITextField) NSArray *textFields;
@property (weak, nonatomic) IBOutlet UITextView *resultTextView;

@property (weak, nonatomic) IBOutlet UIButton *clearButton;
@property (weak, nonatomic) IBOutlet UIButton *calculateButton;

@property (nonatomic, readwrite) CGFloat pH;
@property (nonatomic, readwrite) CGFloat PaCO2;
@property (nonatomic, readwrite) CGFloat HCO3;
@property (nonatomic, readwrite) CGFloat Alb;
@property (nonatomic, readwrite) CGFloat Na;
@property (nonatomic, readwrite) CGFloat Cl;

@property (nonatomic, strong) IBOutletCollection(UILabel) NSArray *labels;

@property (weak, nonatomic) IBOutlet UILabel *disclaimLabel;

@property (weak, nonatomic) IBOutlet UIButton *infoButton;
@property (weak, nonatomic) IBOutlet UIButton *helpButton;

@property (weak, nonatomic) IBOutlet UINavigationBar *navigationBar;

@property (nonatomic, retain) UIScrollView *infoView;
@property (nonatomic, retain) UILabel *infoLabel;
@property (retain, nonatomic) IBOutlet UIView *mainView;
@property (strong, nonatomic) IBOutlet UIView *middleView;
@property (retain, nonatomic) UIView *helpView;
@property (retain, nonatomic) UITableView *helpTableView;

@property (retain, nonatomic) NSMutableArray *textHeights;

@property (retain, nonatomic) NSArray *hplusValues;
@property (retain, nonatomic) NSArray *phValues;

@end

