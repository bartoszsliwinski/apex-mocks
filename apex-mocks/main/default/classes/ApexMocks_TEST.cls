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

        String arg1 = 'asdf';
        Integer arg2 = 123;
        Decimal expectedResponse = 30.2;

        mocks.startStubbing();
        mocks.when(service.nonVoidMethod(arg1, arg2)).thenReturn(expectedResponse);
        mocks.stopStubbing();

        // When
        Test.startTest();
        Object response = service.nonVoidMethod(arg1, arg2);
        Test.stopTest();

        // Then
        System.assertEquals(expectedResponse, response);
        ((ApexMocks_TestServiceClass) mocks.verify(service, 1))
            .nonVoidMethod(arg1, arg2);
        ((ApexMocks_TestServiceClass) mocks.captureArguments(service))
            .nonVoidMethod(null, null);
        System.assertEquals(arg1, mocks.getArgument(0));
        System.assertEquals(arg2, mocks.getArgument(1));
    }

    @IsTest
    static void shouldNotMatchAnyArgument_whenNotChosenTo() {
        // Given
        ApexMocks mocks = new ApexMocks();
        ApexMocks_TestServiceClass service = (ApexMocks_TestServiceClass) mocks.mock(ApexMocks_TestServiceClass.class);

        String arg1 = 'asdf';
        Integer arg2 = 123;
        Decimal expectedResponse = 30.2;

        mocks.startStubbing();
        mocks.when(service.nonVoidMethod(arg1, arg2)).thenReturn(expectedResponse);
        mocks.stopStubbing();

        Integer actualArg1 = 1243123;
        String actualArg2 = 'dawdwa';

        // When
        Test.startTest();
        Object response = service.nonVoidMethod(actualArg1, actualArg2);
        Test.stopTest();

        // Then
        System.assertNotEquals(expectedResponse, response);
        System.assertEquals(null, response);
        ((ApexMocks_TestServiceClass) mocks.verify(service, 0))
            .nonVoidMethod(arg1, arg2);
        ((ApexMocks_TestServiceClass) mocks.captureArguments(service))
            .nonVoidMethod(null, null);
        System.assertEquals(actualArg1, (Integer) mocks.getArgument(0));
        System.assertEquals(actualArg2, (String) mocks.getArgument(1));
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

        String actualArg1 = '321321321';
        Integer actualArg2 = 2321321;

        // When
        Test.startTest();
        Object response = service.nonVoidMethod(actualArg1, actualArg2);
        Test.stopTest();

        // Then
        System.assertEquals(expectedResponse, response);
        ((ApexMocks_TestServiceClass) mocks.verify(service, 1))
            .nonVoidMethod('dwadwa', 124433);
        ((ApexMocks_TestServiceClass) mocks.captureArguments(service))
            .nonVoidMethod(null, null);
        System.assertEquals(actualArg1, (String) mocks.getArgument(0));
        System.assertEquals(actualArg2, (Integer) mocks.getArgument(1));
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
        System.assertEquals(actualArg, (String) mocks.getArgument(0));
    }

    @IsTest
    static void shouldThrowException() {
        // Given
        ApexMocks mocks = new ApexMocks();
        ApexMocks_TestServiceClass service = (ApexMocks_TestServiceClass) mocks.mock(ApexMocks_TestServiceClass.class);

        String arg1 = 'asdf';
        Integer arg2 = 123;

        mocks.startStubbing();
        mocks.when(service.nonVoidMethod(arg1, arg2)).thenThrow(new DmlException('an exception'));
        mocks.stopStubbing();

        // When
        Test.startTest();
        Exception ex;
        try {
            service.nonVoidMethod(arg1, arg2);
        } catch (Exception e) {
            ex = e;
        }
        Test.stopTest();

        // Then
        System.assertNotEquals(null, ex);
    }

}