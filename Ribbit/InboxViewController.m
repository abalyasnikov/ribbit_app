//
//  InboxViewController.m
//  Ribbit
//
//  Created by Андрей Балясников on 08/02/14.
//  Copyright (c) 2014 Andrey Balyasnikov. All rights reserved.
//

#import "InboxViewController.h"
#import "MBProgressHUD.h"
#import "ImageViewController.h"
#import "MSCellAccessory.h"

@interface InboxViewController ()

@end

@implementation InboxViewController



- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.moviePlayer = [[MPMoviePlayerController alloc] init];
    
    
    
    PFUser *currentUser = [PFUser currentUser];
    
    if (currentUser) {
        NSLog(@"текущий юзер: %@", currentUser.username);
    } else {
        [self performSegueWithIdentifier:@"showLogin" sender:self];
    }
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(displayMessageSent)
                                                 name:@"messageSent"
                                               object:nil];
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self
                            action:@selector(retrieveMessages)
                  forControlEvents:UIControlEventValueChanged];
    
    
}

- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"messageSent" object:nil];
}



- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.navigationController.navigationBar setHidden:NO];
    
    [self retrieveMessages];
    
    
    
}

- (void)displayMessageSent {
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.tabBarController.view animated:YES];
    
    hud.mode = MBProgressHUDModeText;
    hud.labelText = @"Message sent";
    hud.margin = 10.f;
    hud.yOffset = 150.f;
    hud.removeFromSuperViewOnHide = YES;
    
    [hud hide:YES afterDelay:3];
    
}

- (IBAction)logout:(id)sender
{
    [PFUser logOut];
    [self performSegueWithIdentifier:@"showLogin" sender:self];
    
    
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.messages count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"CellInbox";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    PFObject *message = [self.messages objectAtIndex:indexPath.row];
    
    cell.textLabel.text = [message objectForKey:@"senderName"];
    
    // кастомные инконки перехода
    UIColor *desclosureColor = [UIColor colorWithRed:0.553 green:0.439 blue:0.718 alpha:1];
    cell.accessoryView = [MSCellAccessory accessoryWithType:FLAT_DISCLOSURE_INDICATOR color:desclosureColor];
    
    // определяем тип сообщения, чтобы добавить иконку
    NSString *fileType = [message objectForKey:@"fileType"];
    if ([fileType isEqualToString:@"image"]) {
        cell.imageView.image = [UIImage imageNamed:@"icon_image"];
    }
    else {
        cell.imageView.image = [UIImage imageNamed:@"icon_video"];
    }
    
    return cell;
}


#pragma mark - Table view delegate


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.selectedMessage = [self.messages objectAtIndex:indexPath.row];
    NSString *fileType = [self.selectedMessage objectForKey:@"fileType"];
    if ([fileType isEqualToString:@"image"]) {
        [self performSegueWithIdentifier:@"showImage" sender:self];
    }
    else {
        // здесь обрабатываем видео сообщение
        PFFile *videoFile = [self.selectedMessage objectForKey:@"file"];
        NSURL *fileURL = [NSURL URLWithString:videoFile.url];
        [self.moviePlayer setContentURL:fileURL];
        [self.moviePlayer prepareToPlay];
        
        // добавить в вью контроллер
        [self.view addSubview:self.moviePlayer.view];
        [self.moviePlayer setFullscreen:YES animated:YES];
    }
    
    // удаляем картинки или видео после просмотра
    NSMutableArray *recipientsIds = [NSMutableArray arrayWithArray:[self.selectedMessage objectForKey:@"recipientIds"]];
    NSLog(@"%@", recipientsIds);
    
    if ([recipientsIds count] == 1) {
        // это значит что сейчас последний получатель, поэтому нужно удалить контент
        [self.selectedMessage deleteInBackground];
    }
    else {
        // удаляем этого получателя и сохраняем
        [recipientsIds removeObject:[[PFUser currentUser] objectId]];
        [self.selectedMessage setObject:recipientsIds forKey:@"recipientIds"];
        [self.selectedMessage saveInBackground];
    }
    
    
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    if ([segue.identifier isEqualToString:@"showLogin"]) {
        
        // прячем таб иконки снизу
        [[segue destinationViewController] setHidesBottomBarWhenPushed:YES];
    }
    else if(([segue.identifier isEqualToString:@"showImage"])) {
        
        // прячем таб иконки снизу
        [[segue destinationViewController] setHidesBottomBarWhenPushed:YES];
        ImageViewController *ivc = (ImageViewController *)segue.destinationViewController;
        ivc.message = self.selectedMessage;
    }
}

#pragma mark - Helper methods

- (void)retrieveMessages
{
    PFQuery *query = [PFQuery queryWithClassName:@"Messages"];
    [query whereKey:@"recipientIds" equalTo:[[PFUser currentUser] objectId]];
    // сортировка по дате "Descending" - значит что новые будут на верху
    [query orderByDescending:@"createdAt"];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error) {
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
        else {
            // отображаем сообщения
            self.messages = objects;
            [self.tableView reloadData];
            NSLog(@"сообщений: %d", [self.messages count]);
            
        }
        
        if ([self.refreshControl isRefreshing]) {
            [self.refreshControl endRefreshing];
        }
        
        
    }];
}

@end
