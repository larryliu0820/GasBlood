//
//  ExpandingCell.m
//  arterial blood gas calculator
//
//  Created by Larry Liu on 3/10/15.
//  Copyright (c) 2015 Larry Liu. All rights reserved.
//

#import "ExpandingCell.h"

@implementation ExpandingCell
@synthesize textLabel,fruitLabel,titleLabel,calcLabel, subtitleLabel, calculationLabel;
- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
