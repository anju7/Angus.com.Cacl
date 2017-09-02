//
//  CalcViewController.h
//  Calculator
//
//  Created by Kumangus on 2013/12/25.
//  Copyright (c) 2013年 Kumangus. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef enum
{
	operatorTypePlus=0,
	operatorTypeMinus=1,
	operatorTypeMul=2,
	operatorTypeDiv=3,
	operstorTypePercentage=4,
	operatorTypePositiveAndNegative=5,
    operstorNoType=6
} OperatorType;

@interface CalcViewController : UIViewController{
    
	UIButton *btnOne;
	UIButton *btnThree;
	UIButton *btnFive;
	UIButton *btnPlus;
	UIButton *btnMul;
	UIButton *btnAdd;

	IBOutlet UIButton *btnEqu;
	UILabel *txtResult;
	BOOL isOper;
	BOOL isDotDown;
	BOOL isOverFlow;
	BOOL isCal;
	BOOL isPreOper;
	NSString *currentTxt;
	BOOL isExp;//是否出現一次計算的異常
	BOOL flag;//週轉變量
	int currentafterNumber;
	int afterDotNumber;
	double num1;
	double num2;
	double currentNumber;
	int numberCount;
	OperatorType currentOperatorType;
    
    BOOL openPassword;
    BOOL twiceTypeDot;
    BOOL isTyped;
	
	
}

@property(nonatomic,retain) IBOutlet UIButton *btnOne,*btnThree,*btnFive;


@property (weak, nonatomic) IBOutlet UIButton *btnDot;
@property(nonatomic,retain) IBOutlet UILabel *txtResult;
- (IBAction) numberPress:(id)sender;
- (IBAction) operPress:(id)sender;
- (IBAction) dotPress:(id)sender;
- (IBAction) equPress;
- (void) equResult;
- (IBAction) clearPress:(id)sender;
- (NSString *)changeFloat:(double)Right ;


@end


