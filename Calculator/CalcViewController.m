//
//  CalcViewController.m
//  Calculator
//
//  Created by Kumangus on 2013/12/25.
//  Copyright (c) 2013年 Kumangus. All rights reserved.
//
#import "AppDelegate.h"
#import <QuartzCore/QuartzCore.h>
#import "CalcViewController.h"
#import "ListViewController.h"
#import "LTHPasscodeViewController.h"
#import "SFHFKeychainUtils.h"

//#import "FlipController.h"

@interface CalcViewController ()<UIViewControllerTransitioningDelegate,UINavigationControllerDelegate,ListViewControllerDelegate,LTHPasscodeViewControllerDelegate>

@end

@implementation CalcViewController{
//    FlipController *flipController;
    NSString *savedPasscode;

}
@synthesize btnOne,btnThree,btnFive,txtResult;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self.navigationController setNavigationBarHidden:YES];
    }
    return self;
}

- (UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

-(void)viewWillAppear:(BOOL)animated{
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
//    flipController = [FlipController new];
//    self.navigationController.delegate = self;
    
    
    [LTHPasscodeViewController sharedUser].delegate = self;
	savedPasscode = [SFHFKeychainUtils getPasswordForUsername: @"demoPasscode"
                                               andServiceName: @"demoServiceName"
                                                        error: nil];

    if (savedPasscode == nil) {
        [self _enablePasscode];
    }

    //計算機設定
	numberCount = 0;//已輸入的 "操作數" 的個數
	isDotDown = NO;//小數點的判斷
	isCal = NO;//是否經過一次有效的等號計算
	isPreOper = NO;//前一次輸入是否為操作數
	flag = NO;//週轉變數
	afterDotNumber = 0;//小數點後數字的位數
	num1 = 0;//操作數1
	num2 = 0;//操作數2
	isOverFlow = NO;
	isExp = NO;//是否發生操作數超過範圍異常
	currentOperatorType = operstorNoType;//當前操作類型
	currentNumber = 0;//當前操作數
    
    //密碼
    openPassword = NO;
    twiceTypeDot = NO;
    
    
	txtResult.text = @"0";
    
}



//-(id<UIViewControllerAnimatedTransitioning>) navigationController:(UINavigationController *)navigationController animationControllerForOperation:(UINavigationControllerOperation)operation fromViewController:(UIViewController *)fromVC toViewController:(UIViewController *)toVC{
////    if (operation == UINavigationControllerOperationPush) {
////        [swipeController wireToViewController:toVC];
////    }
//    flipController.reverse =
//    operation == UINavigationControllerOperationPop;
//    return flipController;
//}

//-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
//    
//    UIViewController *toVC = segue.destinationViewController;
//    toVC.transitioningDelegate = self;
//    
//}

- (void) inition{ //重置為0
	numberCount = 0;
	isDotDown = NO;
	isCal = NO;
	isOverFlow=NO;
	isPreOper = NO;
	afterDotNumber = 0;
	num1 = 0;
	num2 = 0;
	currentOperatorType = operstorNoType;
	txtResult.text = @"0";
	currentNumber = 0;
    
    //密碼
    openPassword = NO;
    twiceTypeDot = NO;
    isTyped = NO;
}


- (NSString *)changeFloat:(double)Right //把浮點數轉換成 字串加以顯示
{
	NSString *stringFloat;
	stringFloat = [NSString stringWithFormat:@"%f",Right];
	const char *floatChars = [stringFloat UTF8String];
    NSUInteger length = [stringFloat length];
	int i;
    for( i = length-1; i>=0; i--)
    {
        if(floatChars[i] == '0')
			;
		else
		{
            if(floatChars[i] == '.')
                i--;
            break;
        }
    }
    NSString *returnString;
    if(i == -1)
        returnString = @"0";
	else
        returnString = [stringFloat substringToIndex:i+1];
    return returnString;
}

-(IBAction) numberPress:(id)sender
{
	int number = [sender tag]; //數字等於該tag
	if(numberCount == 0||numberCount == 1)
	{
		if([txtResult.text length]>=9 && !isExp)
		{
			return;
		}
		isExp = NO;
		isPreOper = NO;
		numberCount = 1;
		if(isCal)
		{
			[self inition];
			if(flag)
			{
				txtResult.text = @"0.";
				isDotDown = YES;
				flag = NO;
			}
		}
		
		if(!isDotDown)
		{
			num1 = num1 * 10 +  number;
			txtResult.text = [self changeFloat: num1];
		}
		else{
			
			afterDotNumber ++;
			if(number == 0)
				txtResult.text = [NSString stringWithFormat:@"%@%@",txtResult.text,@"0"];
			else
			{
				num1 = num1 + pow(0.1,afterDotNumber) * number;
				txtResult.text=[NSString stringWithFormat:@"%@%d",txtResult.text,number];
				
			}
		}
		currentNumber = num1;
	}
    
	else if(numberCount == 2)
	{
		if([txtResult.text length] >= 9)
		{
			if(!isPreOper)
				return;
		}
		
		isPreOper = NO;
		if(!isDotDown)
		{
			
			num2 = num2 * 10 + number;
			txtResult.text = [self changeFloat: num2];
		}
		else
		{
			afterDotNumber++;
			
			if(number == 0)
				txtResult.text = [NSString stringWithFormat:@"%@%@",txtResult.text,@"0"];
			else
			{
				
				num2 = num2 + pow(0.1,afterDotNumber) * number;
				
				txtResult.text=[NSString stringWithFormat:@"%@%d",txtResult.text,number];
			}
		}
		currentNumber = num2;
	}
	currentafterNumber=afterDotNumber;
}

-(void)showMessage:(NSString *) msg//利用提示框顯示提示信息
{
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
													message:msg
												   delegate:self
										  cancelButtonTitle:@"OK"
										  otherButtonTitles:nil];
	[alert show];
}


- (void) equResult
{
	switch(currentOperatorType)
	{
		case operatorTypePlus:
			num1 = num1 + num2;
			break;
		case operatorTypeMinus:
			num1 = num1 - num2;
			break;
		case operatorTypeMul:
			num1 = num1 * num2;
			break;
		case operatorTypeDiv:
			if(num2 == 0)
			{
				txtResult.text = @"Error";
				[self showMessage:@"the divided number can't be Zero"];
				return;
			}
			num1 = num1 / num2;
			break;
            
            
		case operstorTypePercentage:
			num1= num1/100 ;
            break;
        case operatorTypePositiveAndNegative:
			num1 = -num1;
            break;
            
        case operstorNoType:
            break;
        
            
	}
	currentNumber = num1;
	isOverFlow=NO;
	NSLog(@"%f",num1);
	if([[self changeFloat:num1] length] >= 15)
	{
		txtResult.text = [NSString stringWithFormat:@"%e",num1];
		isExp = YES;
	}
	else if([[self changeFloat: num1] isEqualToString:@"-0"])
		txtResult.text = @"0";
	else
		txtResult.text = [self changeFloat: num1];
}

- (IBAction) equPress
{
	if(numberCount == 1 && isPreOper) //一個操作數，且前一次輸入為操作數
	{
		NSString *temp = txtResult.text;
		[self inition];
		txtResult.text = temp;
	}
	else if(numberCount >= 1&&!isPreOper)//一個以上操作數，且前一次輸入不是操作數
	{
		[self equResult];
		if([[self changeFloat: num1] length] >=9)
			isExp=YES;
		isCal = YES;
		isPreOper = NO;
		numberCount = 1;
		isDotDown = NO;
		afterDotNumber = 0;
	}
	else if(numberCount == 2 && isPreOper)//兩個操作數，且前一次輸入為操作數
	{
		
		num2 = isDotDown ? 0 : num1;
		[self equResult];
		isCal = YES;
		isPreOper = NO;
		numberCount = 1;
		isDotDown = NO;
		afterDotNumber = 0;
	}
}

- (IBAction) operPress:(id)sender
{
    if(numberCount == 2&&!isPreOper)
	{
		isPreOper = YES;
		[self equResult];
	}
	currentOperatorType = [sender tag];
	numberCount = 2 ;
	isPreOper = YES;
	isDotDown = NO;
	isOverFlow=NO;
	isCal = NO;
	num2 = 0;
	afterDotNumber = 0;
}
- (IBAction) clearPress:(id)sender{
	if([sender tag] == 0)
	{
		//後退操作
		if(numberCount == 1)
		{
			if(isCal)
			{
				[self inition];
				return;
			}
			if(isDotDown&&afterDotNumber > 0)
			{
				NSString *desiredNumber = [txtResult.text substringWithRange:NSMakeRange(0,[txtResult.text length]-1)];
				//NSLog(@"%@",desiredNumber);
				afterDotNumber--;
				txtResult.text = desiredNumber;
				num1 = [desiredNumber floatValue];
				NSLog(@"num1: %f",num1);
			}
			else {
				num1 = (int)(num1 / 10);
				isDotDown = NO;
				txtResult.text = [self changeFloat: num1];
			}
		}
		else if(numberCount == 2)
		{
			if(isDotDown&&afterDotNumber > 0)
			{
				NSString *desiredNumber = [txtResult.text substringWithRange:NSMakeRange(0,[txtResult.text length]-1)];
				afterDotNumber--;
				txtResult.text = desiredNumber;
				num2 = [desiredNumber floatValue];
				NSLog(@"num2: %f",num2);
			}
			else {
				num2 = (int)(num2/10);
				isDotDown = NO;
				txtResult.text = [self changeFloat: num2];
			}
		}
	}
	else//完全清零(初始化)
	{
		[self inition];
	}
}

#pragma mark - DotPress & Password

- (IBAction) dotPress:(id)sender
{

	if(isCal)//是否經過一次有效計算
		flag = YES;
	if(!isDotDown && !isCal && !isPreOper)//如果沒有 點號、計算過、運算
	{
		txtResult.text = [NSString stringWithFormat:@"%@%@",txtResult.text,@"."];
		isDotDown = YES;
	}
	else if(!isDotDown&&(isCal || isPreOper))
	{
		num2 = 0;
		txtResult.text = @"0.";
		isDotDown = YES;
	}
    
//密碼
    
    NSString *zeroDot = @"0.";
//    NSString *keychainValue = [SFHFKeychainUtils getPasswordForUsername:
//kKeychainTimerStart
//														 andServiceName: kKeychainServiceName
//																  error: nil];
    //    NSString *password = @"5023";
    savedPasscode = [SFHFKeychainUtils getPasswordForUsername: @"demoPasscode"
                                               andServiceName: @"demoServiceName"
                                                        error: nil];
    if (!twiceTypeDot) {
        NSLog(@"使用者 按下第 1 次點,savedPasscode＝%@",savedPasscode);
        openPassword = YES;
        twiceTypeDot = YES;
        
    }else if(twiceTypeDot && openPassword){
        NSLog(@"使用者 按下第 2 次點");
        if ([txtResult.text isEqualToString:
             [zeroDot stringByAppendingString:savedPasscode] ]) {
            NSLog(@"使用者輸入正確");
            
            UITabBarController *uiTabBarController = [self.storyboard instantiateViewControllerWithIdentifier:@"tabBarID"];
            
            [self presentViewController:uiTabBarController animated:YES completion:nil];
            
            twiceTypeDot = NO;//輸入正確才切換
        }else{
            NSLog(@"使用者輸入錯誤,密碼關閉,使用者輸入%@",txtResult.text);
            openPassword = NO;
        }
        
    }
}


-(void) buttonClicked:(id)sender
{
    UITabBarController *uiTabBarController = [self.storyboard instantiateViewControllerWithIdentifier:@"tabBarID"];

    [self presentViewController:uiTabBarController animated:YES completion:nil];
}


-(void) listViewControllerDidClickedDismissButton:(UINavigationController *)viewController
{
    [self dismissViewControllerAnimated:YES completion:nil];
}



//- (void)_refreshUI {
//	if ([LTHPasscodeViewController passcodeExistsInKeychain]) {
//		_enablePasscode.enabled = NO;
//		_changePasscode.enabled = YES;
//		_turnOffPasscode.enabled = YES;
//		_testPasscode.enabled = YES;
//		
//		_changePasscode.backgroundColor = [UIColor colorWithRed:0.50f green:0.30f blue:0.87f alpha:1.00f];
//		_testPasscode.backgroundColor = [UIColor colorWithRed:0.000f green:0.645f blue:0.608f alpha:1.000f];
//		_enablePasscode.backgroundColor = [UIColor colorWithWhite: 0.8f alpha: 1.0f];
//		_turnOffPasscode.backgroundColor = [UIColor colorWithRed:0.8f green:0.1f blue:0.2f alpha:1.000f];
//	}
//	else {
//		_enablePasscode.enabled = YES;
//		_changePasscode.enabled = NO;
//		_turnOffPasscode.enabled = NO;
//		_testPasscode.enabled = NO;
//		
//		_changePasscode.backgroundColor = [UIColor colorWithWhite: 0.8f alpha: 1.0f];
//		_enablePasscode.backgroundColor = [UIColor colorWithRed:0.000f green:0.645f blue:0.608f alpha:1.000f];
//		_testPasscode.backgroundColor = [UIColor colorWithWhite: 0.8f alpha: 1.0f];
//		_turnOffPasscode.backgroundColor = [UIColor colorWithWhite: 0.8f alpha: 1.0f];
//	}
//}


//- (void)passcodeViewControllerWasDismissed {
//	[self _refreshUI];
//}


- (void)_enablePasscode {
    [self showLockViewForEnablingPasscode];
}


- (void)showLockViewForEnablingPasscode {
	[[LTHPasscodeViewController sharedUser] showForEnablingPasscodeInViewController: self];
}




- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	// Release any cached data, images, etc that aren't in use.
}

@end
