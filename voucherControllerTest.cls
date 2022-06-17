@isTest
public with sharing class voucherControllerTest {

    @TestSetup
    static void makeData(){
        // insert certification exams
        List<Certification_Exam__c> certList = new List<Certification_Exam__c>();
        certList.add(new Certification_Exam__c(
            Capability__c = 'Salesforce',
            Category__c = 'Administrator',
            Name__c = 'Platform App Builder'));
        certList.add(new Certification_Exam__c(
            Capability__c = 'Salesforce',
            Category__c = 'Developer',
            Name__c = 'B2C Commerce Architect'));
        insert certList;
    }

    static testMethod void getContact(){

        //Create Partner User
        Id p = [select id from profile where name='Partner Community User'].id;

        Account ac = new Account(name ='Pepper Potts') ;
        insert ac;

        Contact con = new Contact(LastName ='Stark', AccountId = ac.Id, Milestone_Level__c = '1', Team__c = 'Salesforce');
        insert con;

        User user = new User(Username = 'pepperpotts11@deloitte.com', LastName = 'Potts', Email='pepper@deloitte.com', Alias = 'Pepp',
        TimeZoneSidKey = 'Asia/Manila', LocaleSidKey = 'en_US', EmailEncodingKey = 'ISO-8859-1', ProfileId = p, LanguageLocaleKey = 'en_US',  ContactId = con.Id);
        User partnerUser = user;
        insert partnerUser;

        Contact con2 = new Contact();
        System.runAs(partnerUser){
            Test.startTest();
                con2 = voucherController.getContact();
            Test.stopTest();
        }

        // verify contacts are the same
        System.assertEquals(con.Id, con2.Id);
    }

    static testMethod void getCertifications(){
        Map<String, List<Certification_Exam__c>> certificateMap = new Map<String, List<Certification_Exam__c>>();

        System.assert(certificateMap.isEmpty());
        Test.startTest();
            certificateMap = voucherController.getCertificates('Salesforce');
        Test.stopTest();

        // verify map has now value
        System.assert(!certificateMap.isEmpty());
    }

    static testMethod void NewRequest(){

        //Create Partner User
        Id p = [select id from profile where name='Partner Community User'].id;

        Account ac = new Account(name ='Pepper Potts') ;
        insert ac;

        Contact con = new Contact(LastName ='Stark', AccountId = ac.Id, Milestone_Level__c = '1', Team__c = 'Salesforce', Email = 'teafdasfdasfdsst@test.com');
        insert con;

        User user = new User(Username = 'pepperpotts11@deloitte.com', LastName = 'Potts', Email='pepper@deloitte.com', Alias = 'Pepp',
        TimeZoneSidKey = 'Asia/Manila', LocaleSidKey = 'en_US', EmailEncodingKey = 'ISO-8859-1', ProfileId = p, LanguageLocaleKey = 'en_US',  ContactId = con.Id);
        User partnerUser = user;
        insert partnerUser;

        Certification_Exam__c exam = [SELECT Id FROM Certification_Exam__c LIMIT 1];

        List<Case> caseList = new List<Case>([SELECT Id FROM Case]);
        System.assertEquals(0, caseList.size());

        Case caseRec = new Case();
        caseRec.SuppliedEmail = con.Email;
        caseRec.Subject = 'Voucher Request - ' + con.Name;
        caseRec.AccountId = ac.Id;
        caseRec.ContactId = con.Id;
        caseRec.Origin = 'Web';
        caseRec.Status = 'New';
        caseRec.Certification_Exam__c = exam.Id;
        caseRec.Type = 'Voucher';

        System.runAs(partnerUser){
            Test.startTest();
                voucherController.sendRequest(caseRec);
            Test.stopTest();
        }

        caseList = new List<Case>([SELECT Id FROM Case]);
        System.assertEquals(1, caseList.size());
    }

    static testMethod void HasPendingRequest(){

        //Create Partner User
        Id p = [select id from profile where name='Partner Community User'].id;

        Account ac = new Account(name ='Pepper Potts') ;
        insert ac;

        Contact con = new Contact(LastName ='Stark', AccountId = ac.Id, Milestone_Level__c = '1', Team__c = 'Salesforce', Email = 'teafdasfdasfdsst@test.com');
        insert con;

        User user = new User(Username = 'pepperpotts11@deloitte.com', LastName = 'Potts', Email='pepper@deloitte.com', Alias = 'Pepp',
        TimeZoneSidKey = 'Asia/Manila', LocaleSidKey = 'en_US', EmailEncodingKey = 'ISO-8859-1', ProfileId = p, LanguageLocaleKey = 'en_US',  ContactId = con.Id);
        User partnerUser = user;
        insert partnerUser;

        Certification_Exam__c exam = [SELECT Id FROM Certification_Exam__c LIMIT 1];

        Case caseRec = new Case();
        caseRec.SuppliedEmail = con.Email;
        caseRec.Subject = 'Voucher Request - ' + con.Name;
        caseRec.AccountId = ac.Id;
        caseRec.ContactId = con.Id;
        caseRec.Origin = 'Web';
        caseRec.Status = 'New';
        caseRec.Certification_Exam__c = exam.Id;
        caseRec.Type = 'Voucher';
        insert caseRec;

        Case caseRec2 = new Case();
        caseRec2.SuppliedEmail = con.Email;
        caseRec2.Subject = 'Voucher Request - ' + con.Name;
        caseRec2.AccountId = ac.Id;
        caseRec2.ContactId = con.Id;
        caseRec2.Origin = 'Web';
        caseRec2.Status = 'New';
        caseRec2.Certification_Exam__c = exam.Id;
        caseRec2.Type = 'Voucher';

        System.runAs(partnerUser){
            Test.startTest();
            // has duplicate
            try {
                voucherController.sendRequest(caseRec2);
            } catch (AuraHandledException e) {}
            Test.stopTest();
        }
    }

    static testMethod void AlreadyCertified(){

        //Create Partner User
        Id p = [select id from profile where name='Partner Community User'].id;

        Account ac = new Account(name ='Pepper Potts') ;
        insert ac;

        Contact con = new Contact(LastName ='Stark', AccountId = ac.Id, Milestone_Level__c = '1', Team__c = 'Salesforce', Email = 'teafdasfdasfdsst@test.com');
        insert con;

        User user = new User(Username = 'pepperpotts11@deloitte.com', LastName = 'Potts', Email='pepper@deloitte.com', Alias = 'Pepp',
        TimeZoneSidKey = 'Asia/Manila', LocaleSidKey = 'en_US', EmailEncodingKey = 'ISO-8859-1', ProfileId = p, LanguageLocaleKey = 'en_US',  ContactId = con.Id);
        User partnerUser = user;
        insert partnerUser;

        Certification_Exam__c exam = [SELECT Id FROM Certification_Exam__c LIMIT 1];

        insert new Certification__c(
            Certification_Id__c = 'asdfasf',
            Resource__c = con.Id,
            Certification_Exam__c = exam.Id);

        List<Case> caseList = new List<Case>([SELECT Id FROM Case]);
        System.assertEquals(0, caseList.size());

        Case caseRec = new Case();
        caseRec.SuppliedEmail = con.Email;
        caseRec.Subject = 'Voucher Request - ' + con.Name;
        caseRec.AccountId = ac.Id;
        caseRec.ContactId = con.Id;
        caseRec.Origin = 'Web';
        caseRec.Status = 'New';
        caseRec.Certification_Exam__c = exam.Id;
        caseRec.Type = 'Voucher';

        System.runAs(partnerUser){
            Test.startTest();
                // already certified
                try{
                    voucherController.sendRequest(caseRec);
                } catch (AuraHandledException e) {}
            Test.stopTest();
        }
    }

    static testMethod void PassedExam(){

        //Create Partner User
        Id p = [select id from profile where name='Partner Community User'].id;

        Account ac = new Account(name ='Pepper Potts') ;
        insert ac;

        Contact con = new Contact(LastName ='Stark', AccountId = ac.Id, Milestone_Level__c = '1', Team__c = 'Salesforce', Email = 'teafdasfdasfdsst@test.com');
        insert con;

        User user = new User(Username = 'pepperpotts11@deloitte.com', LastName = 'Potts', Email='pepper@deloitte.com', Alias = 'Pepp',
        TimeZoneSidKey = 'Asia/Manila', LocaleSidKey = 'en_US', EmailEncodingKey = 'ISO-8859-1', ProfileId = p, LanguageLocaleKey = 'en_US',  ContactId = con.Id);
        User partnerUser = user;
        insert partnerUser;

        Certification_Exam__c exam = [SELECT Id FROM Certification_Exam__c LIMIT 1];

        Case caseRec = new Case();
        caseRec.SuppliedEmail = con.Email;
        caseRec.Subject = 'Voucher Request - ' + con.Name;
        caseRec.AccountId = ac.Id;
        caseRec.ContactId = con.Id;
        caseRec.Origin = 'Web';
        caseRec.Status = 'New';
        caseRec.Certification_Exam__c = exam.Id;
        caseRec.Type = 'Voucher';
        caseRec.Exam_Date__c = Date.today();
        insert caseRec;

        System.runAs(partnerUser){
            Test.startTest();
                caseRec.Examination_Status__c = 'Passed';
                caseRec.Certification_Id__c = '12313231';
                update caseRec;
            Test.stopTest();
        }
    }
}