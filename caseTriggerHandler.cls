public without sharing class caseTriggerHandler {
 	public static void onAfterUpdate(List<Case> newCaseList, 
                                     Map<Id,Case> newCaseMap, 
                                     List<Case> oldCaseList, 
                                     Map<Id,Case> oldCaseMap){
        	
           List<Certification__c> crl = new List<Certification__c>();
            	for(Case rec: newCaseList){
                	if(rec.Examination_Status__c == 'Passed'){
                   		Certification__c cr = new Certification__c();
                       	cr.Resource_Name__c	= rec.ContactId;
                        cr.Exam_Date__c = rec.Exam_Date__c;
                        cr.Certification_Category__c= rec.Certification_Category__c;
                        cr.Certification_Name__c= rec.Certification_Name__c;
                        cr.Completed_Date__c = System.today();
						crl.add(cr);  
                	}        
            	}
           	try{
            	insert crl;
            } catch (Exception e) {
                throw new AuraHandledException(e.getMessage());
            }
    }
}