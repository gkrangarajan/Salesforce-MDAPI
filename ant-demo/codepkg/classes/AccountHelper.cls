public with sharing class AccountHelper {
    
    @AuraEnabled(cacheable=true)
    public static list<AccountContactRelation> getIndirectContacts(String accId,Integer noOfRecords, String sortOption){
    system.debug('accId >> ' + accId);

    String SOQLQuery = 'select Id,Contact_First_Name__c,Contact_Last_Name__c, roles from AccountContactRelation where accountId=\''+String.escapeSingleQuotes(accId) +'\' and isdirect=false ORDER BY ' +sortOption +' LIMIT ' +noOfRecords;
    System.debug('SOQLQuery' +SOQLQuery);

    /*list<AccountContactRelation> lstACR=[select Id,Contact_First_Name__c,Contact_Last_Name__c, roles 
    from AccountContactRelation 
    where accountId=:accId and isdirect=false ORDER BY :sortOption LIMIT :noOfRecords];*/

    list<AccountContactRelation> lstACR=database.query(SOQLQuery);
    system.debug('list size >> ' + lstACR);
    return lstACR;

    //Added for GIT Test


        
    }
}