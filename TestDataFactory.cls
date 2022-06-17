@isTest (SeeAllData = false)
public class TestDataFactory {
    public static Id rtHRRecruitment = Schema.SObjectType.Contact.getRecordTypeInfosbyName().get('HR Recruitment').getRecordTypeId();
    public static Id rtBootcampCand = Schema.SObjectType.Candidate__c.getRecordTypeInfosbyName().get('Bootcamp Candidates').getRecordTypeId();
    public static Id rtEntryLevelCand = Schema.SObjectType.Candidate__c.getRecordTypeInfosbyName().get('Entry Level Candidate').getRecordTypeId();
    public static Id rtExpCand = Schema.SObjectType.Candidate__c.getRecordTypeInfosbyName().get('Experienced Candidate').getRecordTypeId();
    public static Id rtHiredCand = Schema.SObjectType.Candidate__c.getRecordTypeInfosbyName().get('Hired - Archived').getRecordTypeId();
    
    public static Id idRec = '0034C00000YuqaBQAR';
        
    public static List<Candidate__c> createHiredArchivedCandidate(String fname, String lname, String email){
        List <Candidate__c> hiredCand = new List<Candidate__c>();
        Candidate__c c = new Candidate__c();
            c.RecordTypeId = rtHiredCand;
            c.First_Name__c = fname;
            c.Last_Name__c = lname;
            c.Source__c = 'LinkedIn';
            c.Proposed_Level__c = 'Consultant';
            c.Recruiter__c = idRec;
            c.Offering_Capability__c= 'Salesforce';
            c.Status__c = 'Hired';
            c.Hire_Date__c = System.today();
            c.Start_Date__c = System.today()+1;
            c.Email__c = email;
        hiredCand.add(c);
        return hiredCand;
    }
    
    public static List<Candidate__c> createNewCandidate(String fname, String lname, String email){
        List <Candidate__c> candItems = new List <Candidate__c>();
        Candidate__c c = new Candidate__c();
            c.RecordTypeId = '0124C0000005ZVFQA2';
            c.First_Name__c = fname;
            c.Last_Name__c = lname;
            c.Source__c = 'LinkedIn';
            c.Proposed_Level__c = 'Analyst - Bootcamp';
            c.Recruiter__c = idRec;
            c.Offering_Capability__c= 'Salesforce';
            c.Status__c = 'New';
            c.Hire_Date__c = System.today();
            c.Start_Date__c = System.today()+1;
            c.Email__c = email;
        candItems.add(c);
        return candItems;
    }
    
    public static List<Candidate__c> createCandidate(String capability, String status, Date hiredate, Date startdate){
        List <Candidate__c> candItems = new List <Candidate__c>();
        Candidate__c c = new Candidate__c();
            c.RecordTypeId = rtEntryLevelCand;
            c.First_Name__c = 'Test';
            c.Last_Name__c = 'Candidate';
            c.Source__c = 'LinkedIn';
            c.Proposed_Level__c = 'Analyst - Bootcamp';
            c.Recruiter__c = idRec;
            c.Offering_Capability__c= capability;
            c.Status__c = status;
            c.Hire_Date__c = hiredate;
            c.Start_Date__c = startdate;
            c.Email__c = 'email@test.com.test';
        candItems.add(c);
        return candItems;
    }
    
    public static List<Contact> createContact(Id recTypeId, String title, String name){
        List <Contact> cont = new List<Contact>();
        Contact newCont = new Contact();
            newCont.RecordTypeId = recTypeId;
            newCont.Title = title;
            newCont.LastName = name;
        cont.add(newCont);
        insert cont;
        return cont;
    }
}