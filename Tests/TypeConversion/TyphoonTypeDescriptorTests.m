////////////////////////////////////////////////////////////////////////////////
//
//  JASPER BLUES
//  Copyright 2013 Jasper Blues
//  All Rights Reserved.
//
//  NOTICE: Jasper Blues permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////

#import <SenTestingKit/SenTestingKit.h>
#import "TyphoonTypeDescriptor.h"
#import "NSObject+TyphoonIntrospectionUtils.h"
#import "Quest.h"
#import "Knight.h"

typedef struct
{
    int foo;
    char bar[255];
} SomeStructType;

@interface TyphoonTypeDescriptorTests : SenTestCase

@property BOOL aBoolProperty;
@property NSURL* anNSURLProperty;
@property id<Quest> aQuestProperty;

@property(nonatomic, readonly) char charProperty;
@property(nonatomic, readonly) int intProperty;
@property(nonatomic, readonly) short shortProperty;
@property(nonatomic, readonly) long longProperty;
@property(nonatomic, readonly) NSUInteger* pointerToLongLongProperty;
@property(nonatomic, readonly) SomeStructType structProperty;

@end

@implementation TyphoonTypeDescriptorTests

- (void) test_type_description_primitive
{
    TyphoonTypeDescriptor* descriptor = [self typeForPropertyWithName:@"aBoolProperty"];
    assertThatBool([descriptor isPrimitive], equalToBool(YES));
    assertThat([descriptor typeBeingDescribed], nilValue());
    assertThat([descriptor protocol], nilValue());
    assertThatBool([descriptor isArray], equalToBool(NO));
    assertThatInt([descriptor arrayLength], equalToInt(0));

    NSString* description = [descriptor description];
    assertThat(description, equalTo(@"Type descriptor for primitive: 1"));
}

- (void)test_type_description_class
{
    TyphoonTypeDescriptor* descriptor = [self typeForPropertyWithName:@"anNSURLProperty"];
    assertThatBool([descriptor isPrimitive], equalToBool(NO));
    assertThat([descriptor typeBeingDescribed], equalTo([NSURL class]));
    assertThat([descriptor protocol], nilValue());

    NSString* description = [descriptor description];
    assertThat(description, equalTo(@"Type descriptor: NSURL"));
}

- (void)test_type_description_protocol
{
    TyphoonTypeDescriptor* descriptor = [self typeForPropertyWithName:@"aQuestProperty"];
    assertThatBool([descriptor isPrimitive], equalToBool(NO));
    assertThat([descriptor typeBeingDescribed], nilValue());
    assertThat([descriptor protocol], equalTo(@protocol(Quest)));

    NSString* description = [descriptor description];
    assertThat(description, equalTo(@"Type descriptor: id<Quest>"));
}

- (void)test_typeForPropertyWithName_char
{
    TyphoonTypeDescriptor* descriptor = [self typeForPropertyWithName:@"charProperty"];
    assertThatBool(descriptor.isPrimitive, equalToBool(YES));
    assertThatInt(descriptor.primitiveType, equalToInt(TyphoonPrimitiveTypeChar));
}

- (void)test_typeForPropertyWithName_int
{
    TyphoonTypeDescriptor* descriptor = [self typeForPropertyWithName:@"intProperty"];
    assertThatBool(descriptor.isPrimitive, equalToBool(YES));
    assertThatBool(descriptor.isPointer, equalToBool(NO));
    assertThatInt(descriptor.primitiveType, equalToInt(TyphoonPrimitiveTypeInt));
}

- (void)test_typeForPropertyWithName_short
{
    TyphoonTypeDescriptor* descriptor = [self typeForPropertyWithName:@"shortProperty"];
    assertThatBool(descriptor.isPrimitive, equalToBool(YES));
    assertThatBool(descriptor.isPointer, equalToBool(NO));
    assertThatInt(descriptor.primitiveType, equalToInt(TyphoonPrimitiveTypeShort));
}

- (void)test_typeForPropertyWithName_long
{
    TyphoonTypeDescriptor* descriptor = [self typeForPropertyWithName:@"longProperty"];
    assertThatBool(descriptor.isPrimitive, equalToBool(YES));
    assertThatBool(descriptor.isPointer, equalToBool(NO));
}

- (void)test_typeForPropertyWithName_pointerToLongLong
{
    TyphoonTypeDescriptor* descriptor = [self typeForPropertyWithName:@"pointerToLongLongProperty"];
    assertThatBool(descriptor.isPrimitive, equalToBool(YES));
    assertThatBool(descriptor.isPointer, equalToBool(YES));
}

- (void)test_typeForPropertyWithName_struct
{
    TyphoonTypeDescriptor* descriptor = [self typeForPropertyWithName:@"structProperty"];
    assertThatBool(descriptor.isPrimitive, equalToBool(YES));
    assertThatBool(descriptor.isPointer, equalToBool(NO));
    assertThatBool(descriptor.isStructure, equalToBool(YES));
    assertThat(descriptor.structureTypeName, equalTo(@"?=i[255c]"));
}

- (void)test_parameterNamesForSelector_init_method
{
    NSArray* parameterNames = [self parameterNamesForSelector:@selector(initWithNibName:bundle:)];
    NSLog(@"Parameter names: %@", parameterNames);
    assertThat(parameterNames, hasCountOf(2));
    assertThat([parameterNames objectAtIndex:0], equalTo(@"nibName"));
    assertThat([parameterNames objectAtIndex:1], equalTo(@"bundle"));
}

- (void)test_parameterNamesForSelector_factory_method
{
    NSArray* parameterNames = [self parameterNamesForSelector:@selector(URLWithString:)];
    NSLog(@"Parameter names: %@", parameterNames);
    assertThat(parameterNames, hasCountOf(1));
    assertThat([parameterNames objectAtIndex:0], equalTo(@"string"));
}

- (void)test_typeCodesForSelectorWithName
{
    Knight* knight = [[Knight alloc] initWithQuest:nil damselsRescued:0];
    NSArray* typeCodes = [knight typeCodesForSelector:@selector(initWithQuest:damselsRescued:)];

    NSLog(@"Here's the typeCodes: %@", typeCodes);
    assertThat([typeCodes objectAtIndex:0], equalTo(@"@"));


    TyphoonTypeDescriptor* typeDescriptor = [TyphoonTypeDescriptor descriptorWithTypeCode:[typeCodes objectAtIndex:1]];
    assertThatBool(typeDescriptor.isPrimitive, equalToBool(YES));
}

@end