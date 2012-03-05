//
//  ImageCaptureControl.h
//  ChromatcCapture
//
//  Created by Brett Renfer on 3/4/12.
//  Copyright (c) 2012 Robotconscience. All rights reserved.
//

#pragma once

#import <Foundation/Foundation.h>

#import <Cocoa/Cocoa.h>
#import <ImageCaptureCore/ImageCaptureCore.h>

@interface ImageCaptureControl : NSObject
// Create delegates for the device browser and camera device classes.
<ICDeviceBrowserDelegate, ICCameraDeviceDelegate, ICCameraDeviceDownloadDelegate> {
    
    // Create an instance variable for the device browser
    // and an array for the cameras the browser finds
    ICDeviceBrowser * mDeviceBrowser;
    NSMutableArray * mCameras;
    
    BOOL    bDoneListing;
    BOOL    bCurrentDeviceReady;
    BOOL    bTakingPhotos;
    int     _currentDevice;
}

// Cameras are properties of the device browser stored in an array
@property(retain)   NSMutableArray* cameras;

@property (readwrite, getter=getCurrentDeviceIndex) int currentDevice;
@property (readwrite, getter=isDoneListing)         BOOL  doneListing;
@property (readwrite, getter=isCurrentDeviceReady)  BOOL  currentDeviceReady;
@property (readwrite) BOOL isTakingPhotos;

- (void) exit; //not working right now ;/

- (NSArray *) currentDevices; 

- (void) listCameras;
- (BOOL) openCamera:(int)ID;
- (BOOL) closeCamera:(int)ID;
- (void) takePicture:(int)ID;

@end
