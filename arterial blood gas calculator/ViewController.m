//
//  ViewController.m
//  arterial blood gas calculator
//
//  Created by Larry Liu on 3/3/15.
//  Copyright (c) 2015 Larry Liu. All rights reserved.
//

#import "ViewController.h"
#import "InfoViewController.h"
@interface ViewController ()

@end

@implementation ViewController

@synthesize alertView, textFields, pH, PaCO2, HCO3, Alb, Na, K, Cl,clearButton, calculateButton, resultTextView, rightLabels, disclaimLabel, infoButton, infoViewController;

enum {
    pHFieldTag = 0,
    PaCO2FieldTag,
    HCO3FieldTag,
    AlbFieldTag,
    NaFieldTag,
    KFieldTag,
    ClFieldTag
};

- (void)viewDidLoad {
    [super viewDidLoad];
    CGFloat widthMargin = 19;
    CGFloat heightMargin = 50;
    CGFloat width = [[UIScreen mainScreen] bounds].size.width;
    CGFloat height = [[UIScreen mainScreen] bounds].size.height;
    for (UITextField *tempTextField in textFields) {
        tempTextField.delegate = self;
        if (tempTextField.tag > 3) {
            CGFloat originalX = tempTextField.center.x;
            tempTextField.frame = CGRectMake(width - 2 * widthMargin - tempTextField.frame.size.width, tempTextField.center.y - tempTextField.frame.size.height / 2, tempTextField.frame.size.width, tempTextField.frame.size.height);
            UILabel *tempLabel = rightLabels[tempTextField.tag - 4];
            tempLabel.center = CGPointMake(tempLabel.center.x + tempTextField.center.x - originalX, tempLabel.center.y);
        }
    }
    infoButton.frame = CGRectMake(width - widthMargin - infoButton.frame.size.width, infoButton.frame.origin.y, infoButton.frame.size.width, infoButton.frame.size.height);
    clearButton.frame = CGRectMake(widthMargin, height - heightMargin, clearButton.frame.size.width, clearButton.frame.size.height);
    calculateButton.frame = CGRectMake(width - widthMargin - calculateButton.frame.size.width, height - heightMargin, calculateButton.frame.size.width, calculateButton.frame.size.height);
    calculateButton.alpha = 0.4;
    calculateButton.enabled = NO;
    // Do any additional setup after loading the view, typically from a nib.
    resultTextView.frame = CGRectMake(widthMargin, height / 2 - heightMargin, width - 2 * widthMargin, height / 3);
    disclaimLabel.frame = CGRectMake(widthMargin, resultTextView.frame.origin.y + resultTextView.frame.size.height + heightMargin/2, width - 2 * widthMargin, disclaimLabel.frame.size.height);

}
- (IBAction)showInfo:(id)sender {
    if(!infoViewController) {
        infoViewController = [[InfoViewController alloc] initInfo];
        infoViewController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    }
    [self presentViewController:infoViewController animated:YES completion:nil];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)calculate:(id)sender {
    // Get values from text fields.
    CGFloat eph = 6.1 + log(HCO3 / (PaCO2 * 0.0301)) / log(10);
    CGFloat ehco3 = pow(10, pH - 6.1) * 0.0301 * PaCO2;
    CGFloat eco2 = HCO3 / (0.0301 * pow(10, pH - 6.1));
    CGFloat phHigh, phLow, hco3High, hco3Low;
    eph = [self roundNum:eph numDigits:2];
    ehco3 = [self roundNum:ehco3 numDigits:0];
    eco2 = [self roundNum:eco2 numDigits:0];
    
    NSString *resultText = @"";
    NSString *expectedText = @"";
    CGFloat expectedPco2 = 0.0;
    CGFloat agap = 0.0;
    // Primary Metabolic Disorders
    if ((pH < 7.36) && (PaCO2 <= 40)) {
        resultText = @"Primary metabolic acidosis";
        expectedPco2 = 1.5 * HCO3 + 8;
        agap = [self anionGap];
        if (agap <= 16) {
            resultText = [resultText stringByAppendingString:@", with normal anion gap"];
            CGFloat agapChange = agap - 12;
            CGFloat bicarbChange = 24 - HCO3;
            
            if ((agapChange - bicarbChange) > 7) {
                resultText = [resultText stringByAppendingString:@",\nmixed with a metabolic alkalosis"];
            }else if((agapChange - bicarbChange) < -7) {
                resultText = [resultText stringByAppendingString:@",\nmixed with a normal-gap metabolic acidosis"];
            }
        }
    }
    
    if ((pH > 7.44) && (PaCO2 >= 40)) {
        resultText = @"Primary metabolic alkalosis";
        expectedPco2 = 0.7 * HCO3 + 21;
    }
    
    expectedPco2 = [self roundNum:expectedPco2 numDigits:0];
    NSString *postfix = @"";
    if (PaCO2 > (expectedPco2 + 2)) {postfix = @",\nwith superimposed respiratory acidosis";}
    if (PaCO2 < (expectedPco2 - 2)) {postfix = @",\nwith superimposed respiratory alkalosis";}
    if (PaCO2 <= (expectedPco2 + 2) && PaCO2 >= (expectedPco2 - 2)) {postfix = @",\nwith full respiratory compensation";}
    
    resultText = [resultText stringByAppendingString:postfix];
    expectedText = [NSString stringWithFormat:@"(expected Pco2 = %f - %f)", expectedPco2 - 2, expectedPco2 + 2];
    
    // Primary Respiratory Disorders
    if ((pH < 7.4) && (PaCO2 > 44)) {
        resultText = @"primary respiratory acidosis";
        phHigh = 7.4 - (0.003 * (PaCO2 - 40));
        phLow = 7.4 - (0.008 * (PaCO2 - 40));
        hco3High = 24 + (0.35 * (PaCO2 - 40));
        hco3Low = 24 + (0.1 * (PaCO2 - 40));
        
        phLow = [self roundNum:phLow numDigits:2];
        phHigh = [self roundNum:phHigh numDigits:2];
        hco3Low = [self roundNum:hco3Low numDigits:0];
        hco3High = [self roundNum:hco3High numDigits:0];
        
        if (pH <= (phLow + 0.02)) {
            resultText = [@"Acute (uncompensated) " stringByAppendingString:resultText];
            if (HCO3 < (hco3Low - 2)) {
                [resultText stringByAppendingString:@",\nwith metabolic acidosis"];
                agap = [self anionGap];
                if (agap <= 16) {postfix = @", with normal anion gap";}
                else {postfix = @", with increased anion gap";}
                [resultText stringByAppendingString:postfix];
            }
        }
        
        if (pH >= (phHigh - 0.02001)) {
            resultText = [@"Chronic (compensated) " stringByAppendingString:resultText];
            if (HCO3 > (hco3High + 2)) {
                [resultText stringByAppendingString:@",\nwith metabolic alkalosis"];
            }
        }
        
        if ((pH > (phLow + 0.02)) && (pH < (phHigh - 0.02001))) {
            resultText = [@"(1) partially compensated primary respiratory acidosis, or\n(2) acute superimposed on chronic " stringByAppendingString:resultText];
            resultText = [resultText stringByAppendingString:@", or\n(3) mixed acute respiratory acidosis with a small metabolic alkalosis"];
        }
        
        expectedText = [NSString stringWithFormat:@"pH < %f and HCO3 < %f, for acute(uncompensated)\npH > %f and HCO3 > %f, for chronic (compensated)", phLow, hco3Low, phHigh, hco3High];
    }
    
    if ((pH > 7.4) && (PaCO2 < 36)) {
        resultText = @"primary respiratory alkalosis";
        phLow = 7.4 + (0.0017 * (40 - PaCO2));
        phHigh = 7.4 + (0.008 * (40 - PaCO2));
        hco3Low = 24 - (0.5 * (40 - PaCO2));
        hco3High = 24 - (0.25 * (40 - PaCO2));
        
        phLow = [self roundNum:phLow numDigits:2];
        phHigh = [self roundNum:phHigh numDigits:2];
        hco3Low = [self roundNum:hco3Low numDigits:0];
        hco3High = [self roundNum:hco3High numDigits:0];
        
        if (pH <= (phLow + 0.02)) {
            resultText = [@"Chronic (compensated) " stringByAppendingString:resultText];
            if (HCO3 < (hco3Low - 2)) {
                resultText = [resultText stringByAppendingString:@",\nwith metabolic acidosis"];
                agap = [self anionGap];
                if (agap <= 16) {resultText = [resultText stringByAppendingString:@", with normal anion gap"];}
                else {resultText = [resultText stringByAppendingString:@", with increased anoion gap"];}
            }
        }
        
        if (pH >= (phHigh - 0.02)) {
            resultText = [@"Acute (uncompensated) " stringByAppendingString:resultText];
            if (HCO3 > (hco3High + 2)) {
                resultText = [resultText stringByAppendingString:@",\nwith metabolic alkalosis"];
            }
        }
        
        if ((pH > (phLow + 0.02)) && (pH < (phHigh - 0.02))) {
            resultText = [@"(1) partially compensated primary respiratory alkalosis, or\n(2) acute superimposed on chronic " stringByAppendingString:resultText];
            resultText = [resultText stringByAppendingString:@", or\n(3) mixed acute respiratory alkalosis with a small metabolic acidosis"];
        }
        
        expectedText = [NSString stringWithFormat:@"pH > %f and HCO3 > %f, for acute(uncompensated)\npH < %f and HCO3 < %f, for chronic (compensated)", phHigh, hco3High, phLow, hco3Low];
        
    }
    //  Mixed Acid-Base Disorders
    if ([resultText isEqualToString:@""]) {
        if ((pH >= 7.36) && (pH <= 7.44)) {
            if ((PaCO2 > 40) && (HCO3 > 26)) {
                resultText = @"Mixed respiratory acidosis / metabolic alkalosis";
                expectedPco2 = 0.7 * HCO3 + 21;
            } else if((PaCO2 < 40) && (HCO3 < 22)) {
                resultText = @"Mixed respiratory alkalosis / metabolic acidosis";
                expectedPco2 = 1.5 * HCO3 + 8;
                agap = [self anionGap];
                if (agap <= 16) {
                    [resultText stringByAppendingString:@", with normal anion gap"];
                }else {
                    [resultText stringByAppendingString:@", with increased anion gap"];
                }
            } else {
                agap = [self anionGap];
                if (agap > 16) {
                    resultText = @"Mixed metabolic alkalosis / metabolic acidosis, with increased anion gap";
                }
            }
            expectedPco2 = [self roundNum:expectedPco2 numDigits:0];
            expectedText = [NSString stringWithFormat:@"(expected Pco2 = %f - %f)", expectedPco2 - 2, expectedPco2 + 2];
        }
    }
    // Normal ABG
    if ([resultText isEqualToString:@""]) {
        resultText = @"Normal ABG";
        expectedText = @"";
    }
    
    NSString *expectedText2 =[NSString stringWithFormat:@"expected pH = %f\nexpected CO2 = %f\nexpected HCO3- = %f", eph, eco2, ehco3];
    [resultTextView setText:[NSString stringWithFormat:@"%@\n\n%@\n\n%@", resultText, expectedText, expectedText2]];
                              
}

- (IBAction)clearInput:(id)sender {
    for (UITextField* tempTextField in textFields) {
        tempTextField.text = nil;
    }
    resultTextView.text = nil;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    if (textField.text == nil || [textField.text  isEqual: @""]) {
        return;
    }
    CGFloat floatValue = (CGFloat)[textField.text floatValue];
    if (floatValue == 0.0) {
        alertView = [[UIAlertView alloc] initWithTitle:@"Invalid value!" message:nil delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alertView show];
        textField.text = nil;
        calculateButton.alpha = 0.4;
        calculateButton.enabled = NO;
        return;
    }
    
    NSLog(@"here!textView.tag = %li, %f", textField.tag, floatValue);
    switch (textField.tag) {
        case pHFieldTag:
            pH = floatValue;
            break;
        case PaCO2FieldTag:
            PaCO2 = floatValue;
            break;
        case HCO3FieldTag:
            HCO3 = floatValue;
            break;
        case AlbFieldTag:
            Alb = floatValue;
            break;
        case NaFieldTag:
            Na = floatValue;
            break;
        case KFieldTag:
            K = floatValue;
            break;
        case ClFieldTag:
            Cl = floatValue;
            break;
        default:
            break;
    }
    BOOL isAllFull = YES;
    for (int i = 0; i < 3; i++) {
        UITextField *tempTextField = (UITextField*)textFields[i];
        if (tempTextField.text == nil || [tempTextField.text  isEqual: @""]) {
            isAllFull = NO;
        }
    }
    if (isAllFull) {
        calculateButton.alpha = 1;
        calculateButton.enabled = YES;
    }
}

- (CGFloat) anionGap {
    return Na - HCO3 - Cl;
}

- (CGFloat) roundNum:(CGFloat)thisNum numDigits:(NSUInteger)dec {
    thisNum = thisNum * pow(10,dec);
    thisNum = round(thisNum);
    thisNum = thisNum / pow(10,dec);
    return thisNum;
}

@end
