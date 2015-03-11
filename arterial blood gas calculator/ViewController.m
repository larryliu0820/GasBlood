//
//  ViewController.m
//  arterial blood gas calculator
//
//  Created by Larry Liu on 3/3/15.
//  Copyright (c) 2015 Larry Liu. All rights reserved.
//

#import "ViewController.h"
#import "ExpandingCell.h"
@interface ViewController ()

@end

@implementation ViewController

@synthesize alertView, textFields, pH, PaCO2, HCO3, Alb, Na, Cl,clearButton, calculateButton, resultTextView, rightLabels, disclaimLabel, infoButton,infoView, infoLabel, mainView, navigationBar, middleView, helpTableView, helpButton;

enum {
    pHFieldTag = 0,
    PaCO2FieldTag,
    HCO3FieldTag,
    NaFieldTag,
    ClFieldTag,
    AlbFieldTag,
};

- (void)viewDidLoad {
    [super viewDidLoad];
    
    CGFloat widthMargin = 19;
    CGFloat heightMargin = 50;
    CGFloat width = [[UIScreen mainScreen] bounds].size.width;
    CGFloat height = [[UIScreen mainScreen] bounds].size.height - navigationBar.frame.origin.y - navigationBar.frame.size.height;
    middleView.frame = CGRectMake(0, navigationBar.frame.origin.y + navigationBar.frame.size.height, width, height);
    mainView.frame = CGRectMake(0, 0, middleView.frame.size.width, middleView.frame.size.height);

    
    for (UITextField *tempTextField in textFields) {
        tempTextField.delegate = self;
        if (tempTextField.tag > 2) {
            CGFloat originalX = tempTextField.center.x;
            tempTextField.frame = CGRectMake(width - 2 * widthMargin - tempTextField.frame.size.width, tempTextField.center.y - tempTextField.frame.size.height / 2, tempTextField.frame.size.width, tempTextField.frame.size.height);
            UILabel *tempLabel = rightLabels[tempTextField.tag - 3];
            tempLabel.center = CGPointMake(tempLabel.center.x + tempTextField.center.x - originalX, tempLabel.center.y);
        }
    }
    infoButton.frame = CGRectMake(width - widthMargin - infoButton.frame.size.width, infoButton.frame.origin.y, infoButton.frame.size.width, infoButton.frame.size.height);
    calculateButton.frame = CGRectMake(width - 2 * widthMargin - calculateButton.frame.size.width, calculateButton.frame.origin.y, calculateButton.frame.size.width, calculateButton.frame.size.height);
    calculateButton.alpha = 0.4;
    calculateButton.enabled = NO;
    // Do any additional setup after loading the view, typically from a nib.
    resultTextView.frame = CGRectMake(widthMargin, height / 2 - heightMargin, width - 2 * widthMargin, height * 0.4);
    disclaimLabel.frame = CGRectMake(widthMargin, (resultTextView.frame.origin.y + resultTextView.frame.size.height + height - disclaimLabel.frame.size.height)/2, width - 2 * widthMargin, disclaimLabel.frame.size.height);
    
    // Info view
    infoView = [[UIView alloc] initWithFrame:CGRectMake(0,0,width, height)];
    [infoView setBackgroundColor:[UIColor darkGrayColor]];
    infoLabel =[[UILabel alloc] initWithFrame:CGRectMake(widthMargin,0,width - 2 * widthMargin, height)];
    [infoLabel setNumberOfLines:20];
    [infoLabel setText:@"\t版本：1.0.0\n\t制作者：Larry 梦子\n\temail：eemliu@ucla.edu\n\n\n\t感谢您下载使用血气分析！由于血气分析的计算公式复杂，临床上判断多重酸碱代谢失衡十分不便。我们便萌生了使用程序代替笔算的想法。\n\t我们发现，当前appstore中的免费血气分析软件，大多操作不便或需要填写太多指标而难以应用到临床和血气相关习题中。因此我们采用了简化的计算指标。\n\t若这款软件能够帮助大家提高工作效率，我们将十分开心，并会继续努力！"];
    [infoLabel setTextColor:[UIColor whiteColor]];
    [infoView addSubview:infoLabel];
    
    // Help table View
    helpTableView = [[UITableView alloc] initWithFrame:CGRectMake(0,0,width, height)];
    helpTableView.delegate = self;
    helpTableView.dataSource = self;
    
    // Setting selectedIndex = -1 saying that there's no table selected
    selectedIndex = -1;
    titleArray = [[NSMutableArray alloc] init];
    NSString *string;
    for (int i = 0; i < 8; i++) {
        string = [NSString stringWithFormat:@"Row %i", i];
        [titleArray addObject:string];
    }
    
    subtitleArray = [[NSArray alloc] initWithObjects:@"First Row",@"Second Row",@"Third Row", @"Fourth Row",@"Fifth Row", @"Sixth Row", @"Seventh Row", @"Eighth Row", nil];
    textArray = [[NSArray alloc] initWithObjects:@"Apple",@"Orange",@"Banana",@"Blueberry",@"Grape",@"Lemon",@"Lime",@"Peach", nil];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return titleArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"expandingCell";
    ExpandingCell *cell = (ExpandingCell *) [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if(cell == NULL) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"ExpandingCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    cell.frame = CGRectMake(cell.frame.origin.x, cell.frame.origin.y, tableView.frame.size.width, cell.frame.size.height);
    cell.textLabel.frame = CGRectMake(cell.frame.size.width - cell.textLabel.frame.size.width - 10, cell.textLabel.frame.origin.y, cell.textLabel.frame.size.width, cell.textLabel.frame.size.height);
    cell.subtitleLabel.frame = CGRectMake(cell.frame.size.width - cell.subtitleLabel.frame.size.width - 10, cell.subtitleLabel.frame.origin.y, cell.subtitleLabel.frame.size.width, cell.subtitleLabel.frame.size.height);
    cell.calculationLabel.frame = CGRectMake(cell.frame.size.width - cell.calculationLabel.frame.size.width - 10, cell.calculationLabel.frame.origin.y, cell.calculationLabel.frame.size.width, cell.calculationLabel.frame.size.height);
    if (selectedIndex == indexPath.row) {
        //Do expanding cell stuff
        cell.contentView.backgroundColor = [UIColor lightGrayColor];
        cell.textLabel.textColor = [UIColor whiteColor];
        cell.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:18];
        cell.titleLabel.textColor = [UIColor whiteColor];
        cell.subtitleLabel.textColor = [UIColor whiteColor];
        cell.fruitLabel.textColor = [UIColor whiteColor];
        cell.calcLabel.textColor = [UIColor whiteColor];
        cell.calculationLabel.textColor = [UIColor whiteColor];
    } else {
        //Do closing cell stuff
        cell.contentView.backgroundColor = [UIColor whiteColor];
        cell.textLabel.textColor = [UIColor blackColor];
        cell.titleLabel.font = [UIFont systemFontOfSize:17];
        cell.titleLabel.textColor = [UIColor blackColor];
        cell.subtitleLabel.textColor = [UIColor blackColor];
        cell.fruitLabel.textColor = [UIColor blackColor];
        cell.calcLabel.textColor = [UIColor blackColor];
        cell.calculationLabel.textColor = [UIColor blackColor];
    }
    
    cell.textLabel.text = [titleArray objectAtIndex:indexPath.row];
    cell.subtitleLabel.text = [subtitleArray objectAtIndex:indexPath.row];
    cell.textLabel.text = [textArray objectAtIndex:indexPath.row];
    int calculation = ((int)indexPath.row + 1) * 25;
    cell.calculationLabel.text = [NSString stringWithFormat:@"%i", calculation];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (selectedIndex == indexPath.row) {
        return 100;
    } else {
        return 44;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    //User taps expanded row
    if (selectedIndex == indexPath.row) {
        selectedIndex = -1;
        [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        return;
    }
    
    //User taps different row
    
    if(selectedIndex != -1) {
        NSIndexPath *prevPath = [NSIndexPath indexPathForRow:selectedIndex inSection:0];
        selectedIndex = (int)indexPath.row;
        [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:prevPath]withRowAnimation:UITableViewRowAnimationFade];
        return;
    }
    
    //User taps new row with none expanded
    selectedIndex = (int)indexPath.row;
    [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
}
- (IBAction)showHelp:(id)sender {
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:1.0];
    [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:middleView cache:YES];
    
    if ([mainView superview])
    {
        [mainView removeFromSuperview];
        [middleView addSubview:helpTableView];
        [middleView sendSubviewToBack:mainView];
        [helpButton setImage:[UIImage imageNamed:@"info2.png"] forState:UIControlStateNormal];
    }
    else
    {
        [helpTableView removeFromSuperview];
        [middleView addSubview:mainView];
        [middleView sendSubviewToBack:helpTableView];
        [helpButton setImage:[UIImage imageNamed:@"info.png"] forState:UIControlStateNormal];
    }
    [UIView commitAnimations];
}

- (IBAction)showInfo:(id)sender {
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:1.0];
    [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight forView:middleView cache:YES];
    
    if ([mainView superview])
    {
        [mainView removeFromSuperview];
        [middleView addSubview:infoView];
        [middleView sendSubviewToBack:mainView];
        [infoButton setImage:[UIImage imageNamed:@"info2.png"] forState:UIControlStateNormal];
    }
    else
    {
        [infoView removeFromSuperview];
        [middleView addSubview:mainView];
        [middleView sendSubviewToBack:infoView];
        [infoButton setImage:[UIImage imageNamed:@"info.png"] forState:UIControlStateNormal];
    }
    [UIView commitAnimations];
    
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
        resultText = @"原发代谢性酸中毒";
        expectedPco2 = 1.5 * HCO3 + 8;
        agap = [self anionGap];
        if (agap <= 16) {
            resultText = [resultText stringByAppendingString:@"（正常阴离子间隙）"];
            CGFloat agapChange = agap - 12;
            CGFloat bicarbChange = 24 - HCO3;
            
            if ((agapChange - bicarbChange) > 7) {
                resultText = [resultText stringByAppendingString:@",\n混合代谢性碱中毒"];
            }else if((agapChange - bicarbChange) < -7) {
                resultText = [resultText stringByAppendingString:@",\n混合正常阴离子间隙的代谢性酸中毒"];
            }
        }
    }
    
    if ((pH > 7.44) && (PaCO2 >= 40)) {
        resultText = @"原发代谢性碱中毒";
        expectedPco2 = 0.7 * HCO3 + 21;
    }
    
    expectedPco2 = [self roundNum:expectedPco2 numDigits:0];
    NSString *postfix = @"";
    if (PaCO2 > (expectedPco2 + 2)) {postfix = @",\n合并呼吸性酸中毒";}
    if (PaCO2 < (expectedPco2 - 2)) {postfix = @",\n合并呼吸性碱中毒";}
    if (PaCO2 <= (expectedPco2 + 2) && PaCO2 >= (expectedPco2 - 2)) {postfix = @",\n伴完全呼吸代偿";}
    
    resultText = [resultText stringByAppendingString:postfix];
    expectedText = [NSString stringWithFormat:@"(预计 Pco2 = %f - %f)", expectedPco2 - 2, expectedPco2 + 2];
    
    // Primary Respiratory Disorders
    if ((pH < 7.4) && (PaCO2 > 44)) {
        resultText = @"原发性呼吸性酸中毒";
        phHigh = 7.4 - (0.003 * (PaCO2 - 40));
        phLow = 7.4 - (0.008 * (PaCO2 - 40));
        hco3High = 24 + (0.35 * (PaCO2 - 40));
        hco3Low = 24 + (0.1 * (PaCO2 - 40));
        
        phLow = [self roundNum:phLow numDigits:2];
        phHigh = [self roundNum:phHigh numDigits:2];
        hco3Low = [self roundNum:hco3Low numDigits:0];
        hco3High = [self roundNum:hco3High numDigits:0];
        
        if (pH <= (phLow + 0.02)) {
            resultText = [@"急性（失代偿）" stringByAppendingString:resultText];
            if (HCO3 < (hco3Low - 2)) {
                [resultText stringByAppendingString:@",\n合并代谢性酸中毒"];
                agap = [self anionGap];
                if (agap <= 16) {postfix = @"（正常阴离子间隙）";}
                else {postfix = @"（阴离子间隙升高）";}
                [resultText stringByAppendingString:postfix];
            }
        }
        
        if (pH >= (phHigh - 0.02001)) {
            resultText = [@"慢性（代偿）" stringByAppendingString:resultText];
            if (HCO3 > (hco3High + 2)) {
                [resultText stringByAppendingString:@",\n伴代谢性碱中毒"];
            }
        }
        
        if ((pH > (phLow + 0.02)) && (pH < (phHigh - 0.02001))) {
            resultText = [@"(1)部分代偿的原发呼吸性酸中毒，或\n(2)急性合并慢性呼吸性酸"// acute superimposed on chronic//
                          stringByAppendingString:resultText];
            resultText = [resultText stringByAppendingString:@", 或\n(3)混合型急性呼吸性酸中毒伴轻度代谢性碱中毒"];
        }
        
        expectedText = [NSString stringWithFormat:@"若pH < %f 且 HCO3 < %f, 则为急性（失代偿）\n若pH > %f 且 HCO3 > %f, 则为慢性（代偿）", phLow, hco3Low, phHigh, hco3High];
    }
    
    if ((pH > 7.4) && (PaCO2 < 36)) {
        resultText = @"原发呼吸性碱中毒";
        phLow = 7.4 + (0.0017 * (40 - PaCO2));
        phHigh = 7.4 + (0.008 * (40 - PaCO2));
        hco3Low = 24 - (0.5 * (40 - PaCO2));
        hco3High = 24 - (0.25 * (40 - PaCO2));
        
        phLow = [self roundNum:phLow numDigits:2];
        phHigh = [self roundNum:phHigh numDigits:2];
        hco3Low = [self roundNum:hco3Low numDigits:0];
        hco3High = [self roundNum:hco3High numDigits:0];
        
        if (pH <= (phLow + 0.02)) {
            resultText = [@"慢性（代偿性）" stringByAppendingString:resultText];
            if (HCO3 < (hco3Low - 2)) {
                resultText = [resultText stringByAppendingString:@",\n伴代谢性酸中毒"];
                agap = [self anionGap];
                if (agap <= 16) {resultText = [resultText stringByAppendingString:@"（正常阴离子间隙"];}
                else {resultText = [resultText stringByAppendingString:@"（阴离子间隙升高）"];}
            }
        }
        
        if (pH >= (phHigh - 0.02)) {
            resultText = [@"急性（失代偿）" stringByAppendingString:resultText];
            if (HCO3 > (hco3High + 2)) {
                resultText = [resultText stringByAppendingString:@",\n伴代谢性碱中毒"];
            }
        }
        
        if ((pH > (phLow + 0.02)) && (pH < (phHigh - 0.02))) {
            resultText = [@"(1)部分代偿的原发呼吸性碱中毒，或\n(2)急性合并慢性呼吸性碱中毒" stringByAppendingString:resultText];
            resultText = [resultText stringByAppendingString:@", 或\n(3)急性呼吸性碱中毒合并轻度代谢性酸中毒"];
        }
        
        expectedText = [NSString stringWithFormat:@"若pH > %f 且 HCO3 > %f, 则为急性（失代偿）\n若pH < %f 且 HCO3 < %f, 则为慢性（代偿）", phHigh, hco3High, phLow, hco3Low];
        
    }
    //  Mixed Acid-Base Disorders
    if ([resultText isEqualToString:@""]) {
        if ((pH >= 7.36) && (pH <= 7.44)) {
            if ((PaCO2 > 40) && (HCO3 > 26)) {
                resultText = @"呼吸性酸中毒混合代谢性碱中毒";
                expectedPco2 = 0.7 * HCO3 + 21;
            } else if((PaCO2 < 40) && (HCO3 < 22)) {
                resultText = @"呼吸性碱中毒混合代谢性酸中毒";
                expectedPco2 = 1.5 * HCO3 + 8;
                agap = [self anionGap];
                if (agap <= 16) {
                    [resultText stringByAppendingString:@"（正常阴离子间隙）"];
                }else {
                    [resultText stringByAppendingString:@"（阴离子间隙升高）"];
                }
            } else {
                agap = [self anionGap];
                if (agap > 16) {
                    resultText = @"代谢性碱中毒混合代谢性酸中毒（阴离子间隙升高）";
                }
            }
            expectedPco2 = [self roundNum:expectedPco2 numDigits:0];
            expectedText = [NSString stringWithFormat:@"(预计 Pco2 = %f - %f)", expectedPco2 - 2, expectedPco2 + 2];
        }
    }
    // Normal ABG
    if ([resultText isEqualToString:@""]) {
        resultText = @"正常血气";
        expectedText = @"";
    }
    
    NSString *expectedText2 =[NSString stringWithFormat:@"预计 pH = %f\n预计 CO2 = %f\n预计 HCO3- = %f", eph, eco2, ehco3];
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
