//
//  ImageViewController.h
//  Ribbit
//
//  Created by Андрей Балясников on 12/02/14.
//  Copyright (c) 2014 Andrey Balyasnikov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface ImageViewController : UIViewController

@property (nonatomic, strong) PFObject *message;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@end
