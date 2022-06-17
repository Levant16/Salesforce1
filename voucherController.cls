public without sharing class voucherController {
    private final Case caseRecord;
    public voucherController(ApexPages.StandardController stdController) {
        this.caseRecord = (Case)stdController.getRecord();
        
    }
    
	//public String selectedEmail { get; set; }  // email
    public String selectedCategory { get; set; }  // category of cert
    public String certificates { get; set; }  // cert
    
  
    public PageReference sendRequest(){

        Id contactId =[SELECT ContactId FROM User WHERE Id=:UserInfo.getUserId()].ContactId;
        
        if(contactId == null){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'No Email account has been specified. Please correct and resubmit.'));
            return null; //early out
        }
        
        if(caseRecord.Certification_Category__c == null || caseRecord.Certification_Name__c == null){//need changes
            
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Invalid Certificate. Please correct and resubmit.'));
            return null; //early out
        }
        Id vcrecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Voucher_Request').getRecordTypeId();
        Contact con = [SELECT Id,AccountId, Name, Email FROM Contact WHERE Id =: contactId LIMIT 1];
        System.debug(con);
        
        
        Case c = new Case();
        c.SuppliedEmail = con.Email;
        c.RecordTypeId = vcrecordTypeId;
        c.Subject = 'Voucher Request - ' +con.Name;          
        c.AccountId = con.AccountId;
        c.ContactId = con.Id;
        c.Origin = 'Web';
        c.Status = 'New';
        c.Certification_Category__c = caseRecord.Certification_Category__c;
        c.Certification_Name__c = caseRecord.Certification_Name__c;
        //c.Certification__c = certDetails.Id;//remove
        //c.Certification_Price__c = certDetails.Certification_Price__c;//
        c.Type = 'Voucher';
        
        //new code for validation of duplicate request before insert
        String selCert = caseRecord.Certification_Name__c;
        String caseSubject = c.Subject;
        String guestName = con.Name;
        String guestcontact = c.ContactId;
        System.debug(selCert);
        System.debug(caseSubject);
        System.debug(con.Id);
        System.debug(guestcontact);
        
        //String certName = certDetails.Certification_Name__c;
        
        List<Case> checkForDuplicates = [SELECT Id, ContactId, Subject, Status, Certification_Name__c, Examination_Status__c 
                                         FROM Case 
                                         WHERE Type = 'Voucher'  
                                         AND Certification_Name__c =: selCert 
                                         AND Subject =: caseSubject 
                                         AND ContactId =: guestcontact];
        if(!checkForDuplicates.isEmpty()){
            for(Case ca : checkForDuplicates){
                if(ca.Status == 'New' ){//duplicate request
                    ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.INFO, 'Hi '+ guestName +'! You have an on-going request for '+selCert+'.'));
                    System.debug(selCert);
                    return null;
                    
                }
                if(ca.Status == 'Approved' &&  ca.Examination_Status__c == null){//request not yet finished no pass
                    ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.INFO, 'Hi '+ guestName +'! You have an on-going approved request for '+selCert+'.'));
                    return null;
                    
                }
                if(ca.Examination_Status__c == 'Passed' ){//request passed
                    ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.INFO, 'Hi '+ guestName +'! You have already passed the certification for this certificate: '+selCert+'.'));
                    return null;
                    
                }
            }
        }
        //end of new edit
        
        insert c;
        pageReference success = new pageReference('https://voucher-phpdc.cs201.force.com/pdcportal/s/voucher');
        return success;
       
    }
}