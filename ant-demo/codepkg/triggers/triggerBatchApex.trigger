trigger triggerBatchApex on BatchApexErrorEvent (after insert) {
    
    System.debug('Inside platform events trigger');
    Set<Id> asyncApexJobIds = new Set<Id>();
    
    for(BatchApexErrorEvent evt:Trigger.new){
        asyncApexJobIds.add(evt.AsyncApexJobId);
    }
    
    Map<Id,AsyncApexJob> jobs = new Map<Id,AsyncApexJob>(
        [SELECT id, ApexClass.Name FROM AsyncApexJob WHERE Id IN :asyncApexJobIds]);
    
	for(BatchApexErrorEvent evt:Trigger.new){
        //only handle events for the job(s) we care about
        if(jobs.get(evt.AsyncApexJobId).ApexClass.Name == 'QuoteBatchProcess'){
            for (String item : evt.JobScope.split(',')) {
                System.debug('Error occcured in Batch for record:' +item);
            }
        }
    }    
    
 }