@isTest
private class CancelledCareerLogBatchTest {
    static String currentFY = 'FY22';
    
    @testSetup
    static void setup() {
        // Account Creation
        String conSalesforceRecTypeId = Schema.getGlobalDescribe().get('Contact').getDescribe()
            .getRecordTypeInfosByDeveloperName().get('Salesforce').getRecordTypeId();
        
        Account coachAcc = new Account();
        coachAcc.name = 'CoachAcc';
        insert coachAcc;
        
        Account coacheeAcc = new Account(name='CoacheeAcc');
        insert coacheeAcc;
        
        // Contact Creation
        Contact coachCon = new Contact();
        coachCon.Firstname ='Coach';
        coachCon.LastName ='Contact';
        coachCon.Account = coachAcc;
        coachCon.recordTypeId = conSalesforceRecTypeId;
        coachCon.Milestone_Level__c ='L2';
        coachCon.Team__c ='testTeam';
        insert coachCon;
        
        Contact coacheeCon = new Contact();
        coacheeCon.Firstname ='Coachee'; 
        coacheeCon.LastName ='Contact';
        coacheeCon.Account = coacheeAcc; 
        coacheeCon.recordTypeId = conSalesforceRecTypeId; 
        coacheeCon.Milestone_Level__c ='L1'; 
        coacheeCon.Team__c ='testTeam';
        coacheeCon.Coach__c =coachCon.Id;
        
        insert coacheeCon;
        
        // Career Log Creation
        String careerGoalRecTypeId = Schema.getGlobalDescribe().get('CareerLog__c')
         .getDescribe().getRecordTypeInfosByDeveloperName().get('Career_Goals').getRecordTypeId();
        
        CareerLog__c careerLog1 = new CareerLog__c();
         careerLog1.CareerGoal__c = 'Test Class Apex Career Goal';
         careerLog1.Comment__c = 'Test Class Apex Career Goal Comment';
         careerLog1.Other_Contribution__c = '';
         careerLog1.Date__c = date.Today();
         careerLog1.Verified__c = FALSE;
         careerLog1.Cancelled__c = TRUE;
         careerLog1.recordTypeId = careerGoalRecTypeId;
         careerLog1.Contact__c = coacheeCon.Id;

         insert careerLog1;
    }
        
        /*String otherContributionRecTypeId = Schema.getGlobalDescribe().get('CareerLog__c')
         .getDescribe().getRecordTypeInfosByDeveloperName().get('Other_Contributions').getRecordTypeId();

         CareerLog__c careerLog2 = new CareerLog__c();
         careerLog2.Other_Contribution__c = 'Test Class Apex Other Contribution';
         careerLog2.Comment__c = 'Test Class Apex Other Contribution Comment';
         careerLog2.Date__c = date.Today();
         careerLog2.Verified__c = FALSE;
         careerLog2.Cancelled__c = TRUE;
         careerLog2.recordTypeId = OtherContributionRecTypeId;
         careerLog2.Contact__c = coacheeCon.Id;

         insert careerLog2;


         String projectUpdatesRecTypeId = Schema.getGlobalDescribe().get('CareerLog__c')
         .getDescribe().getRecordTypeInfosByDeveloperName().get('Project_Updates').getRecordTypeId();

         Project__c projUpd = new Project__c();
         projUpd.name = 'Test Class Apex Project';
         projUpd.Project_Name_NO_CI__c = 'TestClassApexProject';
         projUpd.Color__c = 'Green';
         insert projUpd;

         Project__c projUpdRec = [SELECT Id, Name FROM Project__c WHERE Name = 'Test Class Apex Project' LIMIT 1];

         CareerLog__c careerLog3 = new CareerLog__c();
         careerLog3.Project__c = projUpdRec.Id;
         careerLog3.Comment__c = 'Test Class Apex Project Update Comment';
         careerLog3.Date__c = date.Today();
         careerLog3.Verified__c = FALSE;
         careerLog3.Cancelled__c = TRUE;
         careerLog3.Team_Lead__c = coacheeCon.Coach__c;
         careerLog3.recordTypeId = projectUpdatesRecTypeId;
         careerLog3.Contact__c = coacheeCon.Id;

         insert careerLog3;
        
         String genCommentRecTypeId = Schema.getGlobalDescribe().get('CareerLog__c')
         .getDescribe().getRecordTypeInfosByDeveloperName().get('General_Comments').getRecordTypeId();
         CareerLog__c careerLog4 = new CareerLog__c();
         careerLog4.Comment__c = 'Test Class Apex General Comment';
         careerLog4.Date__c = date.Today();
         careerLog4.recordTypeId = genCommentRecTypeId;
         careerLog4.Contact__c = coacheeCon.Id;

        insert careerLog4;
        */
        
        
        // Testing
        @isTest 
        private static void test() {
        currentFY = CancelledCareerLogBatchTest.currentFY;
         String careerGoalRecTypeId = Schema.getGlobalDescribe().get('CareerLog__c')
         	.getDescribe().getRecordTypeInfosByDeveloperName().get('Career_Goals').getRecordTypeId();
         
         //Query created CareerLog from testSetup
         CareerLog__c careerGoalQry = [SELECT Id, CareerGoal__c,
                                             Contact__r.Id,
                                             FiscalYear__c 
                                             FROM CareerLog__c WHERE CareerGoal__c = 'Test Class Apex Career Goal' LIMIT 1];
        System.Test.startTest();
            
        CancelledCareerLogSchedulable delCareerLogSched = new CancelledCareerLogSchedulable();
        String chron = '0 0 0 1 APR ? *';
        String jobID = System.schedule('Cancelled Career Logs Batch Schedulable', chron,delCareerLogSched);
  
        CronTrigger ct = [SELECT ID, CronExpression from CronTrigger where id = :jobID];
        System.assertEquals(chron,ct.CronExpression);
            
        CancelledCareerLogBatch delCareerLogBatch = new CancelledCareerLogBatch();
   
        Database.executeBatch(delCareerLogBatch);
        
        System.assertEquals(careerGoalQry, [SELECT Id, CareerGoal__c,
                                             Contact__r.Id,
                                             FiscalYear__c 
                                             FROM CareerLog__c WHERE CareerGoal__c = 'Test Class Apex Career Goal' LIMIT 1]);
        System.Test.stopTest();
        
    }
}