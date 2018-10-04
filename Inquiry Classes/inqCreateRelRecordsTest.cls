@isTest
public class inqCreateRelRecordsTest {
    @isTest static void checkOppsTest(){
        System.debug('Creating a contact and an inquiry. Inquiry should have "Create Opportunity" checked.');
        
        List<Inquiry__c> inqList = new List<Inquiry__c>();
        List<Inquiry__c> inqListLead = new List<Inquiry__c>();
        List<Inquiry__c> inqInvalidOwner = new List<Inquiry__c>();
        
        Test.startTest();
        inqList = inqCreateRelRecordsTest.createInqOnContactTest(1,1,false);
        inqListLead = inqCreateRelRecordsTest.createInqOnLeadTest(1,1,false);
        inqInvalidOwner = inqCreateRelRecordsTest.createInqOnContactTest(1,1,true);
        Test.stopTest();
        
        List<Inquiry__c> checkInq = [SELECT id, Create_Opportunity__c FROM Inquiry__c WHERE id IN :inqList];
        System.debug('checkInq = ' + checkInq);
        System.assertEquals(true, checkInq[0].Create_Opportunity__c, 'Inquiry not marked true.');
        
        List<Inquiry__c> checkInqLead = [SELECT id, Create_Opportunity__c FROM Inquiry__c WHERE id IN :inqListLead];
        System.debug('checkInq = ' + checkInq);
        System.assertEquals(1, checkInqLead.size(), 'Inquiry not created on lead.');
        
        id contID = inqInvalidOwner[0].contact__c;
        List<Case> checkCase = [SELECT id FROM Case WHERE ContactId = :contID];
        System.debug('checkCase = ' + checkCase);
        System.assertEquals(1, checkCase.size(), 'Case not created on lead.');
    }
    
    static List<Inquiry__c> createInqOnContactTest(integer numCont, integer numInq, boolean bogusUser){
        //get user data
        List<User> UserList = [SELECT id, name FROM User WHERE Bogus_User__c = :bogusUser AND isActive=true];
        id userID = UserList[0].id;
        
        //Create Contacts
        List<Contact> contsList = new List<Contact>();        
        for(Integer i=0; i<numCont;){
            System.debug('Creating Contact ' + i);
            Contact c = new Contact(LastName='TestContact', FirstName='Number ' + i, ownerID = userID);
            contsList.add(c);
            i = i + 1;
        }         
        
        System.debug('Inserting Contacts');
        System.debug('contsList = ' + contsList);
        insert contsList;
        
        //Insert Inquiries
        List<Inquiry__c> inqList = new List<Inquiry__c>();
        if(numInq>0){
            for(integer j=0; j<numCont;){
                Contact cont = contsList[j];
                //For each contact just created, add tasks
                for(integer l=0; l<numInq; l++){
                    System.debug('Creating Inquiry ' + l);
                    inqList.add(new Inquiry__c(Name='Inquiry #' +l,
                                               Contact__c = cont.Id
                                               
                                              ));
                    j=j+1;
                }
            }
        }
        
        System.debug('Inserting inqList' + inqList);
        insert inqList;
        
        return inqList;
    }
    
    static List<Inquiry__c> createInqOnLeadTest(integer numCont, integer numInq, boolean bogusUser){
        //get user data
        List<User> UserList = [SELECT id, name FROM User WHERE Bogus_User__c = :bogusUser AND isActive=true];
        id userID = UserList[0].id;
        
        //Create Leads
        List<Lead> contsList = new List<Lead>();        
        for(Integer i=0; i<numCont;){
            System.debug('Creating Lead ' + i);
            Lead c = new Lead(LastName='TestLead', FirstName='Number ' + i, Company='Test', ownerID=userID);
            contsList.add(c);
            i = i + 1;
        }         
        
        System.debug('Inserting LEads');
        System.debug('contsList = ' + contsList);
        insert contsList;
        
        //Insert Inquiries
        List<Inquiry__c> inqList = new List<Inquiry__c>();
        if(numInq>0){
            for(integer j=0; j<numCont;){
                Lead cont = contsList[j];
                //For each lead just created, add tasks
                for(integer l=0; l<numInq; l++){
                    System.debug('Creating Inquiry ' + l);
                    inqList.add(new Inquiry__c(Name='Inquiry #' +l,
                                               Lead__c = cont.Id
                                               
                                              ));
                    j=j+1;
                }
            }
        }
        
        System.debug('Inserting inqList' + inqList);
        insert inqList;
        
        return inqList;
    }
}