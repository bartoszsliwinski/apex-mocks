/**
 * Simplified version of fflib_Application
 *
 * @author Bartosz Sliwinski (bsliwinski@deloittece.com)
 * @date September 2022
 */
public with sharing class ApplicationFactory {

    public class SelectorFactory {

        private Map<SObjectType, Type> sObjectType2SelectorImplementation;
        private Map<SObjectType, Object> sObjectType2MockInstance;

        public SelectorFactory(Map<SObjectType, Type> sObjectType2ServiceImplementation) {
            this.sObjectType2SelectorImplementation = sObjectType2ServiceImplementation;
            this.sObjectType2MockInstance = new Map<SObjectType, Object>();
        }

        public Object newInstance(SObjectType sObjType) {
            if (!sObjectType2SelectorImplementation.containsKey(sObjType)) {
                throw new ApplicationFactoryException(String.format(
                    'No selector registered for {0} SObjectType',
                    new List<String> {
                        sObjType.getDescribe().getName()
                    }));
            }

            if (sObjectType2MockInstance.containsKey(sObjType)) {
                return sObjectType2MockInstance.get(sObjType);
            }

            return sObjectType2SelectorImplementation.get(sObjType).newInstance();
        }

        @TestVisible
        private void setMock(SelectorBase mockInstance) {
            sObjectType2MockInstance.put(mockInstance.getSObjectType(), mockInstance);
        }

    }

    // Replace this with actual Selector
    private abstract class SelectorBase {
        private abstract SObjectType getSObjectType();
    }

    public class ServiceFactory {

        private Set<Type> registeredServices;
        private Map<Type, Object> serviceInterfaceType2MockInstance;

        public ServiceFactory(Set<Type> registeredServices) {
            this.registeredServices = registeredServices;
            this.serviceInterfaceType2MockInstance = new Map<Type, Object>();
        }

        public Object newInstance(Type serviceType) {
            if (!registeredServices.contains(serviceType)) {
                throw new ApplicationFactoryException(serviceType.getName() + ' is not registered as a service.');
            }

            if (serviceInterfaceType2MockInstance.containsKey(serviceType)) {
                return serviceInterfaceType2MockInstance.get(serviceType);
            }

            return serviceType.newInstance();
        }

        @TestVisible
        private void setMock(Type serviceType, Object mockInstance) {
            serviceInterfaceType2MockInstance.put(serviceType, mockInstance);
        }

    }

    public class UnitOfWorkFactory {

        private List<SObjectType> registeredSObjectTypes;
        private UnitOfWorkInterface uowMock;

        public UnitOfWorkFactory(List<SObjectType> registeredSObjectTypes) {
            this.registeredSObjectTypes = registeredSObjectTypes;
        }

        public UnitOfWorkInterface newInstance() {
            if (uowMock != null) {
                return uowMock;
            }
            return new UnitOfWorkImplementation(registeredSObjectTypes);
        }

        @TestVisible
        private void setMock(UnitOfWorkInterface mockInstance) {
            this.uowMock = mockInstance;
        }
    }

    // Replace this with actual UoW
    private interface UnitOfWorkInterface {}
    private class UnitOfWorkImplementation implements UnitOfWorkInterface {
        private UnitOfWorkImplementation(List<SObjectType> registeredSObjectTypes) {

        }
    }

    public class ApplicationFactoryException extends Exception {}

}