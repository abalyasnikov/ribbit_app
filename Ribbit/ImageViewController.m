//
//  ImageViewController.m
//  Ribbit
//
//  Created by Андрей Балясников on 12/02/14.
//  Copyright (c) 2014 Andrey Balyasnikov. All rights reserved.
//

#import "ImageViewController.h"

@interface ImageViewController ()

@end

@implementation ImageViewController




- (void)viewDidLoad
{
    [super viewDidLoad];
	
    PFFile *imageFile = [self.message objectForKey:@"file"];
    if (imageFile.url != nil) {
        NSURL *imageFileUrl = [[NSURL alloc] initWithString:imageFile.url];
        NSData *imageData = [NSData dataWithContentsOfURL:imageFileUrl];
        self.imageView.image = [UIImage imageWithData:imageData];
        
        NSString *senderName = [self.message objectForKey:@"senderName"];
        NSString *title = [NSString stringWithFormat:@"Sent from %@", senderName];
        self.navigationItem.title = title;
    }
    
}


- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.tabBarController.tabBar setHidden:YES];
}






@end
