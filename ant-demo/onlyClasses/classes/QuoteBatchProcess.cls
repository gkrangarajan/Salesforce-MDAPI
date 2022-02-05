public class QuoteBatchProcess implements Database.Batchable<sObject>, Database.Stateful,Database.RaisesPlatformEvents {
    // instance member to retain state across transactions

    public List<string> errorRecordsId=new List<String>();
    public Integer recordsProcessed = 0;
    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(
            'SELECT ID, Account_ID__c,Quote_ID__c,Opportunity_Id__c,Quote_Name__c,Quote_Status__c,' +
            '(select ID,Product_ID__c,Quote_ID__c,Health_Care_Quote_Line_ID__c,Quantity__c,Pricebook_Entry_ID__c from Healthcare_QuoteDetail_Staging__r) ' +
            'FROM Healthcare_Quote_Staging__c ' 
        );
    }
    public void execute(Database.BatchableContext bc, List<Healthcare_Quote_Staging__c> scope){
        // process each batch of records

        List<Quote> lstQuotes=new list<Quote>();
        List<QuoteLineItem> lstQLI= new List<QuoteLineItem>();

        //External ID field on Quote
        Schema.SObjectField qExtId = Quote.Fields.External_Quote_ID__c;
        Schema.SObjectField qliExtId = QuoteLineItem.Fields.External_Quote_Line_ID__c;

        for (Healthcare_Quote_Staging__c hqs:scope)
        {
            //Generate Quote records
            
            Quote q= new Quote (Name=hqs.Quote_Name__c,
            Opportunity=new Opportunity(External_Opportunity_ID__c=hqs.Opportunity_Id__c),
            Account__r=new Account(External_Account_ID__c=hqs.Account_ID__c),
            Pricebook2Id='01s4x000003HEFDAA4',
            External_Quote_ID__c=hqs.Quote_ID__c);

            lstQuotes.add(q);

            //Generate Quote Line records

            for (Healthcare_QuoteDetail_Staging__c hqls:hqs.Healthcare_QuoteDetail_Staging__r)
            {
                System.debug(hqls.Id);
                QuoteLineItem qli= new QuoteLineItem(
                    quote=new Quote(External_Quote_ID__c=hqls.Quote_ID__c),
                    product2= new Product2(External_Product_ID__c=hqls.Product_ID__c),
                    Quantity=hqls.Quantity__c,
                    UnitPrice=5,  // Can be added as a fields on Detail stage table
                    //PricebookEntry=new PricebookEntry(External_Pricebook_Entry_ID__c=hqls.Pricebook_Entry_ID__c),
                    External_Quote_Line_ID__c=hqls.Health_Care_Quote_Line_ID__c
                );
                lstQLI.add(qli);
                System.debug('Quote Line Item list' +lstQLI);
            }

            
        }
            if (!lstQuotes.isEmpty())
            {   
                    Database.UpsertResult[] upsertQts = Database.upsert(lstQuotes, qExtId, false);
                    
            
            }

            if (!lstQLI.isEmpty())
            {   
                Database.UpsertResult[] upsertQLI = Database.upsert(lstQLI, qliExtId, false);
                integer recordIndex=0;
                    for (Database.UpsertResult  sr : upsertQLI) {
                    if (!sr.isSuccess()) {
                        for(Database.Error err : sr.getErrors()) {
                            System.debug('The following error has occurred.'+err.getStatusCode() + ': ' + err.getMessage());
                            errorRecordsId.add(lstQLI[recordIndex].External_Quote_Line_ID__c);
                        }
                    }
                    recordIndex++;
                }
            }
        
    }
    public void finish(Database.BatchableContext bc){


    system.debug('*****failed recordIds:'+string.join(errorRecordsId,','));
        // Create an instance of the Demo event 
        Batch_Events__e demoEvent = new Batch_Events__e(
            Event_Info__c='Batch failure for Quote data load', 
            Event_Publisher__c='QuoteBatchProcess',
            Record_Ids__c=string.join(errorRecordsId,','));
        // Call method to publish events
        Database.SaveResult sr = EventBus.publish(demoEvent);
        // Inspect publishing result 
        if (sr.isSuccess()) {
            System.debug('Successfully published event.');
        } else {
            for(Database.Error err : sr.getErrors()) {
                System.debug('Error returned: ' +  err.getStatusCode() +' - ' + err.getMessage());
            }
        }  
    }
}



/* 

Anonymous apex to load Quote lines using Quote related ID 

Healthcare_Quote_Staging__c hcq1= new Healthcare_Quote_Staging__c(External_Health_Care_Quote_ID__c ='HCQ001');
system.debug('Quote' +hcq1);
Healthcare_QuoteDetail_Staging__c h1 = new Healthcare_QuoteDetail_Staging__c();
h1.Healthcare_Quote_Staging__r=hcq1;
h1.Name ='HQD001';
h1.Quantity__c =15;
insert h1;

==========

Schema.SObjectField f = Quote.Fields.External_Quote_ID__c;
Quote q= new Quote(Name='Test Q1',External_Quote_ID__c='Q001',OpportunityId='0064x00000AJjGjAAL');
Database.UpsertResult cr = Database.upsert(q, f, false);

======

List<Quote> lstQuotes=new list<Quote>();
Schema.SObjectField qExtId = Quote.Fields.External_Quote_ID__c;

Healthcare_Quote_Staging__c hqs=[select Quote_Name__c,Quote_ID__c FROM Healthcare_Quote_Staging__c
                                 LIMIT 1];
    
Quote q= new Quote (Name=hqs.Quote_Name__c,Opportunity=new Opportunity(External_Opportunity_ID__c='Opp001'),External_Quote_ID__c=hqs.Quote_ID__c);
lstQuotes.add(q);
        
if (!lstQuotes.isEmpty())
   {   
      Database.UpsertResult[] cr = Database.upsert(lstQuotes, qExtId, false);
   }

//Execute the Batch Job
   Database.executeBatch(new QuoteBatchProcess());



//Send email

AsyncApexJob a = [SELECT CreatedBy.Email, CreatedBy.Name, CreatedDate, CompletedDate, Id, JobItemsProcessed, NumberOfErrors, Status, TotalJobItems FROM AsyncApexJob WHERE Id =: bc.getJobId()];  
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage(); 
        String[] toAddresses = new String[] {'grangarajan@salesforce.com'}; 
        mail.setToAddresses(toAddresses); //to
        mail.setSubject('Apex Batch job for Quote Execution Status:'+a.Status); 
        mail.setPlainTextBody('The batch Apex job created by '+a.CreatedBy.Name+' ('+a.CreatedBy.Email+') processed '+a.TotalJobItems+' batches with '+a.NumberOfErrors+' failures. The process began at '+a.CreatedDate+' and finished at '+a.CompletedDate+'.'); 
        mail.setPlainTextBody('Batch job error:' +errors);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail }); //send

*/