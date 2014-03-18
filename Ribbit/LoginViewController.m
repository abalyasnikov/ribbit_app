//
//  LoginViewController.m
//  Ribbit
//
//  Created by Андрей Балясников on 08/02/14.
//  Copyright (c) 2014 Andrey Balyasnikov. All rights reserved.
//

#import "LoginViewController.h"
#import <Parse/Parse.h>

@interface LoginViewController ()

@end

@implementation LoginViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // добавляем padding
    self.usernameField.leftView = [self paddingForTextField];
    self.usernameField.leftViewMode = UITextFieldViewModeAlways;
    

    self.passwordField.leftView = [self paddingForTextField];
    self.passwordField.leftViewMode = UITextFieldViewModeAlways;
    

}



- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar setHidden:YES];
}



- (IBAction)login:(id)sender
{
    
    // копирнули из signup
    NSString *username = [self.usernameField.text stringByTrimmingCharactersInSet:
                          [NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    NSString *password = [self.passwordField.text stringByTrimmingCharactersInSet:
                          [NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if ( [username length] == 0 || [password length] == 0 ) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Oops"
                                                        message:@"Make sure you enter a user name and password!"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles: nil];
        [alert show];
        
    }   else {
        
        [PFUser logInWithUsernameInBackground:username
                                     password:password
                                        block:^(PFUser *user, NSError *error)
        {
            if (error) {
                
                UIAlertView *alerView = [[UIAlertView alloc] initWithTitle:@"Sorry"
                                                                   message:[error.userInfo objectForKey:@"error"]
                                                                  delegate:nil
                                                         cancelButtonTitle:@"OK"
                                                         otherButtonTitles: nil];
                [alerView show];
            } else {
                
                // если все ок, как и в случае с sign up возвращаем в inbox
                [self.navigationController popToRootViewControllerAnimated:YES];
            }
            
            
        }];
        
        
    }



}


#pragma mark - helper methods

- (UIView *) paddingForTextField
{
    return [[UIView alloc] initWithFrame:CGRectMake(0, 0, 15, 44)];
}




@end
