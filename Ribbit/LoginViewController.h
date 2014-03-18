//
//  LoginViewController.h
//  Ribbit
//
//  Created by Андрей Балясников on 08/02/14.
//  Copyright (c) 2014 Andrey Balyasnikov. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoginViewController : UIViewController


@property (weak, nonatomic) IBOutlet UITextField *usernameField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
- (IBAction)login:(id)sender;

@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;

@end
