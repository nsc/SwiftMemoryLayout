//
//  memoryLayout.m
//  SwiftMemoryLayout
//
//  Created by Nico Schmidt on 20.07.14.
//  Copyright (c) 2014 Nico Schmidt. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <objc/runtime.h>

NSString *hexDumpString(void *memory, size_t size)
{
    NSMutableString *hexDump = [NSMutableString new];
    
    uint64_t v;

    for (size_t i = 0; i < size; i += sizeof(v))
    {
        memcpy(&v, memory + i, sizeof(v));
        [hexDump appendFormat:@"%016llx ", v];
        
        if (i > 0 && i % 32 == 0)
        {
            [hexDump appendString:@"\n"];
        }
    }
    
    return hexDump;
}


NSString *ivarsString(Class objectClass)
{
    NSMutableString *ivarsString = [NSMutableString new];
    
    unsigned int numberOfIvars;
    Ivar *ivars = class_copyIvarList(objectClass, &numberOfIvars);
    for (unsigned int i = 0; i < numberOfIvars; ++i)
    {
        NSMutableString *description = [NSMutableString new];

        Ivar ivar = ivars[i];
        [description appendFormat:@"%s", ivar_getName(ivar)];
        const char *type = ivar_getTypeEncoding(ivar);
        if (type != NULL) {
            [description appendFormat:@" %s", type];
        }
        
        [ivarsString appendFormat:@"    Ivar: %@\n", description];
    }
    
    free(ivars);
    
    return ivarsString;
}

NSString *propertiesString(Class objectClass)
{
    NSMutableString *propertiesString = [NSMutableString new];
    
    unsigned int numberOfProperties;
    objc_property_t *properties = class_copyPropertyList(objectClass, &numberOfProperties);
    for (unsigned int i = 0; i < numberOfProperties; ++i)
    {
        NSMutableString *propertyString = [NSMutableString new];
        
        objc_property_t property = properties[i];
        [propertyString appendFormat:@"%s", property_getName(property)];
        [propertyString appendFormat:@" %s", property_getAttributes(property)];
    
        [propertiesString appendFormat:@"    Property: %@\n", propertyString];
    }
    
    free(properties);
    
    return propertiesString;
}

NSString *methodsString(Class objectClass)
{
    NSMutableString *methodsString = [NSMutableString new];
    
    unsigned int numberOfMethods;
    Method *methods = class_copyMethodList(objectClass, &numberOfMethods);
    for (unsigned int i = 0; i < numberOfMethods; ++i)
    {
        NSMutableString *description = [NSMutableString new];

        Method method = methods[i];
        [description appendFormat:@"%s", sel_getName(method_getName(method))];
        [description appendFormat:@" %s", method_getTypeEncoding(method)];
        
        [methodsString appendFormat:@"    Method: %@\n", description];
    }
    
    free(methods);
    
    return methodsString;
}

NSString *objectLayoutDescription(id object)
{
    Class objectClass = object_getClass(object);

    NSMutableString *description = [NSMutableString new];

    size_t instanceSize = class_getInstanceSize(objectClass);
    [description appendFormat:@"%@\n", hexDumpString((__bridge void *)object, instanceSize)];

    while (objectClass != nil)
    {
        NSString *className = [NSString stringWithUTF8String:class_getName(objectClass)];
        
        [description appendFormat:@"class %@:\n", className];
        
        [description appendString:ivarsString(objectClass)];
        [description appendString:propertiesString(objectClass)];
        [description appendString:methodsString(objectClass)];
        
        [description appendString:@"\n"];
        
        objectClass = class_getSuperclass(objectClass);
    }
    
    return description;
}