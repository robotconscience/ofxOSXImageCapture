//
//  Camera.h
//  TetheredCapture
//
//  Created by Brett Renfer on 3/11/12.
//  Copyright (c) 2012 Robotconscience. All rights reserved.
//

#pragma once

#include "ofMain.h"

#import <Cocoa/Cocoa.h>
#import <ImageCaptureCore/ImageCaptureCore.h>

@interface CameraDelegate : NSObject
// Create delegates for the device browser and camera device classes.
<ICDeviceDelegate, ICCameraDeviceDelegate> {
    
    BOOL    bReady;
    BOOL    bTakingPhotos;
    ICCameraDevice * device;
}

@property (readwrite, getter=isReady)  BOOL  bReady;
@property (readwrite, getter=isTakingPhotos) BOOL bTakingPhotos;
@property (readwrite) ICCameraDevice * device;

-(void) takePicture;

@end

namespace ofxOSXImageCapture {
    class Camera {
    public: 
        
        Camera ( ICCameraDevice * _cocoaCamera );
        
        void open();
        void close();
        void takePicture();
        
        bool isReady();
        bool isTakingPicture();
        bool canTakePicture();
        
        // get all images taken since opening the camera
        vector <string> getImages();
        
        // access to lower-level ICCameraItems
        vector<ICCameraItem *> getNewItems();
        vector<ICCameraItem *> getExistingItems();
        
    // please don't call these... they are called from the delegate
        
        void foundImage( ICCameraItem* image );         // 1: found existing images
        void capturedImage( ICCameraItem* image );      // 2: found new image you've captured
        void downloadedImage( ICCameraItem* image );    // 3: downloaded new image to bin
        
        void onDeviceRemoved();
        void onDeviceReady();
        
    private:
        
        vector <ICCameraItem *> existingFiles;
        vector <ICCameraItem *> newFiles;
        
        vector <string> downloadedImages;
        
        bool bOpen, bOpening, bClosing, bActive, bTakingPicture;
        string currentImage;
        ICCameraDevice * cocoaCamera;
    };
};
