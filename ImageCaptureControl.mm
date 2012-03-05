//
//  ImageCaptureControl.m
//  ChromatcCapture
//
//  Created by Brett Renfer on 3/4/12.
//  Copyright (c) 2012 Robotconscience. All rights reserved.
//
#include "ofxOSXImageCapture.h"
#import "ImageCaptureControl.h"

@implementation ImageCaptureControl

ofxOSXImageCapture * ofParent = NULL;

// synthesize the getters and setters for camera properties
@synthesize cameras = mCameras;
@synthesize doneListing = bDoneListing;
@synthesize currentDeviceReady = bCurrentDeviceReady;
@synthesize currentDevice = _currentDevice;
@synthesize isTakingPhotos = bTakingPhotos;

- (void) initWithOFHandler:(ofxOSXImageCapture*) h{
    ofParent = h;
}

// DO THIS FIRST!
- (void)listCameras
{
    self.currentDevice = -1;
    self.currentDeviceReady = NO;
    self.isTakingPhotos = NO;
    
    mCameras = [[NSMutableArray alloc] initWithCapacity:0];
    
    // Get an instance of ICDeviceBrowser
    mDeviceBrowser = [[ICDeviceBrowser alloc] init];
    // Assign a delegate
    mDeviceBrowser.delegate = self;
    // Look for cameras in all available locations
    mDeviceBrowser.browsedDeviceTypeMask = mDeviceBrowser.browsedDeviceTypeMask 
    | ICDeviceTypeMaskCamera
    | ICDeviceLocationTypeMaskLocal
    | ICDeviceLocationTypeMaskShared
    | ICDeviceLocationTypeMaskBonjour
    | ICDeviceLocationTypeMaskBluetooth
    | ICDeviceLocationTypeMaskRemote;
    // Start browsing for cameras
    [mDeviceBrowser start];
}

// Stop browser and release it when done
- (void)exit{      
    if (self.currentDevice != -1){  
//        [[mCameras objectAtIndex:self.currentDevice] requestCloseSession];
//        [mDeviceBrowser stop];  
//        [mDeviceBrowser release];         
//        [mCameras release];
//        mDeviceBrowser.delegate = NULL;
    }       
}

//
- (NSArray *) currentDevices{
    return mDeviceBrowser.devices;
}

//
- (BOOL) openCamera:(int) ID{
    if ([mCameras count] >= ID+1){
        if (self.currentDevice != -1){
            [[mCameras objectAtIndex:self.currentDevice] requestCloseSession];
        }
        self.currentDeviceReady = NO;
        self.currentDevice = ID;
        [[mCameras objectAtIndex:ID] requestOpenSession];
        return true;
    } else {
        NSLog(@"there are not that many devices");
        return false;
    }
}

//
- (BOOL) closeCamera:(int)ID{
    if ([mCameras count] >= ID+1){
        [[mCameras objectAtIndex:ID] requestCloseSession];
        return true;
    } else {
        return false;
    }
};

//
- (void) takePicture:(int) ID {
    if ([mCameras count] >= ID){
        self.isTakingPhotos = YES;
        [[mCameras objectAtIndex:ID] requestTakePicture];
    } else {
    }
}

// CAMERA DELEGATES

- (void)cameraDevice:(ICCameraDevice*)camera didAddItem:(ICCameraItem*)item {
    if (ofParent != NULL){
        if (self.isTakingPhotos){
            NSDictionary* options = [NSDictionary dictionaryWithObject:[NSURL fileURLWithPath:[NSString stringWithUTF8String:((string)ofToDataPath("", true)).c_str()]] forKey:ICDownloadsDirectoryURL];
            
            [camera requestDownloadFile:item options:options downloadDelegate:self didDownloadSelector:@selector(didDownloadFile:error:options:contextInfo:) contextInfo:NULL];
        }
        //ofParent->gotNewImage( item );
    }
    //NSLog(@"took a picture or whatever");
}

- (void)deviceDidBecomeReady:(ICDevice*)device {
    if ( device == [mCameras objectAtIndex:self.currentDevice] ){
        NSLog(@"Device %i ready", self.currentDevice);
        self.currentDeviceReady = YES;
        [[mCameras objectAtIndex:self.currentDevice] requestEnableTethering];
    }
}

// Method delegates for device added and removed
//
// Device browser maintains list of cameras as key-value pairs, so delegate
// must call willChangeValueForKey to modify list
- (void)deviceBrowser:(ICDeviceBrowser*)browser didAddDevice:(ICDevice*)addedDevice moreComing:(BOOL)moreComing
{    
    if ( addedDevice.type & ICDeviceTypeCamera ){
        addedDevice.delegate = self;
        
        // implement manual observer notification for the cameras property
        [self willChangeValueForKey:@"cameras"];
        [mCameras addObject:addedDevice];
        [self didChangeValueForKey:@"cameras"];
    }
    NSLog(@"Found a device");
    NSLog(@"More coming? %@", moreComing?@"YES":@"NO");
    self.doneListing = !moreComing;
}


- (void)deviceBrowser:(ICDeviceBrowser*)browser didRemoveDevice:(ICDevice*)device moreGoing:(BOOL)moreGoing
{
    device.delegate = NULL;
    
    // implement manual observer notification for the cameras property
    [self willChangeValueForKey:@"cameras"];
    [mCameras removeObject:device];
    [self didChangeValueForKey:@"cameras"];
}

- (void)didRemoveDevice:(ICDevice*)removedDevice
{
}

- (void)deviceBrowser:(ICDeviceBrowser*)browser deviceBrowserDidEnumerateLocalDevices:(ICDeviceBrowser*)brows{
};

// Done downloading -- log results to console for debugging
- (void)didDownloadFile:(ICCameraFile*)file error:(NSError*)error options:(NSDictionary*)options contextInfo:(void*)contextInfo
{
    NSLog( @"didDownloadFile called with:\n" );
    NSLog( @"  file:        %@\n", file );
    NSLog( @"  error:       %@\n", error );
    NSLog( @"  options:     %@\n", options );
    NSLog( @"  contextInfo: %p\n", contextInfo );
    ofParent->gotNewImage( file );
}

@end
