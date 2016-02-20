/*
 * Copyright 2016 Open mHealth
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#import <Foundation/Foundation.h>

FOUNDATION_EXPORT NSString *const OMHErrorDomain;

/**
 Error types for Granola used to identify different problematic conditions within the library.
 */
typedef NS_ENUM(NSInteger, OMHErrorCode) {
    
    /** Indicates that the sample type is a valid type, but not currently supported by Granola.*/
    OMHErrorCodeUnsupportedType = 1000,
    
    /** Indicates that the input value is not supported by the specific method in Granola.*/
    OMHErrorCodeUnsupportedValues = 1001,
    
    /** Indicates that the sample type is the incorrect type for the specific method or serializer.*/
    OMHErrorCodeIncorrectType = 1002
};

