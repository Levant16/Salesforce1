public without sharing class certificationExamDateController {
	public Date selectedDate { get; set; }  // date
    
    
    public PageReference sendRequest(){
        try{
            String caseId = apexpages.currentpage().getparameters().get('id');
        	Case selectedCase = [SELECT Id, Exam_Date__c, Subject, Status FROM Case WHERE Id =: caseId ];
        	if(selectedCase.Exam_Date__c != null){
            	ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.WARNING, 'You have already entered a date for this examination.' ));
            	return null;
        	}
            else if(selectedCase.Status != 'Approved'){
                ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, 'Your request has not been approved.' ));
            	return null;
            }
        	selectedCase.Exam_Date__c = selectedDate;
        	update selectedCase;
            pageReference success = new pageReference('/examDateSuccess');
        	//ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.INFO, 'Date has been submitted.'));
        	return success;
        }catch (Exception e) {
            ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, 'Invalid Request' ));
            return null;
        }
        
    }
   
}