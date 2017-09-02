//
//  LTHDemoViewController.m
//  LTHPasscodeViewController
//
//  Created by Roland Leth on 9/6/13.
//  Copyright (c) 2013 Roland Leth. All rights reserved.
//

#import "LTHDemoViewController.h"
#import "LTHPasscodeViewController.h"
#import "AppDelegate.h"

@implementation LTHDemoViewController
- (void)_refreshUI {
	if ([LTHPasscodeViewController passcodeExistsInKeychain]) {
		_enablePasscode.enabled = NO;
		_changePasscode.enabled = YES;
		
		
		_changePasscode.backgroundColor = [UIColor colorWithRed:0.50f green:0.30f blue:0.87f alpha:1.00f];
		
		_enablePasscode.backgroundColor = [UIColor colorWithWhite: 0.8f alpha: 1.0f];
	}
	else {
		_enablePasscode.enabled = YES;
		_changePasscode.enabled = NO;
				
		_changePasscode.backgroundColor = [UIColor colorWithWhite: 0.8f alpha: 1.0f];
		_enablePasscode.backgroundColor = [UIColor colorWithRed:0.000f green:0.645f blue:0.608f alpha:1.000f];
	}
}
- (void)passcodeViewControllerWasDismissed {
	[self _refreshUI];
}

- (void)viewDidLoad {
    [super viewDidLoad];
	self.title = @"Demo";
	self.view.backgroundColor = [UIColor whiteColor];
	
	[LTHPasscodeViewController sharedUser].delegate = self;
	_changePasscode = [UIButton buttonWithType: UIButtonTypeCustom];
	_enablePasscode = [UIButton buttonWithType: UIButtonTypeCustom];
	_enablePasscode.frame = CGRectMake(100, 100, 100, 50);
	_changePasscode.frame = CGRectMake(100, 200, 100, 50);
	[_changePasscode setTitle: @"Change" forState: UIControlStateNormal];
	[_enablePasscode setTitle: @"Enable" forState: UIControlStateNormal];
	[self _refreshUI];
	[_changePasscode addTarget: self action: @selector(_changePasscode) forControlEvents: UIControlEventTouchUpInside];
	[_enablePasscode addTarget: self action: @selector(_enablePasscode) forControlEvents: UIControlEventTouchUpInside];
	[self.view addSubview: _changePasscode];
	[self.view addSubview: _enablePasscode];
}

- (void)_changePasscode {
	[self showLockViewForChangingPasscode];
}
- (void)_enablePasscode {
	[self showLockViewForEnablingPasscode];
}
- (void)showLockViewForEnablingPasscode {
	[[LTHPasscodeViewController sharedUser] showForEnablingPasscodeInViewController: self];
}
- (void)showLockViewForChangingPasscode {
	[[LTHPasscodeViewController sharedUser] showForChangingPasscodeInViewController: self];
}
@end
