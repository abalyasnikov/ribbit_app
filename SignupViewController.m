//
//  SignupViewController.m
//  Ribbit
//
//  Created by Андрей Балясников on 08/02/14.
//  Copyright (c) 2014 Andrey Balyasnikov. All rights reserved.
//

#import "SignupViewController.h"
#import <Parse/Parse.h>

@interface SignupViewController ()

@end

@implementation SignupViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // добавляем padding
    self.usernameField.leftView = [self paddingForTextField];
    self.usernameField.leftViewMode = UITextFieldViewModeAlways;
    
    
    self.passwordField.leftView = [self paddingForTextField];
    self.passwordField.leftViewMode = UITextFieldViewModeAlways;
    
    self.emailField.leftView = [self paddingForTextField];
    self.emailField.leftViewMode = UITextFieldViewModeAlways;
    
    
}



- (IBAction)signup:(id)sender
{
    // self.usernameField.text - просто засовываем текст в стринг
    //  stringByTrimmingCharactersInSet - обрезаем пустое пространсво (пробелы) с обоих
    //  концов строки и похоже  -  это проверка, чтобы не засирать бд
    NSString *username = [self.usernameField.text stringByTrimmingCharactersInSet:
                          [NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    NSString *password = [self.passwordField.text stringByTrimmingCharactersInSet:
                          [NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    NSString *email = [self.emailField.text stringByTrimmingCharactersInSet:
                          [NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if ( [username length] == 0 || [password length] == 0 || [email length] == 0 ) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Oops"
                                                        message:@"Make sure you enter a user name, password and email!"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles: nil];
        [alert show];
        
    } else {
        // создаем нового юзера в parse.com
        // у экземпляра класса есть свойства, к ним приравниваем наши переменные с данными
        // документация тут: https://parse.com/docs/ios_guide#users/iOS
        
        PFUser *newUser = [PFUser user];
        newUser.username = username;
        newUser.password = password;
        newUser.email = email;
        
        // регистрируем юзера
        [newUser signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            // обрабатываем ошибку
            if (error) {
                UIAlertView *alerView = [[UIAlertView alloc] initWithTitle:@"Sorry"
                                                                   message:[error.userInfo objectForKey:@"error"]
                                                                  delegate:nil
                                                         cancelButtonTitle:@"OK"
                                                         otherButtonTitles: nil];
                [alerView show];
            } else {
                // если все ок, то возвращаем юзера в корневой контроллер, в даном случае - инбокс
                [self.navigationController popToRootViewControllerAnimated:YES];
                
            }
        }];
        
    }
    
    
}

- (IBAction)dismiss:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];


}

#pragma mark - helper methods

- (UIView *) paddingForTextField
{
    return [[UIView alloc] initWithFrame:CGRectMake(0, 0, 15, 44)];
}


@end
