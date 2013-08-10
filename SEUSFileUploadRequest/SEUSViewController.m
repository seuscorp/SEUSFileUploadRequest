//
//  SEUSViewController.m
//  SEUSFileUploadRequest
//
//  Created by Joel Bell on 8/9/13.
//  Copyright (c) 2013 Seus Corp. All rights reserved.
//

#import "SEUSViewController.h"
#import "SEUSFileUploadRequest.h"


/*!
 @note Change this to your server. While i'd love to have an app that demonstrates this out of the box
       but I really dont want to have to worry about random images being uploaded to my server all the time.
 */
static NSString * const URL = @"http://apps.seusx.com/test";





@implementation SEUSViewController
{
    NSURLConnection *_connection;
    NSMutableData *_data;
    
    UIImagePickerController *_imagePicker;
    UIImageView *_imageView;
}


#pragma mark - Targets
- (void)takePictureButtonPressed:(id)sender {
    if (_imagePicker == nil) {
        _imagePicker = [[UIImagePickerController alloc] init];
        _imagePicker.delegate = self;
        _imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            _imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        }
    }
       
    [self presentViewController:_imagePicker animated:YES completion:nil];
}

- (void)submitButtonPressed:(id)sender {
    
    if (_imageView.image == nil) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Notice" message:@"You havent chosen an image yet!" delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil];
        [alert show];
    }
    else {
        
        // SYNCHRONOUS REQUEST (Image is processed into data on the main thread) For the sake of the example were only going to actually launch the async one but commented out is the code you would need to actually launch a syncronous request

//        SEUSFileUploadRequest *syncRequest = [[SEUSFileUploadRequest alloc] initWithURL:[NSURL URLWithString:URL]
//                                                                              image:_imageView.image
//                                                                           filename:@"My Upload"
//                                                                        andFileType:SEUSFileTypePNG];
//         _connection = [[NSURLConnection alloc] initWithRequest:syncRequest delegate:self];
        
        
        
        
        // ASYNCHRONOUS REQUEST (Image is processed into data on a background thread)
        SEUSFileUploadRequest *asyncRequest = [[SEUSFileUploadRequest alloc] initWithURL:[NSURL URLWithString:URL]];
        [asyncRequest setImage:_imageView.image filename:@"My Upload" fileType:SEUSFileTypePNG finishedProcessingHander:^(BOOL success, id weakRequest) {
            _connection = [[NSURLConnection alloc] initWithRequest:weakRequest delegate:self];
        }];
    }
}

#pragma mark
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    
    _imageView = [[UIImageView alloc] initWithFrame:CGRectMake((screenBounds.size.width - 250)/2,
                                                                           (screenBounds.size.width - 250)/2,
                                                                           250,
                                                                           250)];
    _imageView.contentMode = UIViewContentModeScaleAspectFit;
    _imageView.backgroundColor = [UIColor lightGrayColor];
    [self.view addSubview:_imageView];
    
    UIButton *picturebutton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [picturebutton addTarget:self action:@selector(takePictureButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    picturebutton.frame = CGRectMake(CGRectGetMinX(_imageView.frame),
                                     CGRectGetMaxY(_imageView.frame) + 20,
                                     _imageView.frame.size.width,
                                     40);
    [picturebutton setTitle:@"Take Picture" forState:UIControlStateNormal];
    [self.view addSubview:picturebutton];
    
    UIButton *submitButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [submitButton addTarget:self action:@selector(submitButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    submitButton.frame = CGRectMake(CGRectGetMinX(picturebutton.frame), CGRectGetMaxY(picturebutton.frame) + 20, picturebutton.frame.size.width, 40);
    [submitButton setTitle:@"SUBMIT" forState:UIControlStateNormal];
    [self.view addSubview:submitButton];
    


    
}

#pragma mark - Image Picker Controller
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [self dismissViewControllerAnimated:YES completion: ^ {
        _imageView.image = [info objectForKey:UIImagePickerControllerOriginalImage];
    }];
}

#pragma mark - NSURLConnectionDataDelegate

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    if (_data != nil) {
        [_data setLength:0];
    } else {
        _data = [[NSMutableData alloc] init];
    }    
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [_data appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Alert" message:@"Upload Failed. Check your server URL or your internet connection" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    [alert show];
    NSLog(@"Error: %@", error);
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Success!" message:@"You've successfully upload an image to your server!" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    [alert show];
    
    
    NSString *responseString = [[NSString alloc] initWithData:_data encoding:NSUTF8StringEncoding];
    NSLog(@"Response: %@", responseString);
}

@end
