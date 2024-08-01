/**
 * Implementation of HttpCalloutMock interface, allowing work with multiple endpoints at once.
 *
 * @author Bartosz Sliwinski (bartosz.j.sliwinski@gmail.com)
 * @date July 2024
 */
@IsTest
public with sharing class HttpMock implements HttpCalloutMock {

    private Boolean isExactEndpointMatch;
    private Map<String, HttpResponse> endpoint2HttpResponse = new Map<String, HttpResponse>();

    /**
     * @param isExactEndpointMatch Decides whether the endpoint will be matched based on exact match or startsWith.
     * Default is false, which should fit most scenarios.
     */
    public HttpMock() {
        this(false);
    }

    /**
     * @param isExactEndpointMatch Decides whether the endpoint will be matched based on exact match or startsWith.
     * Default is false, which should fit most scenarios.
     */
    public HttpMock(Boolean isExactEndpointMatch) {
        this.isExactEndpointMatch = isExactEndpointMatch;
    }

    /**
     * Adds a default response, without checking for a matching endpoint. To be used only with single callout.
     *
     * @param httpResp Response to be returned
     *
     * @return Current instance of HttpMock class
     */
    public HttpMock addResponse(HttpResponse httpResp) {
        if (!endpoint2HttpResponse.isEmpty()) {
            throw new MockingException('"addResponse(HttpResponse)" should only be used for single-response scenarios.');
        }
        addResponse(null, httpResp);
        return this;
    }

    /**
     * Adds a response for given endpoint. To be used only with multiple callout scenarios.
     *
     * @param endpoint Either full endpoint or its beginning, depending on `isExactEndpointMatch` value
     * @param httpResp Response to be returned for given endpoint
     *
     * @return Current instance of HttpMock class
     */
    public HttpMock addResponse(String endpoint, HttpResponse httpResp) {
        if (endpoint2HttpResponse.containsKey(null)) {
            throw new MockingException('"addResponse(String, HttpResponse") cannot' +
                ' be used after "addResponse(HttpResponse" has been used already.');
        }
        endpoint2HttpResponse.put(endpoint, httpResp);
        return this;
    }

    /**
     * Returns an HTTP response for the given request. The implementation of this method is called by
     * the Apex runtime to send a fake response when an HTTP callout is made after Test.setMock has been called.
     *
     * @param httpReq Request sent by Http.send method
     *
     * @return Mocked response. If only one HttpResponse was given, does not perform endpoint matching.
     */
    public HttpResponse respond(HttpRequest httpReq) {
        if (endpoint2HttpResponse.size() == 1) {
            return endpoint2HttpResponse.values()[0];
        }
        else {
            for (String endpoint : endpoint2HttpResponse.keySet()) {
                if (httpReq.getEndpoint().startsWith(endpoint)) {
                    return endpoint2HttpResponse.get(endpoint);
                }
            }
        }
        return null;
    }

}