//
//  CameraViewController.m
//  Ribbit
//
//  Created by Андрей Балясников on 09/02/14.
//  Copyright (c) 2014 Andrey Balyasnikov. All rights reserved.
//

#import "CameraViewController.h"
#import <MobileCoreServices/UTCoreTypes.h>
#import "MSCellAccessory.h"


@interface CameraViewController ()

@end

@implementation CameraViewController

UIColor *desclosureColor;


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.friendsRelation = [[PFUser currentUser] objectForKey:@"friendsRelations"];
    self.recipients = [[NSMutableArray alloc] init];
    
    desclosureColor = [UIColor colorWithRed:0.553 green:0.439 blue:0.718 alpha:1];
    
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // отображаем список друзей - получателей
    PFQuery *query = [self.friendsRelation query];
    [query orderByAscending:@"username"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error) {
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
        else {
            self.friends = objects;
            [self.tableView reloadData];
        }
        
    }];
    
    // устанавливаем свойства на image пикер
    if (self.image == nil && [self.videoFilePath length] == 0) {
        self.imagePicker = [[UIImagePickerController alloc] init];
        self.imagePicker.delegate = self;
        self.imagePicker.allowsEditing = NO;
        self.imagePicker.videoMaximumDuration = 10;
        
        // проверяем если камера у устройста, соответственно для тех у кого нет, тип источника медиа только библиотека
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            self.imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        }
        else {
            self.imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        }
        
        self.imagePicker.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:self.imagePicker.sourceType];
        
        // модальная вьюха
        [self presentViewController:self.imagePicker animated:NO completion:nil];
    }
    
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
    return [self.friends count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"CellRecipient";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    // создаем экземляр класска пфюзера и тащим из массива юзеров в каждую ячейку по индексу
    PFUser *user = [self.friends objectAtIndex:indexPath.row];
    cell.textLabel.text = user.username;
    
    // так как табличка занова перестраивается (вместе с ней обновляется массив), поэтому чекбоксы раставляются под тем же индексом
    // на другие ячейки, что ни есть хорошо; то что ниже это убирает
    if ([self.recipients containsObject:user.objectId]) {
        cell.accessoryView = [MSCellAccessory accessoryWithType:FLAT_CHECKMARK color:desclosureColor];
    }
    else {
        cell.accessoryView = nil;
    }
    
    return cell;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // убираем выделение строки
    [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    PFUser *user = [self.friends objectAtIndex:indexPath.row];
    
    if (cell.accessoryView == nil) {
        cell.accessoryView = [MSCellAccessory accessoryWithType:FLAT_CHECKMARK color:desclosureColor];
        [self.recipients addObject:user.objectId];
    }
    else {
        cell.accessoryView = nil;
        [self.recipients removeObject:user.objectId];
    }
    
}


#pragma mark - UIImagePickerController delegate

- (void) imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    // раньше было что при нажатие на отметы в режиме камеры, возвращались к путой табличке.
    // сейчас же при нажатии на отмету попадаем в инбокс
    [self dismissViewControllerAnimated:NO completion:nil];
    [self.tabBarController setSelectedIndex:0];
}

- (void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    // засовываем фотку или видео в строку
    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    
    if ([mediaType isEqualToString:(NSString *)kUTTypeImage]) {
        // была выбрана или сделана фотка
        self.image = [info objectForKey:UIImagePickerControllerOriginalImage];
        
        // проверяем на наличие камеры у девайса (на симуляторе ее же нет)
        if ( self.imagePicker.sourceType == UIImagePickerControllerSourceTypeCamera ) {
            // сохраняем фотку локально на айфон
            UIImageWriteToSavedPhotosAlbum(self.image, nil, nil, nil);
        }
        
    }
    else {
        // было снято или выбрано видео
        NSURL *imagePickerURL = [info objectForKey:UIImagePickerControllerMediaURL];
        self.videoFilePath = [imagePickerURL path];
        if ( self.imagePicker.sourceType == UIImagePickerControllerSourceTypeCamera ) {
            
            // проверяем есть ли возможность сохранить видос локально и сохраняем видео
            if (UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(self.videoFilePath)) {
                UISaveVideoAtPathToSavedPhotosAlbum(self.videoFilePath, nil, nil, nil);
            }
            
            
            
        }
        
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}




#pragma mark - IBActions


- (IBAction)send:(id)sender {
    
    if (self.image == nil && [self.videoFilePath length] == 0) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Try again!"
                                                            message:@"Please capture or select a photo or video to share!"
                                                           delegate:self
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
        [alertView show];
        [self presentViewController:self.imagePicker animated:NO completion:nil];
    }
    else {
     
        [self uploadMessage];
        [self.tabBarController setSelectedIndex:0];
        //[[NSNotificationCenter defaultCenter] postNotificationName:@"messageSent" object:nil];
        
        
    }

}


- (IBAction)cancel:(id)sender
{
    [self reset];
    
    // возвращаем юзера в инбокс
    [self.tabBarController setSelectedIndex:0];
    
    

}

#pragma mark - helper methods

- (void) uploadMessage
{
    NSData *fileData;
    NSString *fileName;
    NSString *fileType;
    
    // 1. проверить видео это или картинка
    // 2. если картинка то обрезаем
    // 3. загружаем файл
    // 4. загружаем сообщение с деталями
    if (self.image != nil) {
        // изменяем размер картинки
        UIImage *newImage = [self resizeImage:self.image toWidth:320.0f andHeight:480.0f];
        fileData = UIImagePNGRepresentation(newImage);
        fileName = @"image.png";
        fileType = @"image";
        
    }
    else {
        // засовываем видео в формат nsdata по пути хранения видео который был ранее
        fileData = [NSData dataWithContentsOfFile:self.videoFilePath];
        fileName = @"video.mov";
        fileType = @"video";
    }
    
    PFFile *file = [PFFile fileWithName:fileName data:fileData];
    [file saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (error) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"An error occurred"
                                                            message:@"Plz try send your message again"
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
        }
        else {
            PFObject *message = [PFObject objectWithClassName:@"Messages"];
            [message setObject:file forKey:@"file"];
            [message setObject:fileType forKey:@"fileType"];
            [message setObject:self.recipients forKey:@"recipientIds"];
            [message setObject:[[PFUser currentUser] objectId] forKey:@"senderId"];
            [message setObject:[[PFUser currentUser] username] forKey:@"senderName"];
            
            [message saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (error) {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"An error occurred"
                                                                    message:@"Plz try send your message again"
                                                                   delegate:nil
                                                          cancelButtonTitle:@"OK"
                                                          otherButtonTitles:nil];
                    [alert show];
                }
                else {
                    // все круто! файл улетел в бэкэнд
                    [self reset];
                    
                    
                    
                }
                
                
            }];
            
        }
    }];
    
}



- (void)reset
{
    self.image = nil;
    self.videoFilePath = nil;
    [self.recipients removeAllObjects];
}



// метод меняет размер изображения
- (UIImage *) resizeImage: (UIImage *)image toWidth:(float)width andHeight:(float)height
{
    CGSize newSize = CGSizeMake(width, height);
    CGRect newRectangle = CGRectMake(0, 0, width, height);
    UIGraphicsBeginImageContext(newSize);
    [self.image drawInRect:newRectangle];
    UIImage *resizedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return resizedImage;
    
}








@end
