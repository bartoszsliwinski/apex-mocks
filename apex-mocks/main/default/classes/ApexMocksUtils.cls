/**
 * Provides various mocking-related utilities.
 * Simplified version off fflib_ApexMocksUtils
 *
 * @author Bartosz Sliwinski (bsliwinski@deloittece.com)
 * @date November 2020
 */
@IsTest
public inherited sharing class ApexMocksUtils {

    private static Integer fakeIdCount = 0;
    private static final String ID_PATTERN = '000000000000';

    /**
     * Generate a fake Salesforce Id for the given SObjectType
     *
     * @param sobjectType Type to create Id for
     * @return Mocked Id for given SObjectType
     */
    public static Id generateId(Schema.SObjectType sobjectType) {
        String keyPrefix = sobjectType.getDescribe().getKeyPrefix();
        fakeIdCount++;

        String fakeIdPrefix = ID_PATTERN.substring(0, ID_PATTERN.length() - String.valueOf(fakeIdCount).length());

        return Id.valueOf(keyPrefix + fakeIdPrefix + fakeIdCount);
    }

    /**
     * Provides ability to add child records to a parent (e.g. Account.Contacts).
     * Creates new instances of records in the process.
     *
     * @param parent Parent record to be populated
     * @param relationshipField SObjectField from child object (e.g. Contact.AccountId)
     * @param children Child records to be added to parent
     *
     * @return New instance of parent record with children added
     */
    public static SObject makeRelationship(SObject parent, SObjectField relationshipField, List<SObject> children) {
        List<Schema.ChildRelationship> childRelationships = parent.getSObjectType().getDescribe().getChildRelationships();
        String relationshipName;
        for (Integer i = 0, j = childRelationships.size(); i < j; i++) {
            ChildRelationship childRelationship = childRelationships[i];
            if (childRelationship.getField() == relationshipField) {
                relationshipName = childRelationship.getRelationshipName();
                break;
            }
        }

        Map<String, Object> genericObject = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(parent));
        genericObject.put(relationshipName, new ChildrenNode(children));
        return (SObject) JSON.deserialize(JSON.serialize(genericObject), SObject.class);
    }

    private class ChildrenNode {

        private Integer totalSize;
        private Boolean done;
        private List<SObject> records;

        private ChildrenNode(List<SObject> childRecords) {
            totalSize = childRecords.size();
            done = true;
            records = childRecords;
        }

    }

}