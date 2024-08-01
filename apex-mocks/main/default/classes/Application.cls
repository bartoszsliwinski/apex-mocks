/**
 * Stores information about all Selectors, Services
 * and UnitOfWork-related SObjects.
 *
 * @author Bartosz Sliwinski (bartosz.j.sliwinski@gmail.com)
 * @date September 2022
 */
public with sharing class Application {

    public static final ApplicationFactory.SelectorFactory selector = new ApplicationFactory.SelectorFactory(
        new Map<SObjectType, Type> {
            // Account.SObjectType => SEL_Accounts
        }
    );

    public static final ApplicationFactory.ServiceFactory service = new ApplicationFactory.ServiceFactory(
        new Set<Type> {
            ExampleService.class
        }
    );

    public static final ApplicationFactory.UnitOfWorkFactory unitOfWork = new ApplicationFactory.UnitOfWorkFactory(
        new List<SObjectType> {
            // Account.SObjectType,
            // Contact.SObjectType
        }
    );

}