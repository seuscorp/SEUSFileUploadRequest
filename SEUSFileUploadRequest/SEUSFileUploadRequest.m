//
//  SEUSFileUploadRequest.m
//  SEUSAPIKit
//
//  Created by Joel Bell on 8/9/13.
//  Copyright (c) 2013 Seus Corp. All rights reserved.
//

#import "SEUSFileUploadRequest.h"

@implementation SEUSFileUploadRequest


#pragma mark - Setup Request
- (void)setupHTTPRequestData:(NSData *)imageData filename:(NSString *)filename andFileType:(SEUSFileType)fileType
{
    NSString *fileExtension = nil;
    switch (fileType) {
        case SEUSFileTypePNG:
            fileExtension = @"png";
            break;
        case SEUSFileTypeJPG:
            fileExtension = @"jpg";
            break;
        default:
            break;
    }
    
    // MAKE POST REQUEST
    [self setHTTPMethod:@"POST"];
    
    // HEADER
    NSString *boundary = @"---------------------------14737809831466499882746641449";
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
    [self addValue:contentType forHTTPHeaderField: @"Content-Type"];
    
    // BODY
    NSMutableData *body = [NSMutableData data];
    [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"userfile\"; filename=\"%@.%@\"\r\n", filename, fileExtension] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"Content-Type: image/%@\r\n\r\n", fileExtension] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:imageData];
    [body appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [self setHTTPBody:body];
}


#pragma mark - Public

+ (id)requestWithURL:(NSURL *)url image:(UIImage *)image filename:(NSString *)filename andFileType:(SEUSFileType)fileType
{
    SEUSFileUploadRequest *request = [[SEUSFileUploadRequest alloc] initWithURL:url image:image filename:filename andFileType:fileType];
    return request;
}

- (id)initWithURL:(NSURL *)url image:(UIImage *)image filename:(NSString *)filename andFileType:(SEUSFileType)fileType
{
    if (self = [self initWithURL:url])
    {
        [self setImage:image filename:filename fileType:fileType finishedProcessingHander:nil];
    }
    
    return self;
}

- (BOOL)setImage:(UIImage *)image filename:(NSString *)filename fileType:(SEUSFileType)fileType finishedProcessingHander:(SEUSImageProcessCompletionHandler)finishedProcessingHandler;
{
    NSData __block *imageData = nil;
    BOOL retVal = NO;
    
    if (finishedProcessingHandler == nil) // Encode the Data Synchronously
    {
        switch (fileType)
        {
            case SEUSFileTypeJPG:
                imageData = UIImageJPEGRepresentation(image, 0.80f);
                break;
            case SEUSFileTypePNG:
                imageData = UIImagePNGRepresentation(image);
                break;
            default:
                [NSException raise:SEUSFileUploadRequestInvalidFileTypeException format:@"Invalid FileType: Use the SEUSFileType Constants"];
                break;
        }
        
        if (imageData != nil) {
            [self setupHTTPRequestData:imageData filename:filename andFileType:fileType];
            retVal = YES;
        }
    }
    else // Encode the data Asynchronously
    {
        dispatch_queue_t image_process_queue = dispatch_queue_create("com.seusx.apikit.file_upload.process_image", NULL);
        dispatch_async(image_process_queue, ^ {
            switch (fileType)
            {
                case SEUSFileTypeJPG:
                    imageData = UIImageJPEGRepresentation(image, 0.80f);
                    break;
                case SEUSFileTypePNG:
                    imageData = UIImagePNGRepresentation(image);
                    break;
                default:
                    [NSException raise:SEUSFileUploadRequestInvalidFileTypeException format:@"Invalid FileType: Use the SEUSFileType Constants"];
                    break;
                    
            }
            
            dispatch_async(dispatch_get_main_queue(), ^ {
                
                BOOL success = NO;
                if (imageData != nil) {
                    [self setupHTTPRequestData:imageData filename:filename andFileType:fileType];
                    success = YES;
                }
                
                id __weak weakSelf = self;
                finishedProcessingHandler(success, weakSelf);
            });
        });
    }
    
    return retVal;
}


@end
