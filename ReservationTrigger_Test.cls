@isTest(seeAllData=false)
private class ReservationTrigger_Test {

    @isTest
    static void checkPastReservationTest(){

        Account acc = New Account ();
        acc.Name = 'John Mark Sacdalan';
        insert acc;
    
        Contact con = new Contact();
        con.LastName = 'Sacdalan';
        con.AccountId = acc.Id;
        insert con;
    
        Reservation__c res = new Reservation__c(Date__c = System.today().addDays(-1), Resource__c = con.Id);
        insert res;

        Boolean error;
        try{
            delete 	res;
        }catch(Exception e){
            error=true;
            (e.getMessage().contains('Deleting Past Reservation is Prohibited'));
        }
        System.assert(error);
    }
}