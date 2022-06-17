/******************************************************
* Author : Jai Vera Cruz, KC Cruz
* Date : 02/24/22
* Description : handles all validation in Candidate__c
* History : 03/09/22 changed string literals to custom labels
******************************************************/
public with sharing class CandidateTriggerHandler {
    /******************************************************
    * Author : Jai Vera Cruz
    * Date : 02/24/22
    * Description : converts contact numbers to trunkline format
    * History : 
    ******************************************************/    
    public static void ConvertContactNumber(List<Candidate__c> cands) {
        // Loop through the Candidate records that fired the trigger
        for (Candidate__c can : cands){
            if (can.Contact_Number__c != Null){
                if (can.Contact_Number__c.isAlpha()){                             // If Contact_Number__c is all letters
                    can.Contact_Number__c.addError(Label.Wrong_Number_Format);    // Throw error on the field
                }
                can.Contact_Number__c = can.Contact_Number__c.replaceAll('\\s+','');       // Remove white spaces
                can.Contact_Number__c = can.Contact_Number__c.replace('+63', '0');         // Replace '+63' with '0'
                can.Contact_Number__c = can.Contact_Number__c.replaceAll('[^0-9.]','');    // Remove all characters except alphanumeric
            }
        }
    }

    
    /******************************************************
    * Author : KC Cruz
    * Date : 02/24/22
    * Description : checking if Salesforce has a registered Contact RecordType
    * History : 
    ******************************************************/            
    public static void matchCapabilityToContactRT (List<Candidate__c> candItems){        
        Map <String, Candidate_Contact_Capability_Map__mdt> ccMap = Candidate_Contact_Capability_Map__mdt.getAll();
        List <String> ccNames = new List <String>();
        for (String keySetString : ccMap.keySet()){
            ccNames.add(ccMap.get(keySetString).Offering_Capability__c);
        }
        
        for (Candidate__c cand : candItems){
            //checks if the status for the current candidate is hired
            if (cand.Status__c=='Hired'){
                if (!ccNames.contains(cand.Offering_Capability__c)&&cand.Offering_Capability__c!= NULL){
                    //throws error if the list of contact record types does not include the currently selected capability value
                    cand.addError(Label.No_Matching_Recordtype);
                }
            }
        }
    }

    /******************************************************
    * Author : KC Cruz
    * Date : 03/02/22
    * Description : blocks creation for candidates with non-hired status
    * History : 
    ******************************************************/           
    public static void blockDuplicateCreation (List <Candidate__c> candItems){
        Set <String> newCand = new Set<String>();
        //gets the email of the candidate to be saved for comparison later
        for (Candidate__c c: candItems){
            newCand.add(c.Email__c);
        }
        //retrieves duplicates that don't have Hired status but have the same email
        List <Candidate__c> nonDupes = [SELECT Id, First_Name__c, Last_Name__c, Email__c
                                       FROM Candidate__c WHERE Status__c!='Hired' AND Email__c IN :newCand];
        Map <String, Candidate__c> oldCands = new Map <String, Candidate__c>();
        for (Candidate__c c: nonDupes){
            oldCands.put(c.Email__c, c);                
        }
        for (Candidate__c c: candItems){
            //checks if the current candidate has the same email as the queried ones
            if(oldCands.containsKey(c.Email__c)){
                //checks if first name and last name is the same
                if(oldCands.get(c.Email__c).First_Name__c == c.First_Name__c && oldCands.get(c.Email__c).Last_Name__c == c.Last_Name__c){
                    //throws error if first name, last name, and email are the same
                    c.addError(Label.Candidate_Already_Exists);
                }
            }
        }
    }
    
    /******************************************************
    * Author : Ryan Santos
    * Date : 04/07/22
    * Description : blocks creation for candidates with hired status and within 6 months of creation
    * History : 
    ******************************************************/           
    public static void blockDuplicateCreationWithHiredStatus (List <Candidate__c> candItems){
        Set <String> newCand = new Set<String>();
        Date currentDate = Date.today();
        for (Candidate__c c: candItems){
            newCand.add(c.Email__c);
        }
        List <Candidate__c> nonDupes = [SELECT Id, First_Name__c, Last_Name__c, Email__c, Hire_Date__c
                                       FROM Candidate__c
                                        WHERE Status__c ='Hired'
                                        AND Email__c IN :newCand
                                       AND Hire_Date__c = LAST_N_DAYS:180];
        System.debug('*****nonDupes--- ' +nonDupes); 
        Map <String, Candidate__c> oldCands = new Map <String, Candidate__c>();
        for (Candidate__c c: nonDupes){
            oldCands.put(c.Email__c, c);
        }
        for (Candidate__c c: candItems){
            //checks if the current candidate has the same email as the queried ones
            if(oldCands.containsKey(c.Email__c)){
                System.debug('*****Email__c--- ' + c.Email__c);
                System.debug('*****oldCands--- ' + oldCands.get(c.Email__c));                
                System.debug('*****daysBetween--- ' + oldCands.get(c.Email__c).Hire_Date__c.daysBetween(currentDate));
                if(oldCands.get(c.Email__c).First_Name__c == c.First_Name__c && oldCands.get(c.Email__c).Last_Name__c == c.Last_Name__c
                  && oldCands.get(c.Email__c).Hire_Date__c.daysBetween(currentDate) <= 180){
                    c.addError('The candidate is already hired 6 months from todays date');
                }
            }
        }
    }
}