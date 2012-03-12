//
//  DeviceManager.h
//  TetheredCapture
//
//  Created by Brett Renfer on 3/11/12.
//  Copyright (c) 2012 Robotconscience. All rights reserved.
//

#pragma once

#import <ImageCaptureCore/ImageCaptureCore.h>
#include "ofMain.h"
#include "Camera.h"

@interface DeviceManagerDelegate : NSObject
// Create delegates for the device browser and camera device classes.
<ICDeviceBrowserDelegate> {
    
    // Create an instance variable for the device browser
    // and an array for the cameras the browser finds
    ICDeviceBrowser * mDeviceBrowser;
    NSMutableArray * cameras;
    
    BOOL    doneListing;
}

// Cameras are properties of the device browser stored in an array
@property(retain)   NSMutableArray* cameras;
@property (readwrite, getter=isDoneListing)         BOOL  doneListing;

- (void) exit; //not working right now ;/

- (NSArray *) currentDevices; 

- (void) listCameras;

@end


namespace ofxOSXImageCapture {
        
    enum {
        STATE_WAITING,
        STATE_LISTING_DEVICES,
        STATE_CONNECTING_DEVICE
    };
    
    class DeviceManager : public ofThread {
        public:
            DeviceManager();
            ~DeviceManager();
            
            void listDevices();
            bool doneListing();  
            
            Camera * openCamera( int index=0 );
        
            void addCamera( ICCameraDevice * camera );
            Camera * getCamera( int index=0 );
            vector<Camera *> * getCameras();
            
            DeviceManagerDelegate * captureControl;
            
        private:
            void threadedFunction();
            bool bDoneListing, bDeviceReady, bTakingImage;
        
            vector <Camera *> cameras;
        vector <CameraDelegate *> cameraDelegates;
            
            string  currentImage;
            int     deviceId;
            int     state;
 
    };
    
};