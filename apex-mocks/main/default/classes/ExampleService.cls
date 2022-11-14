public with sharing class ExampleService {

    public static ExampleService newInstance() {
        return (ExampleService) Application.service.newInstance(ExampleService.class);
    }

    public Decimal getDiscount(Id opportunityId) {
        Decimal result = 0;

        // do calculations based on e.g. opp data, account data, HTTP callout

        return result;
    }

}