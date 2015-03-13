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

@synthesize alertView, textFields, pH, PaCO2, HCO3, Alb, Na, Cl,clearButton, calculateButton, resultTextView, rightLabels, disclaimLabel, infoButton,infoView, infoLabel, mainView, navigationBar, middleView, helpTableView, helpButton, textHeights;

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
    resultTextView.frame = CGRectMake(widthMargin, clearButton.frame.origin.y + clearButton.frame.size.height + 15, width - 2 * widthMargin, height - 67 - resultTextView.frame.origin.y);
    resultTextView.editable = NO;
    disclaimLabel.frame = CGRectMake(widthMargin, (resultTextView.frame.origin.y + resultTextView.frame.size.height + height - disclaimLabel.frame.size.height)/2, width - 2 * widthMargin, disclaimLabel.frame.size.height);
    
    // Info view
    
    infoLabel =[[UILabel alloc] initWithFrame:CGRectMake(widthMargin,0,width - 2 * widthMargin, height)];
    [infoLabel setNumberOfLines:0];
    NSString *info = @"版本：1.0.0\n制作者：Larry 梦子\nEmail：mengweiliu600267@gmail.com\n\n\t感谢您下载使用动脉血气分析！由于血气分析的计算公式复杂，临床上判断多重酸碱失衡十分不便，我们萌生了使用程序代替笔算的想法。\n\t我们发现，当前App Store中的免费血气分析软件，大多操作繁琐或需要填写指标过多而难以使用，因此本软件简化了计算指标。\n\t衷心希望这款软件能够对各位的工作有所帮助！";
    NSMutableAttributedString* attrString = [[NSMutableAttributedString alloc] initWithString:info];
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    [style setLineSpacing:6];
    [attrString addAttribute:NSParagraphStyleAttributeName
                       value:style
                       range:NSMakeRange(0, info.length)];
    infoLabel.attributedText = attrString;
//    [infoLabel setText:info];
    
    [infoLabel setTextColor:[UIColor whiteColor]];
    infoView = [[UIScrollView alloc] initWithFrame:CGRectMake(0,0,width, infoLabel.frame.size.height)];
    [infoView setBackgroundColor:[UIColor darkGrayColor]];
    [infoView addSubview:infoLabel];
    
    // Help table View
    helpTableView = [[UITableView alloc] initWithFrame:CGRectMake(0,0,width, height)];
    helpTableView.delegate = self;
    helpTableView.dataSource = self;
    
    // Setting selectedIndex = -1 saying that there's no table selected
    selectedIndex = -1;
    
    titleArray = [[NSMutableArray alloc] initWithObjects:@"动脉血气分析",@"pH", @"PaCO2", @"HCO3-", @"Na+、Cl-", @"Alb", @"代谢性酸中毒",@"呼吸性酸中毒", @"代谢性碱中毒",@"呼吸性碱中毒", nil];
    textHeights = [[NSMutableArray alloc] init];
    for (NSInteger i = 0; i < [titleArray count]; ++i)
        [textHeights addObject:[NSNumber numberWithInt:0]];
    subtitleArray = [[NSArray alloc] initWithObjects:@"动脉血气分析",@"pH", @"PaCO2", @"HCO3-", @"Na+、Cl-", @"Alb", @"代谢性酸中毒",@"呼吸性酸中毒", @"代谢性碱中毒",@"呼吸性碱中毒", nil];
    textArray = [[NSArray alloc] initWithObjects:@"\t动脉血气分析是一项测定动脉学氧分压(PaO2)、二氧化碳分压(PaCO2)、酸碱度的检验(pH)。血气分析在重症疾病、呼吸系统疾病的治疗监护中起到十分关键的作用。因此，血气分析是ICU中最常见的检查之一。", @"\tph：判断酸碱平衡紊乱最直接的指标。血液pH的维持主要取决于HCO3-/H2C03缓冲系统，正常人此缓冲系统比值为20/1。正常参考范围7.35~7.45。",@"\tPaCO2：动脉二氧化碳分压。指血液中物理溶解的CO2气体所产生的压力。PCO2基本上与物理溶解的CO2量成正比关系，而与H2CO3及HCO3-仅有间接关系。正常参考范围35~45mmHg。",@"\tHCO3-：血浆碳酸氢盐。血浆标准碳酸氢盐指在标准条件下[37℃，PCO2 5.32kPa（40mmHg），Hb充分氧合]测得的血浆[HC03-]，也就是呼吸功能完全正常条件下的[HC03-]，通常根据pH与PCO2数据求得。血浆实际碳酸氢盐指血浆实际[HC03-]，即指“真正”血浆(未接触空气的血液在37oC分离的血浆)所含[HC03-]。正常参考值：22~27mmol/l。", @"\t血清中Na+正常参考值135~145mmol/l，Cl-正常参考值96~106mmol/l。",@"\t白蛋白：血浆白蛋白带有负电荷，当其从血液中丢失时其他阴离子如CL-、HCO3-便会增加，因而阴离子间隙会相应下降。低白蛋白血症时，白蛋白每下降10g/L，阴离子间隙正常值下降2.5~3mmol/L。正常参考值40~60g/l。",@"\t阴离子间隙（AG）升高代谢性酸中毒见于：1)乳酸酸中毒；2）酮症酸中毒；3）药物或毒物，如醇类、水杨酸类、二甲双胍、硫酸盐等；4）慢性肾功能衰竭；5）大量横纹肌溶解。\n\tAG正常代谢性酸中毒见于HCO3-丢失：1）长期腹泻；2）使用托吡酯；3）胰瘘；4）输尿管-乙状结肠吻合术；5）肾小管性酸中毒；6）药物或毒物（氯化铵、乙酰唑胺、胆汁酸螯合剂、异丙醇）；7）肾功能衰竭；8）吸入剂滥用；9）甲苯",@"\t急性呼吸性酸中毒见于：1）呼吸中枢抑制（中枢系统疾病或药物）；2）神经肌肉疾病（重症肌无力，脊髓侧索硬化症、格林巴利综合征、肌萎缩症；3）气道梗阻（哮喘或COPD急性加重）。",@"\t氯反应性（低氯性）碱中毒（尿氯<20mmol/L）见于：1）呕吐胃内容物或胃管减压；2）先天性失氯性腹泻；3）收缩性碱中毒（使用袢利尿剂、噻嗪类利尿剂使细胞外液流失、HCO3-浓缩所致）；4）呼吸性酸中毒中高碳酸血症突然被纠正；5）囊性纤维化。\n\t氯抵抗性碱中毒（尿氯>20mmol/L）见于：1）低钾血症；2）碱性物质摄入过多；3）高醛固酮血症；4）长期过量甘草酸摄入；5）Bartter综合征、 Gitelman综合征；6）Liddle综合征；7）11β-羟化酶缺乏症、17α-羟化酶缺乏症；8）氨基糖苷类毒性反应",@"\t呼吸性碱中毒见于：1）机械通气；2）精神因素过度通气；3）中枢疾病（卒中、蛛网膜下腔出血、脑膜炎）；4）药物应用（多沙普仑、阿司匹林、咖啡因等）；5）移居高海拔地区；6）肺部疾病如肺炎所致过度通气；7）发热；8）妊娠；9）血NH3升高", nil];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return titleArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"selectedIndex = %i, indexPath.row = %i", selectedIndex, (int)indexPath.row);
    static NSString *cellIdentifier = @"expandingCell";
    ExpandingCell *cell = (ExpandingCell *) [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if(cell == NULL) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"ExpandingCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    cell.frame = CGRectMake(cell.frame.origin.x, cell.frame.origin.y, tableView.frame.size.width - 10, cell.frame.size.height);
    cell.fruitLabel.frame = CGRectMake(10, cell.fruitLabel.frame.origin.y, cell.frame.size.width - 20, cell.fruitLabel.frame.size.height);
    cell.subtitleLabel.frame = CGRectMake(cell.frame.size.width - cell.subtitleLabel.frame.size.width, cell.subtitleLabel.frame.origin.y, cell.subtitleLabel.frame.size.width, cell.subtitleLabel.frame.size.height);
    if (selectedIndex == (int)indexPath.row) {
        //Do expanding cell stuff
        cell.contentView.backgroundColor = [UIColor lightGrayColor];
        cell.textLabel.textColor = [UIColor whiteColor];
        cell.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:18];
        cell.titleLabel.textColor = [UIColor whiteColor];
        cell.subtitleLabel.textColor = [UIColor whiteColor];
        cell.fruitLabel.textColor = [UIColor whiteColor];
        [cell.fruitLabel setHidden:NO];
    } else {
        //Do closing cell stuff
        cell.contentView.backgroundColor = [UIColor whiteColor];
        cell.textLabel.textColor = [UIColor blackColor];
        cell.titleLabel.font = [UIFont systemFontOfSize:17];
        cell.titleLabel.textColor = [UIColor blackColor];
        cell.subtitleLabel.textColor = [UIColor blackColor];
        cell.fruitLabel.textColor = [UIColor blackColor];
        [cell.fruitLabel setHidden:YES];
    }
    
//    cell.titleLabel.text = [titleArray objectAtIndex:indexPath.row];
    cell.subtitleLabel.text = [subtitleArray objectAtIndex:indexPath.row];
    cell.fruitLabel.text = [textArray objectAtIndex:indexPath.row];
    [cell.fruitLabel sizeToFit];
    [textHeights replaceObjectAtIndex:(int)indexPath.row withObject:@(cell.fruitLabel.frame.size.height + cell.fruitLabel.frame.origin.y + 5)];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (selectedIndex == indexPath.row) {
        return [[textHeights objectAtIndex:(int)indexPath.row] floatValue];
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
        [helpButton setImage:[UIImage imageNamed:@"help2.png"] forState:UIControlStateNormal];
    } else if ([infoView superview]) {
        [infoView removeFromSuperview];
        [middleView addSubview:helpTableView];
        [middleView sendSubviewToBack:infoView];
        [helpButton setImage:[UIImage imageNamed:@"help2.png"] forState:UIControlStateNormal];
        [infoButton setImage:[UIImage imageNamed:@"info.png"] forState:UIControlStateNormal];
    }else{
        [helpTableView removeFromSuperview];
        [middleView addSubview:mainView];
        [middleView sendSubviewToBack:helpTableView];
        [helpButton setImage:[UIImage imageNamed:@"help.png"] forState:UIControlStateNormal];
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
    } else if ([helpTableView superview]){
        [helpTableView removeFromSuperview];
        [middleView addSubview:infoView];
        [middleView sendSubviewToBack:helpTableView];
        [infoButton setImage:[UIImage imageNamed:@"info2.png"] forState:UIControlStateNormal];
        [helpButton setImage:[UIImage imageNamed:@"help.png"] forState:UIControlStateNormal];
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
    if (floatValue <= 0.0) {
        alertView = [[UIAlertView alloc] initWithTitle:@"输入错误，请重新输入!" message:nil delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
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
