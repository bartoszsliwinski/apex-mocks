@IsTest(IsParallel=true)
private class ExampleController_TEST {

    @IsTest
    static void shouldReturnCalculatedOpp() {
        // Given
        ApexMocks mocks = new ApexMocks();
        ExampleService serviceMock = (ExampleService) mocks.mock(ExampleService.class);

        Id oppId = ApexMocksUtils.generateId(Opportunity.SObjectType);

        mocks.startStubbing();
        mocks.when(serviceMock.getDiscount(oppId)).thenReturn(0.2);
        mocks.stopStubbing();

        Application.service.setMock(ExampleService.class, serviceMock);

        // When
        Test.startTest();
        Opportunity calculatedOpp = ExampleController.getCalculatedOpportunity(oppId, 10);
        Test.stopTest();

        // Then
        Assert.areEqual(8, calculatedOpp.Amount);
        ((ExampleService) mocks.verify(serviceMock, 1))
            .getDiscount(oppId);
        ((ExampleService) mocks.captureArguments(serviceMock))
            .getDiscount(null);
        Assert.areEqual(oppId, mocks.getArguments()[0]);

    }

    @IsTest
    static void shouldThrowAuraHandledException() {
        // Given
        ApexMocks mocks = new ApexMocks();
        ExampleService serviceMock = (ExampleService) mocks.mock(ExampleService.class);

        Id oppId = ApexMocksUtils.generateId(Opportunity.SObjectType);

        mocks.startStubbing();
        ((ExampleService) mocks.throwWhen(new CalloutException('Something went wrong'), serviceMock)).getDiscount(oppId);
        mocks.stopStubbing();

        Application.service.setMock(ExampleService.class, serviceMock);

        Exception ex;

        // When
        Test.startTest();
        try {
            ExampleController.getCalculatedOpportunity(oppId, 10);
        }
        catch (Exception e) {
            ex = e;
        }
        Test.stopTest();

        // Then
        Assert.isNotNull(ex);
        Assert.isInstanceOfType(ex, AuraHandledException.class);

    }

}
