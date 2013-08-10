//
//  SEUSFileUploadRequest.h
//  SEUSAPIKit
//
//  Created by Joel Bell on 8/9/13.
//  Copyright (c) 2013 Seus Corp. All rights reserved.
//


typedef NS_ENUM(NSInteger, SEUSFileType)
{
    SEUSFileTypePNG = 100,
    SEUSFileTypeJPG = 101 // We will compress to 80% quality
};

typedef void (^SEUSImageProcessCompletionHandler) (BOOL success, id weakRequest);
static NSString * const SEUSFileUploadRequestInvalidFileTypeException = @"SEUSFileUploadRequestInvalidFileTypeException";




@interface SEUSFileUploadRequest : NSMutableURLRequest




/*!
 @abstract Convenience initalizers (Image Processed Synchronously)
 
 @param url: The url you are making the request too.
 @param image: The image you wish to send of http
 @param filename: The filename you wish the image to have (@note: DO NOT INCLUDE FILE EXTENSION)
 @param filetype: the type of file you wish to update (jpg or png)
 
 @note These functions will process your image syncronously. If the image is large you may want to 
 */

+ (id)requestWithURL:(NSURL *)url image:(UIImage *)image filename:(NSString *)filename andFileType:(SEUSFileType)fileType;
- (id)initWithURL:(NSURL *)url image:(UIImage *)image filename:(NSString *)filename andFileType:(SEUSFileType)fileType;




/*!
 @abstract Assign an image and Process it Asyncronously
 
 @param image: The image you wish to send over http
 @param fileType: The Type of file you want to send to the server (png or jpg)
 @param finishedProcessingHandler: The callback when your image has been fully converted into NSData
        @note If you pass in nil to this parameter then the image will be procesed syncronously
        @note if you pass in a block then you should make your api call inside of this callback
        @note the finishedProcessingHandler passes back a weak reference to this request. Use that when sending the request
 
 @return Returns a bool if a synchronous encoding was successful or not. If async, it returns NO always
 
 */

- (BOOL)setImage:(UIImage *)image filename:(NSString *)filename fileType:(SEUSFileType)fileType finishedProcessingHander:(SEUSImageProcessCompletionHandler)finishedProcessingHandler;



@end
