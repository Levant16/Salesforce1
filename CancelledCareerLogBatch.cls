global class CancelledCareerLogBatch implements Database.Batchable<sObject> {
    
	// START - Gathers Career Goals that have been cancelled
    global Database.QueryLocator start(Database.BatchableContext bc)
        
    { 
        String query = 'SELECT Id, Contact__r.Name, Cancelled__c ';
            query += 'FROM CareerLog__c WHERE (Cancelled__c = TRUE)';
            //query += ' AND Id = \'a0D3C0000029LUbUAM\''; 
            
        return Database.getQueryLocator(query);
    }

    // EXECUTE - Delete all Career Logs with CANCELLED Career Goals among other query conditions
   global void execute(Database.BatchableContext bc, List<CareerLog__c> lstCareerLog)
        {
            List<CareerLog__c> delCareerLogList = new List<CareerLog__c>();
               
            for(CareerLog__c recCareerLog : lstCareerLog)
            {
                recCareerLog = recCareerLog;
                delCareerLogList.add(recCareerLog);
            }   
         
            try{
                delete delCareerLogList;
                //system.debug('@@@Deleted entries: '+ Id);
                //delete XXXX;
            }
            catch(Exception ex) {
                system.debug('@@@ Error: '+ex.getMessage());
            }
        }


    // FINISH
    global void finish(Database.BatchableContext bc)
        {
            system.debug('Deletion of Records with Cancelled Career Goals Completed');
        }
    
}