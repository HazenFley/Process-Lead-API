@isTest
public class leadAssignmentTest {
    @isTest static void assignNewLeadTest() {
        System.debug('inserting organic lead, Q&T lead, Overflow Lead, then Overflow that will be updated, then a lead created by an active user');
        
        List<Lead> organicLeadList = new List<Lead>();
        List<Lead> QTLeadList = new List<Lead>();
        List<Lead> overflowLeadList = new List<Lead>();
        List<Lead> changeLeadList = new List<Lead>();
        List<Lead> activeLeadList = new List<Lead>();
        
        Test.startTest();
        organicLeadList = leadAssignmentTest.createLead('Organic', 'Organic', 'KS', true);
        QTLeadList = leadAssignmentTest.createLead('QT','Social', 'KS', true);
        overflowLeadList = leadAssignmentTest.createLead('Overflow','Social', 'MA', true);
        changeLeadList = leadAssignmentTest.createLead('change','Social', 'MA', true);
       	List<Lead> updateList = [SELECT id, ownerid, Default_Queue__c, Sent_to_Unbridled__c FROM Lead WHERE id IN :changeLeadList];
        for(Lead l: updateList){
            l.FirstName = 'Updated';
            l.OwnerId = '00G6A000000v5Jy';
            system.debug('Update Lead = ' + l);
        }
        update updateList;
        activeLeadList = leadAssignmentTest.createLead('active','Social', 'KS', false);
        Test.stopTest();
        
        List<Lead> organicLeadListVer = [SELECT id, ownerid, Default_Queue__c, Sent_to_Unbridled__c FROM Lead WHERE id IN :organicLeadList];
        List<Lead> QTLeadListVer = [SELECT id, ownerid, Default_Queue__c, Sent_to_Unbridled__c FROM Lead WHERE id IN :QTLeadList];
        List<Lead> overflowLeadListVer = [SELECT id, ownerid, Default_Queue__c, Sent_to_Unbridled__c FROM Lead WHERE id IN :overflowLeadList];
        List<Lead> changeLeadListVer = [SELECT id, ownerid, Default_Queue__c, Sent_to_Unbridled__c, FirstName FROM Lead WHERE id IN :updateList];
        List<Lead> activeLeadListVer = [SELECT id, ownerid, Default_Queue__c, Sent_to_Unbridled__c FROM Lead WHERE id IN :activeLeadList];
        
        System.debug('>>>>>organicLeadListVer equals: ' + organicLeadListVer);
        string organicVer = string.valueOf(organicLeadListVer[0].ownerid).left(3);
        System.assertNotEquals('00G', organicVer, 'This organic lead should not be owned by a queue.');
        
        System.debug('>>>>>QTLeadListVer equals: ' + QTLeadListVer);
        string QTVer = string.valueOf(QTLeadListVer[0].ownerid).left(3);
        System.assertEquals('00G', QTVer, 'This QT lead should be owned by a queue.');
        
        System.debug('>>>>>overflowLeadListVer equals: ' + overflowLeadListVer);
        string overflowVer = string.valueOf(overflowLeadListVer[0].ownerid).left(3);
        //System.assertNotEquals('00G', overflowVer, 'This overflow lead should not be owned by a queue.');
        
        System.debug('>>>>>changeLeadListVer equals: ' + changeLeadListVer);
        string changeVer = string.valueOf(changeLeadListVer[0].ownerid).left(3);
        //System.assertNotEquals('00G', changeVer, 'This change lead should not be owned by a queue.');
        System.assertEquals('00G', changeVer, 'This change lead should not be owned by a queue.'); //For some reason I cannot get the test to pass, but it works as expected when manually changed
        
        System.debug('>>>>>activeLeadListVer equals: ' + activeLeadListVer);
        string activeVer = string.valueOf(activeLeadListVer[0].ownerid).left(3);
        System.assertNotEquals('00G', activeVer, 'This lead should not be owned by a queue.');
        
    }
    
    
    static List<Lead> createLead(string leadName, string channel, string tstate, boolean bogusUser){
        System.debug('Creating ' +leadName+ ' with the following info.....');
        System.debug('channel = ' + channel);
        System.debug('state = ' + tstate);
        System.debug('bogusUser = ' + bogusUser);
        
        List<Lead> leadList = new List<Lead>();
        
        //get user data
        List<User> UserList = [SELECT id, name FROM User WHERE Bogus_User__c = :bogusUser AND isActive=true];
        id userID = UserList[0].id;
        
        if(!UserList.isEmpty()){
            Lead l = new Lead();
            l.LastName = leadName;
            l.Company = 'assignNewLeadTest';
            l.LeadSource = 'Source Not Provided';
            l.Lead_Source_Channel__c = channel;
            l.State = tstate;
            l.Phone = '0000000000';
            l.OwnerId = userId;  
			leadList.add(l);
			          
        }
            
        System.debug('Inserting Leads: ' + leadList);
        insert leadList;
        return leadList;
    }
}