//
//  KICubeThumbnailDownloadOperationHandler.m
//  KiCube
//
//  Created by Vibhakar Shukla on 31/08/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "KICubeThumbnailDownloadOperationHandler.h"
#import "KiCubeRequestHandler.h"
#import "Media.h"

@implementation KICubeThumbnailDownloadOperationHandler

@synthesize url;
@synthesize mediaID, singleThumbnailUpdate;

-(id)initWithURL:(NSURL *)newURL forMediaID:(NSNumber *)newDownloadPath
{
    self = [super init];
    if (self) {
        self.url = newURL;
        self.mediaID = newDownloadPath;
    }
    
    return self;
}

-(void)main {
    if ( self.isCancelled ) return;
    if ( nil == self.url ) return;
    /*
     NSString *theCredentials = [NSString stringWithFormat:THUMBNAIL_DOWNLOAD_URL,mediaID];
     NSString *theDownloadService = [KICUBE_BASE_URL stringByAppendingString:theCredentials];
     // NSString *URLString = [[NSString alloc] initWithFormat:@"http://www.kicube.com/kicube/thumbnail?mediaId=%@",mediaID];
     NSURL *thumbnailURL = [[NSURL alloc] initWithString:theDownloadService];
     */
    failed = NO;
    NSMutableURLRequest *requestForThumbnail = [NSMutableURLRequest requestWithURL:self.url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
    
    
    NSError *ThumbnailError = nil;
    NSHTTPURLResponse *Thumbnailresponse;
    thumbanailData = [NSURLConnection sendSynchronousRequest:requestForThumbnail returningResponse:&Thumbnailresponse error:&ThumbnailError];
    
    NSDictionary *Thumbnaildictionary = [Thumbnailresponse allHeaderFields];
    NSString *ThumbnailDownloadEtag = nil;
    if([Thumbnaildictionary objectForKey:kEtag] != nil)
    {
        ThumbnailDownloadEtag = [Thumbnaildictionary objectForKey:kEtag];
        ThumbnailDownloadEtag = [ThumbnailDownloadEtag stringByReplacingOccurrencesOfString:@"\"" withString:@""];
    }
    //NSURLConnection *connection = [[NSURLConnection alloc]initWithRequest:request delegate:self];
    Media *theMediaInfo = nil;
    NSArray *theMediaDataInfo = [KiCubeCoreDataModel getTheResultsForTheEntity:kMedia andItsPredicate:self.mediaID WithPredicateKey:kmediaID WithSortDescriptor:kmediaName];
    if(theMediaDataInfo.count > 0 )
    {
        theMediaInfo = [theMediaDataInfo objectAtIndex:0];
        if(ThumbnailDownloadEtag.length > 0)
        {
            theMediaInfo.thumbnailDownloadVersion = ThumbnailDownloadEtag;
        }
        
    }
    
    if ( self.isCancelled ) return;
    
    
    if (ThumbnailError) {
        /*UIAlertView *theOfflineAlert = [[UIAlertView alloc]initWithTitle:ERROR_HEADER_TEXT message:@"The connection with the server was lost unexpectedly. Please check your internet connectivity." delegate:self cancelButtonTitle:NSLocalizedString(kOK, @"") otherButtonTitles: nil];
         [theOfflineAlert show];
         [theOfflineAlert release];*/
        
        [self performSelectorOnMainThread:@selector(launchAnConnectionFailedAlertInCaseofError) withObject:nil waitUntilDone:YES];
        
        failed = YES;
        
        //return;
    }
    
    if ( failed == NO)
    {
        [self performSelectorOnMainThread:@selector(callDownloadDone) withObject:nil waitUntilDone:YES];
    }
    else{
        [[KiCubeRequestHandler sharedRequestHandler]cancelOperationQueueOperations];
        [KiCubeCoreDataModel setIsDownloadingFactorOfAllEntitiesToZero];
    }
    
}

-(void)callDownloadDone
{
    
    //[[KiCubeRequestHandler sharedRequestHandler] handleDownloadResponseforSingleMedia:imageData withMediaID:self.mediaID TotalMediaCount:self.totalMediaCount];
    
    if (self.singleThumbnailUpdate ==YES) {
        
        [[KiCubeRequestHandler sharedRequestHandler] handleThumbanailDownloadResponseWithDataForSingleThumbnailUpdate:thumbanailData MediaID:mediaID];
    }
    else{
        [[KiCubeRequestHandler sharedRequestHandler] handleThumbanailDownloadResponseWithData:thumbanailData MediaID:mediaID];
        
    }
    
    
}

-(void)launchAnConnectionFailedAlertInCaseofError
{
    UIAlertView *theOfflineAlert = [[UIAlertView alloc]initWithTitle:NSLocalizedString(ERROR_HEADER_TEXT, @"") message:NSLocalizedString(kServerConnectionErrorMSG, @"") delegate:nil cancelButtonTitle:NSLocalizedString(kOK, @"") otherButtonTitles: nil];
    [theOfflineAlert show];
}

@end
