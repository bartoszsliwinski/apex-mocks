/**
 * Provides the ability to mock Apex classes. Simplified version of fflib_ApexMocks
 */
@IsTest
public inherited sharing class ApexMocks implements System.StubProvider {

    private static final String MSG_RESPONSE_OR_EXCEPTION = 'Specify either a Response or an Exception.';
    private static final String ARGUMENTS_SEPARATOR = '#@!';

    private Map<String, StubResponse> methodSignature2StubResponse = new Map<String, StubResponse>();
    private Set<String> methodsMatchingAny = new Set<String>();
    private Boolean isStubbing = false;
    private Boolean isMatchAnyArguments = false;
    private Boolean isVerifying = false;
    private Boolean isCapturing = false;
    private StubResponse currentStubResponse;
    private Integer currentExpectedCallCount;

    /**
     * Creates mock object of given class or interface.
     *
     * @param classToMock class or interface to mock
     * @return mock object
     */
    public Object mock(Type classToMock) {
        return Test.createStub(classToMock, this);
    }

    public void startStubbing() {
        isStubbing = true;
    }

    public void stopStubbing() {
        isStubbing = false;
    }

    public StubResponse when(Object mock) {
        this.isMatchAnyArguments = false;
        return currentStubResponse;
    }

    public ArgumentMatcher matchAny() {
        isMatchAnyArguments = true;
        return new ArgumentMatcher(this);
    }

    public Object verify(Object stubbedObject, Integer callCount) {
        isVerifying = true;
        currentExpectedCallCount = callCount;
        return stubbedObject;
    }
    public Object captureArguments(Object stubbedObject) {
        isCapturing = true;
        return stubbedObject;
    }

    public Object getArgument(Integer argumentIndex) {
        return currentStubResponse.listOfArgs[argumentIndex];
    }

    public void stopCapturing() {
        this.isCapturing = false;
    }

    /**
     * Inherited from StubProvider.
     * @param stubbedObject The stubbed object.
     * @param stubbedMethodName The name of the invoked method.
     * @param returnType The return type of the invoked method.
     * @param listOfParamTypes A list of the parameter types of the invoked method.
     * @param listOfParamNames A list of the parameter names of the invoked method.
     * @param listOfArgs The actual argument values passed into this method at runtime.
     * @return The stubbed return value. Null by default, unless you prepared one that matches this method and argument values in stubbing.
     */
    public Object handleMethodCall(Object stubbedObject, String stubbedMethodName, Type returnType,
        List<Type> listOfParamTypes, List<String> listOfParamNames, List<Object> listOfArgs) {
        return mockMethod(stubbedObject, stubbedMethodName, listOfArgs);
    }

    public Object mockMethod(Object stubbedObject, String stubbedMethodName, List<Object> listOfArgs) {
        if (isCapturing) {
            prepareForCapture(stubbedObject, stubbedMethodName);
            return null;
        }
        createOrChooseStubResponse(stubbedObject, stubbedMethodName, listOfArgs);
        String methodSignature = currentStubResponse.methodSignature;
        if (isStubbing) {
            return null;
        }
        else if (isVerifying) {
            verify(methodSignature);
            return null;
        }
        else {
            return respond(listOfArgs);
        }
    }

    private void prepareForCapture(Object stubbedObject, String stubbedMethodName) {
        for (String methodSignature : methodSignature2StubResponse.keySet()) {
            if (methodSignature.startsWith(getMethodSignature(stubbedObject, stubbedMethodName))) {
                currentStubResponse = methodSignature2StubResponse.get(methodSignature);
            }
        }
    }

    private void createOrChooseStubResponse(Object stubbedObject, String stubbedMethod, List<Object> listOfArgs) {
        String methodSignature = getMethodSignature(stubbedObject, stubbedMethod);
        if (isMatchAnyArguments || methodsMatchingAny.contains(methodSignature)) {
            isMatchAnyArguments = false;
            methodsMatchingAny.add(methodSignature);
            for (String signature : methodSignature2StubResponse.keySet()) {
                if (signature.startsWith(methodSignature)) {
                    methodSignature = signature;
                }
            }
            setCurrentStubResponse(methodSignature);
        }
        else {
            String fullMethodSignature = getFullMethodSignature(stubbedObject, stubbedMethod, listOfArgs);
            setCurrentStubResponse(fullMethodSignature);
        }
    }

    private void setCurrentStubResponse(String fullMethodSignature) {
        if (!methodSignature2StubResponse.containsKey(fullMethodSignature)) {
            methodSignature2StubResponse.put(fullMethodSignature, new StubResponse(fullMethodSignature));
        }
        currentStubResponse = methodSignature2StubResponse.get(fullMethodSignature);
    }

    private void verify(String methodSignature) {
        System.assertEquals(currentExpectedCallCount,
            methodSignature2StubResponse.get(methodSignature).callCount,
            String.format('Wrong number of method calls for {0} method.', new List<String> {
                methodSignature
            })
        );
        isVerifying = false;
    }

    private Object respond(List<Object> listOfArgs) {
        currentStubResponse.recordCall(listOfArgs);
        if (currentStubResponse.exceptionToThrow != null) {
            throw currentStubResponse.exceptionToThrow;
        }
        return currentStubResponse.response;
    }

    private String getFullMethodSignature(Object stubbedObject, String stubbedMethod, List<Object> listOfArgs) {
        return getMethodSignature(stubbedObject, stubbedMethod) + String.valueOf(listOfArgs);
    }

    public String getMethodSignature(Object stubbedObject, String stubbedMethod) {
        return extractTypeName(stubbedObject) + '.' + stubbedMethod + ARGUMENTS_SEPARATOR;
    }

    private String extractTypeName(Object instance) {
        return String.valueOf(instance).split(':').get(0);
    }


    public class StubResponse {
        private String methodSignature;
        private List<Object> listOfArgs;
        private Object response;
        private Exception exceptionToThrow;
        private Integer callCount = 0;

        private StubResponse(String methodSignature) {
            this.methodSignature = methodSignature;
            this.listOfArgs = listOfArgs;
        }

        public void thenReturn(Object response) {
            if (exceptionToThrow != null) {
                throw new MockingException(MSG_RESPONSE_OR_EXCEPTION);
            }
            this.response = response;
        }

        public void thenThrow(Exception exceptionToThrow) {
            if (response != null) {
                throw new MockingException(MSG_RESPONSE_OR_EXCEPTION);
            }
            this.exceptionToThrow = exceptionToThrow;
        }

        private void recordCall(List<Object> listOfArgs) {
            this.listOfArgs = listOfArgs;
            callCount++;
        }

    }

    public class ArgumentMatcher {

        private ApexMocks mocks;

        private ArgumentMatcher(ApexMocks mocks) {
            this.mocks = mocks;
        }

        public StubResponse when(Object mock) {
            return mocks.when(mock);
        }

        public Object verify(Object stubbedObject, Integer callCount) {
            return mocks.verify(stubbedObject, callCount);
        }

    }

    public class MockingException extends Exception {}

}