//
//  CameraDelegate.m
//  ALIS
//
//  Created by Strong, Shadrian B. on 10/15/14.
//  Copyright (c) 2014 ALIS. All rights reserved.
//

#import <AVFoundation/AVCaptureSession.h>
#import <AVFoundation/AVCaptureDevice.h> // For access to the camera
#import "CameraDelegate.h"
#import <AVFoundation/AVCaptureInput.h> // For adding a data input to the camera
#import <AVFoundation/AVCaptureOutput.h> // For capturing frames
#import <CoreVideo/CVPixelBuffer.h> // for using pixel format types

AVCaptureDevice * m_camera; // A pointer to the front or to the back camera
AVCaptureDeviceInput * m_cameraInput; // This is the data input for the camera that allows us to capture frames
@interface CameraDelegate()
{
@private
    AVCaptureSession * m_captureSession; // Lets us set up and control the camera
}
@end

@implementation CameraDelegate

- ( BOOL ) findCamera: ( BOOL ) useFrontCamera
{
    // 0. Make sure we initialize our camera pointer:
    m_camera = NULL;
    
    // 1. Get a list of available devices:
    // specifying AVMediaTypeVideo will ensure we only get a list of cameras, no microphones
    NSArray * devices = [ AVCaptureDevice devicesWithMediaType: AVMediaTypeVideo ];
    
    // 2. Iterate through the device array and if a device is a camera, check if it's the one we want:
    for ( AVCaptureDevice * device in devices )
    {
        if ( useFrontCamera && AVCaptureDevicePositionFront == [ device position ] )
        {
            // We asked for the front camera and got the front camera, now keep a pointer to it:
            m_camera = device;
        }
        else if ( !useFrontCamera && AVCaptureDevicePositionBack == [ device position ] )
        {
            // We asked for the back camera and here it is:
            m_camera = device;
        }
    }
    
    // 3. Set a frame rate for the camera:
    if ( NULL != m_camera )
    {
        // We firt need to lock the camera, so noone else can mess with its configuration:
        if ( [ m_camera lockForConfiguration: NULL ] )
        {
            // Set a minimum frame rate of 10 frames per second
            [ m_camera setActiveVideoMinFrameDuration: CMTimeMake( 1, 10 ) ];
            
            // and a maximum of 30 frames per second
            [ m_camera setActiveVideoMaxFrameDuration: CMTimeMake( 1, 30 ) ];
            
            [ m_camera unlockForConfiguration ];
        }
    }
    
    // 4. If we've found the camera we want, return true
    return ( NULL != m_camera );
}

- ( BOOL ) attachCameraToCaptureSession
{
    // 0. Assume we've found the camera and set up the session first:
    assert( NULL != m_camera );
    assert( NULL != m_captureSession );
    
    // 1. Initialize the camera input
    m_cameraInput = NULL;
    
    // 2. Request a camera input from the camera
    NSError * error = NULL;
    m_cameraInput = [ AVCaptureDeviceInput deviceInputWithDevice: m_camera error: &error ];
    
    // 2.1. Check if we've got any errors
    if ( NULL != error )
    {
        // TODO: send an error event to ActionScript
        return false;
    }
    
    // 3. We've got the input from the camera, now attach it to the capture session:
    if ( [ m_captureSession canAddInput: m_cameraInput ] )
    {
        [ m_captureSession addInput: m_cameraInput ];
    }
    else
    {
        // TODO: send an error event to ActionScript
        return false;
    }
    
    // 4. Done, the attaching was successful, return true to signal that
    return true;
}

@end