/**
 * Test class for ApexMocks
 *
 * @author Bartosz Sliwinski (bsliwinski@deloittece.com)
 * @date September 2022
 */
@IsTest(IsParallel=true)
public with sharing class ApexMocks_TEST {

    @IsTest
    static void shouldMatchExactArguments() {
        // Given
        ApexMocks mocks = new ApexMocks();
        ApexMocks_TestServiceClass service = (ApexMocks_TestServiceClass) mocks.mock(ApexMocks_TestServiceClass.class);

        String argument1 = 'asdf';
        Integer argument2 = 123;
        Decimal expectedResponse = 30.2;

        mocks.startStubbing();
        mocks.when(service.nonVoidMethod(argument1, argument2)).thenReturn(expectedResponse);
        mocks.stopStubbing();

        // When
        Test.startTest();
        Object response = service.nonVoidMethod(argument1, argument2);
        Test.stopTest();

        // Then
        Assert.areEqual(expectedResponse, response);
        ((ApexMocks_TestServiceClass) mocks.verify(service, 1))
            .nonVoidMethod(argument1, argument2);
        ((ApexMocks_TestServiceClass) mocks.captureArguments(service))
            .nonVoidMethod(null, null);
        List<Object> arguments = mocks.getArguments();
        Assert.areEqual(argument1, arguments[0]);
        Assert.areEqual(argument2, arguments[1]);
    }

    @IsTest
    static void shouldNotMatchAnyArgument_whenNotChosenTo() {
        // Given
        ApexMocks mocks = new ApexMocks();
        ApexMocks_TestServiceClass service = (ApexMocks_TestServiceClass) mocks.mock(ApexMocks_TestServiceClass.class);

        String argument1 = 'asdf';
        Integer argument2 = 123;
        Decimal expectedResponse = 30.2;

        mocks.startStubbing();
        mocks.when(service.nonVoidMethod(argument1, argument2)).thenReturn(expectedResponse);
        mocks.stopStubbing();

        Integer actualArgument1 = 1243123;
        String actualArgument2 = 'dawdwa';

        // When
        Test.startTest();
        Object response = service.nonVoidMethod(actualArgument1, actualArgument2);
        Test.stopTest();

        // Then
        Assert.areNotEqual(expectedResponse, response);
        Assert.areEqual(null, response);
        ((ApexMocks_TestServiceClass) mocks.verify(service, 0))
            .nonVoidMethod(argument1, argument2);
        ((ApexMocks_TestServiceClass) mocks.captureArguments(service))
            .nonVoidMethod(null, null);
        List<Object> arguments = mocks.getArguments();
        Assert.areEqual(actualArgument1, (Integer) arguments[0]);
        Assert.areEqual(actualArgument2, (String) arguments[1]);
    }

    @IsTest
    static void shouldMatchAnyArgument_whenAnyMatchingChosen() {
        // Given
        ApexMocks mocks = new ApexMocks();
        ApexMocks_TestServiceClass service = (ApexMocks_TestServiceClass) mocks.mock(ApexMocks_TestServiceClass.class);

        Decimal expectedResponse = 30.2;

        mocks.startStubbing();
        mocks.matchAny().when(service.nonVoidMethod(null, null)).thenReturn(expectedResponse);
        mocks.stopStubbing();

        String actualArgument1 = '321321321';
        Integer actualArgument2 = 2321321;

        // When
        Test.startTest();
        Object response = service.nonVoidMethod(actualArgument1, actualArgument2);
        Test.stopTest();

        // Then
        Assert.areEqual(expectedResponse, response);
        ((ApexMocks_TestServiceClass) mocks.verify(service, 1))
            .nonVoidMethod('dwadwa', 124433);
        ((ApexMocks_TestServiceClass) mocks.captureArguments(service))
            .nonVoidMethod(null, null);
        List<Object> arguments = mocks.getArguments();
        Assert.areEqual(actualArgument1, (String) arguments[0]);
        Assert.areEqual(actualArgument2, (Integer) arguments[1]);
    }

    @IsTest
    static void shouldMatchAnyArgumentForVoidMethod_whenAnyMatchingChosen() {
        // Given
        ApexMocks mocks = new ApexMocks();
        ApexMocks_TestServiceClass service = (ApexMocks_TestServiceClass) mocks.mock(ApexMocks_TestServiceClass.class);

        String actualArg = '321321321';

        // When
        Test.startTest();
        service.voidMethod(actualArg);
        Test.stopTest();

        // Then
        ((ApexMocks_TestServiceClass) mocks.matchAny().verify(service, 1))
            .voidMethod('dwadwa');
        ((ApexMocks_TestServiceClass) mocks.captureArguments(service))
            .voidMethod(null);
        Assert.areEqual(actualArg, (String) mocks.getArguments()[0]);
    }

    @IsTest
    static void shouldThrowException() {
        // Given
        ApexMocks mocks = new ApexMocks();
        ApexMocks_TestServiceClass service = (ApexMocks_TestServiceClass) mocks.mock(ApexMocks_TestServiceClass.class);

        String argument1 = 'asdf';
        Integer argument2 = 123;

        String expectedExceptionMessage = 'an exception';

        mocks.startStubbing();
        ((ApexMocks_TestServiceClass) mocks.throwWhen(new DmlException(expectedExceptionMessage), service)).nonVoidMethod(argument1, argument2);
        mocks.stopStubbing();

        // When
        Test.startTest();
        Exception ex;
        try {
            service.nonVoidMethod(argument1, argument2);
        } catch (Exception e) {
            ex = e;
        }
        Test.stopTest();

        // Then
        Assert.isNotNull(ex);
        Assert.isInstanceOfType(ex, DmlException.class);
        Assert.areEqual(expectedExceptionMessage, ex.getMessage());
    }

    @IsTest
    static void shouldThrowException_whenAnyMatchChosen() {
        // Given
        ApexMocks mocks = new ApexMocks();
        ApexMocks_TestServiceClass service = (ApexMocks_TestServiceClass) mocks.mock(ApexMocks_TestServiceClass.class);

        String argument1 = 'asdf';
        Integer argument2 = 123;

        String expectedExceptionMessage = 'an exception';

        mocks.startStubbing();
        ((ApexMocks_TestServiceClass) mocks.matchAny().throwWhen(new DmlException(expectedExceptionMessage), service)).nonVoidMethod(argument1, argument2);
        mocks.stopStubbing();

        // When
        Test.startTest();
        Exception ex;
        try {
            service.nonVoidMethod(argument2, argument1);
        } catch (Exception e) {
            ex = e;
        }
        Test.stopTest();

        // Then
        Assert.isNotNull(ex);
        Assert.isInstanceOfType(ex, DmlException.class);
        Assert.areEqual(expectedExceptionMessage, ex.getMessage());
    }

}
