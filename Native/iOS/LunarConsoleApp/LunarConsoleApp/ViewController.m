//
//  ViewController.m
//
//  Lunar Unity Mobile Console
//  https://github.com/SpaceMadness/lunar-unity-console
//
//  Copyright 2015 Alex Lementuev, SpaceMadness.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

#import "ViewController.h"

#import "Lunar.h"
#import "Data.h"

static const NSUInteger kConsoleCapacity = 1024;

@interface ViewController ()
{
    LUConsolePlugin * _plugin;
    NSUInteger _index;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _plugin = [[LUConsolePlugin alloc] initWithCapacity:kConsoleCapacity];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self showConsoleController];
        
        _index = 0;
        [self logNextMessage];
    });
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark Actions

- (IBAction)onShowController:(id)sender
{
    [self showConsoleController];
}

- (IBAction)onShowAlert:(id)sender
{
    [self showAlert];
}

#pragma mark -
#pragma mark Helpers

- (void)showConsoleController
{
    [_plugin show];
}

- (void)showAlert
{
    NSString *message = @"Exception: Error!";
    NSString *stackTrace = @"Logger.LogError () (at Assets/Logger.cs:15)\n \
    UnityEngine.Events.InvokableCall.Invoke (System.Object[] args)\n \
    UnityEngine.Events.InvokableCallList.Invoke (System.Object[] parameters)\n \
    UnityEngine.Events.UnityEventBase.Invoke (System.Object[] parameters)\n \
    UnityEngine.Events.UnityEvent.Invoke ()\n \
    UnityEngine.UI.Button.Press () (at /Users/builduser/buildslave/unity/build/Extensions/guisystem/UnityEngine.UI/UI/Core/Button.cs:35)\n \
    UnityEngine.UI.Button.OnPointerClick (UnityEngine.EventSystems.PointerEventData eventData) (at /Users/builduser/buildslave/unity/build/Extensions/guisystem/UnityEngine.UI/UI/Core/Button.cs:44)\n \
    UnityEngine.EventSystems.ExecuteEvents.Execute (IPointerClickHandler handler, UnityEngine.EventSystems.BaseEventData eventData) (at /Users/builduser/buildslave/unity/build/Extensions/guisystem/UnityEngine.UI/EventSystem/ExecuteEvents.cs:52)\n \
    UnityEngine.EventSystems.ExecuteEvents.Execute[IPointerClickHandler] (UnityEngine.GameObject target, UnityEngine.EventSystems.BaseEventData eventData, UnityEngine.EventSystems.EventFunction`1 functor) (at /Users/builduser/buildslave/unity/build/Extensions/guisystem/UnityEngine.UI/EventSystem/ExecuteEvents.cs:269)\n \
    UnityEngine.EventSystems.EventSystem:Update()";
    
    [_plugin logMessage:message stackTrace:stackTrace type:LUConsoleLogTypeException];
}

- (void)logNextMessage
{
    NSString *message = [[Data messages] objectAtIndex:_index];
    LUConsoleLogType type;
    if ([message hasPrefix:@"E/"])
    {
        type = LUConsoleLogTypeException;
    }
    else if ([message hasPrefix:@"W/"])
    {
        type = LUConsoleLogTypeWarning;
    }
    else
    {
        type = LUConsoleLogTypeLog;
    }
    
    [_plugin logMessage:message stackTrace:nil type:type];
    _index = (_index + 1) % [Data messages].count;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self logNextMessage];
    });
}

@end