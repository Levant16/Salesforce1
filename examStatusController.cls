public without sharing class examStatusController {
    
	public String status { get; set; }  // pass or fail
    
    public list<selectoption> getStatusObj(){
        list<selectoption> options = new list<selectoption>();
        Schema.DescribeFieldResult statusFieldDescription = Case.Examination_Status__c.getDescribe();
        options.add(new Selectoption('----Select Status----', '----Select Status----'));
        for(Schema.PicklistEntry listC : statusFieldDescription.getPicklistValues()){
            options.add(new Selectoption(listC.getValue(), listC.getLabel()));
        }
        return options;
    }
    
    public PageReference sendRequest(){
        try{
            String caseId = apexpages.currentpage().getparameters().get('id');
        	Case selectedCase = [SELECT Id, Examination_Status__c, Status, Exam_Date__c 
                                 FROM Case 
                                 WHERE Id =: caseId ];
        	
        	if(selectedCase.Examination_Status__c != null ){
            	ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.WARNING, 'You have already entered a status for this examination.' ));
            	return null;
        	}
            //if not approved dont proceed
        	if(selectedCase.Status != 'Approved'){
                ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, 'Your request has not been approved.' ));
            	return null;
            }
        	//if exam date is null dont proceed
        	if(selectedCase.Exam_Date__c == null){
                ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, 'Please submit your exam date first.' ));
            	return null;
            }
        	selectedCase.Examination_Status__c = status;
        	//if no status selected dont proceed
            if(selectedCase.Examination_Status__c == '----Select Status----'){
                ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, 'Please select a examination status.' ));
            	return null;
            }
            try{
        		update selectedCase;
            	pageReference success = new pageReference('/examStatusSuccess');
        		return success;
            }catch (Exception e){
                ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, 'update error' ));
                return null;
            }
            
        }catch (Exception e) {
            ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, 'Invalid Request' ));
            return null;
        }
        
    }
}