## SEUSFileUploadRequest


**Purpose**: Allows easy uploading of a UIImage to a web server by emulating an html file input

** Key Features **

* Easily used with all of Cocoas URLConnection Classes
* Asyncronous Image Processing so your larger images don't block the main thread as they are preparing to be sent.
* Mimics a file input request at the server.
* Super easy to implement

** Notes **

* Currently only works with jpg and png file types

* * *

### USAGE ###



#### Asyncronous Image Processing #####

Create The request with a URL:
	
	SEUSFileUploadRequest *asyncRequest = [[SEUSFileUploadRequest alloc] initWithURL:[NSURL URLWithString:URL]];
                
Populate that request with your data and start your URLConnection within the callback
        
        [asyncRequest setImage:_imageView.image filename:@"My Upload" fileType:SEUSFileTypePNG 
      										          finishedProcessingHander:^(BOOL success, id weakRequest) {
            _connection = [[NSURLConnection alloc] initWithRequest:weakRequest delegate:self];
        }];

#### Synchronous Image Processing ####

Create The request with a URL:
	
	SEUSFileUploadRequest *syncRequest = [[SEUSFileUploadRequest alloc] initWithURL:[NSURL URLWithString:URL]
                                                                              image:_imageView.image
                                                                           filename:@"My Upload"
                                                                        andFileType:SEUSFileTypePNG];
                                                                        
Start that request with a connection just like you would a normal NSURLRequest and a NSURLConnection

         _connection = [[NSURLConnection alloc] initWithRequest:syncRequest delegate:self];
             




