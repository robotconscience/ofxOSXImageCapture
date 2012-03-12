//
//  DeviceManager.cpp
//  TetheredCapture
//
//  Created by Brett Renfer on 3/11/12.
//  Copyright (c) 2012 Robotconscience. All rights reserved.
//

#import "DeviceManager.h"

@implementation DeviceManagerDelegate

// This a little sketchy, but useful
ofxOSXImageCapture::DeviceManager * ofParent = NULL;

// synthesize the getters and setters for camera properties
@synthesize cameras;
@synthesize doneListing;

- (void) initWithOFHandler:(ofxOSXImageCapture::DeviceManager*) h{
    ofParent = h;
}

// DO THIS FIRST!
- (void)listCameras
{
    cameras = [[NSMutableArray alloc] initWithCapacity:0];
    
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
    //        [mDeviceBrowser stop];  
    //        [mDeviceBrowser release];         
    //        [cameras release];
    //        mDeviceBrowser.delegate = NULL;
}

// return all current devices
- (NSArray *) currentDevices{
    return mDeviceBrowser.devices;
}

// return all current cameras
- (NSArray *) currentCameras{
    return cameras;
}

// Method delegates for device added and removed
//
// Device browser maintains list of cameras as key-value pairs, so delegate
// must call willChangeValueForKey to modify list
- (void)deviceBrowser:(ICDeviceBrowser*)browser didAddDevice:(ICDevice*)addedDevice moreComing:(BOOL)moreComing
{    
    if ( addedDevice.type & ICDeviceTypeCamera ){
        
        // implement manual observer notification for the cameras property
        [self willChangeValueForKey:@"cameras"];
        [cameras addObject:addedDevice];
        [self didChangeValueForKey:@"cameras"];
        
        ofParent->addCamera( (ICCameraDevice *) addedDevice );
    }
    NSLog(@"Found a device");
    NSLog(@"More coming? %@", moreComing?@"YES":@"NO");
    self.doneListing = !moreComing;
}

// Callback when removed a device
- (void)deviceBrowser:(ICDeviceBrowser*)browser didRemoveDevice:(ICDevice*)device moreGoing:(BOOL)moreGoing
{
    device.delegate = NULL;
    
    // implement manual observer notification for the cameras property
    [self willChangeValueForKey:@"cameras"];
    [cameras removeObject:device];
    [self didChangeValueForKey:@"cameras"];
}

- (void)deviceBrowser:(ICDeviceBrowser*)browser deviceBrowserDidEnumerateLocalDevices:(ICDeviceBrowser*)brows{
};

@end;

namespace ofxOSXImageCapture {
        
    //--------------------------------------------------------------
    DeviceManager::DeviceManager(){
        state = STATE_WAITING;
        bDoneListing = bDeviceReady = bTakingImage = false;
        captureControl = [DeviceManagerDelegate alloc];
        [captureControl initWithOFHandler:this];
    };

    //--------------------------------------------------------------
    DeviceManager::~DeviceManager(){
        [captureControl exit];
    };

    //--------------------------------------------------------------
    void DeviceManager::listDevices(){
        ofLog( OF_LOG_VERBOSE, "listing devices" );
        [captureControl listCameras];
        state = STATE_LISTING_DEVICES;
        startThread(false, false);
    }

    //--------------------------------------------------------------
    bool DeviceManager::doneListing(){
        return bDoneListing;
    };
    
    //--------------------------------------------------------------
    void DeviceManager::threadedFunction(){
        if ( state == STATE_LISTING_DEVICES ){
            while ( ![captureControl isDoneListing] ){
            }
            bDoneListing = true;
            NSArray * devices = [captureControl currentDevices];
            ofLog(OF_LOG_VERBOSE, "found "+ofToString([devices count])+" devices");
            state = STATE_WAITING;
        }
    }
    
    //--------------------------------------------------------------
    void DeviceManager::addCamera( ICCameraDevice * camera ){
        cout<<"add camera"<<endl;
        Camera * cam = new Camera(camera);
        // init delegate
        
        CameraDelegate * delegate = [CameraDelegate alloc];
        
        [delegate initWithDevice:camera camera:cam];
        cameraDelegates.push_back( delegate );
        cameras.push_back( cam );
    };
    
    //--------------------------------------------------------------
    Camera * DeviceManager::openCamera( int index ){
        if (index < cameras.size() ){
            cameras[ index ]->open();
            return cameras[ index ];
        } else {
            return NULL;
        }
    }
    
    //--------------------------------------------------------------
    Camera * DeviceManager::getCamera( int index ){
        if (index < cameras.size() ){
            return cameras[ index ];
        } else {
            return NULL;
        }
    }
    
    //--------------------------------------------------------------
    vector<Camera *> * DeviceManager::getCameras(){
        return &cameras;
    }
}