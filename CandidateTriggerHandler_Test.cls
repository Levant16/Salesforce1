/******************************************************
* Author : Jai Vera Cruz, KC Cruz
* Date : 02/17/22
* Description : handles all validation in Candidate__c
* History : 
******************************************************/
@isTest (seeAllData = false)
public with sharing class CandidateTriggerHandler_Test {
     
    /******************************************************
	* Author : KC Cruz
	* Date : 02/24/22
	* Description : test setup
	* History : 
	******************************************************/
    @testSetup
    static void testData(){
        //creates and inserts original candidate for the blockDupeCandidateTest() method
        List <Candidate__c> origRec = TestDataFactory.createCandidate('CM-DC: Salesforce', 'New', NULL, NULL);
        	origRec[0].First_Name__c= 'Bruce';
        	origRec[0].Last_Name__c= 'Wayne';
        	origRec[0].Email__c= 'b@tman.com.test';        
        Database.insert(origRec);
    }    
    
    /******************************************************
	* Author : Jai Vera Cruz
	* Date : 02/24/22
	* Description : creates new candidates in bulk
	* History : 
	******************************************************/
    @isTest 
    static void TestCreateNewCandidate() {
        // Create candidate with ContactNumber fields incorrectly populated
        List <Candidate__c> wrongNumberFormat = TestDataFactory.createNewCandidate('Test', 'Candidate', 'test@candidate.com.test');
        wrongNumberFormat[0].Contact_Number__c = 'asdfghjkl';
        wrongNumberFormat[0].Status__c = 'Hired'; 

        try {
            insert wrongNumberFormat;
        } catch (DmlException e) {
            
        }
        // Verify that no records were inserted
        System.assertEquals(0, [SELECT Id FROM Contact].size());

        // Create candidate with ContactNumber field populated correctly
       	List <Candidate__c> correctNumberFormat = TestDataFactory.createNewCandidate('Test', 'Candidate', 'test@candidate.com.test');
        correctNumberFormat[0].Contact_Number__c = '09171234567';
        correctNumberFormat[0].Status__c = 'Hired'; 
        
        // Perform Test
        Test.startTest();
        	insert correctNumberFormat;
        Test.stopTest();
    
        // Verify that new candidates were inserted
        List<Candidate__c> verifycans = [SELECT Id FROM Candidate__c];
        System.assertEquals(2, verifycans.size());
        // Verify that Candidate__c Contact_Number__c fields have been correctly formatted
        List<Candidate__c> verifyCansConvertedNumber = [SELECT Contact_Number__c FROM Candidate__c];
        List<Candidate__c> verifiedCansConverted = new List<Candidate__c>();
        for (Candidate__c can : verifyCansConvertedNumber){
            if (can.Contact_Number__c == '09171234567'){           // Check if the number is converted
                verifiedCansConverted.add(can);             // Add to list if verified
            }
        }
        // Verify
        System.assertEquals(1, verifiedCansConverted.size());
    }
    
    /******************************************************
	* Author : Jai Vera Cruz
	* Date : 02/24/22
	* Description : updates candidates in bulk
	* History : 
	******************************************************/    
    @isTest 
    static void TestUpdateCandidate() {
       	List <Candidate__c> noContNum = TestDataFactory.createNewCandidate('Test', 'Candidate', 'test@candidate.com.test');
        noContNum[0].Contact_Number__c = NULL;
        noContNum[0].Status__c = 'Hired';
        
        insert noContNum;
        // Update Contact_Number__c fields of the candidate incorrectly
        for (Candidate__c can : noContNum){
            can.Contact_Number__c = 'abcdefg';
        }        
        try {
            update noContNum;
        } catch (DmlException e) {
            
        }
        // Update Contact_Number__c fields of the candidate correctly
        for (Candidate__c can : noContNum){
            can.Contact_Number__c = '(+639) 17123-4567';
        }
        // Perform Test
        Test.startTest();
        	update noContNum;
        Test.stopTest();
        // Verify that Candidate__c Contact_Number__c field was formatted correctly
        List<Candidate__c> verifyCansConvertedNumber = [SELECT Contact_Number__c FROM Candidate__c];
        List<Candidate__c> verifiedCansConverted = new List<Candidate__c>();
        for (Candidate__c can : verifycansConvertedNumber){
            if (can.Contact_Number__c == '09171234567'){           // Check if the number is converted
                verifiedCansConverted.add(can);             // Add to list if verified
            }
        }
        // Verify
        System.assertEquals(1, verifiedCansConverted.size());
    }
    
    /******************************************************
	* Author : KC Cruz
	* Date : 02/24/22
	* Description : checking if Salesforce has a registered Contact RecordType
	* History : 
	******************************************************/    
    @isTest 
    static void matchCapabilityToContactRTSuccess (){     
        List<Candidate__c> candList = TestDataFactory.createCandidate('Salesforce', 'Hired', System.today(), System.today()+1);
        Test.startTest();
        	//checking starts upon insert attempt
        	Database.insert(candList);
        Test.stopTest();
    }
    
    /******************************************************
	* Author : KC Cruz
	* Date : 02/24/22
	* Description : checks if Capability 'test new' has a corresponding record type
	* History : 
	******************************************************/       
    @isTest 
    static void matchRecordTypeTestFail (){
        List <Candidate__c> candItems = TestDataFactory.createCandidate('test new', 'Hired', System.today(), System.today()+1);
        Boolean errorFound;
        Test.startTest();
            try{
                //checking starts upon insert attempt
            	Database.insert(candItems);
            }catch(Exception e){
                //if no record type equivalent then error is caught
                errorFound = TRUE;
            }
        Test.stopTest();
        System.assertEquals(TRUE, errorFound);
    }
    
    /******************************************************
	* Author : KC Cruz
	* Date : 03/02/22
	* Description : blocks creation for candidates with non-hired status
	* History : 
	******************************************************/       
    @isTest 
    static void blockDupeCandidateTest(){
        List <Candidate__c> dupeRec = TestDataFactory.createNewCandidate('Bruce', 'Wayne', 'b@tman.com.test');
        Boolean errorFound;
        Test.startTest();
        	try{
                //checking starts upon insert attempt
            	Database.insert(dupeRec);
            }catch(Exception e){
                //if non-hired candidate is found then true
                errorFound = TRUE;
            }
        Test.stopTest();
        System.assertEquals(TRUE, errorFound);
    }
}