@isTest
public class inqMarketingInfoTest {
    @isTest static void addVendorInfoTest(){
        System.debug('Creating two contacts and an inquiry each. One has LeadSource, one has CID. Each Inquiry should have Vendor information.');
        
        List<Inquiry__c> CIDlist = new List<Inquiry__c>();
        List<Inquiry__c> leadSourceList = new List<Inquiry__c>();
        
        Test.startTest();
        CIDlist = inqMarketingInfoTest.createInqOnContactTest(1,1,'0001', 'Match CID');
        leadSourceList = inqMarketingInfoTest.createInqOnContactTest(1,1, '', 'findSource');
        Test.stopTest();
        
        List<Inquiry__c> CIDlistCheck = [SELECT id, Vendor_Source__c, LeadSource__c FROM Inquiry__c WHERE id IN :CIDlist];
        List<Inquiry__c> leadSourceListCheck = [SELECT id, Vendor_Source__c, LeadSource__c FROM Inquiry__c WHERE id IN :leadSourceList];
		List<Vendor_Source__c> verifyVendor =[SELECT id, CID__c, Source__c FROM Vendor_Source__c WHERE CID__C = '0001' OR Source__c='findSource'];        
        
        System.debug('verifyVendor = ' + verifyVendor);
        
        System.debug('CIDlistCheck = ' + CIDlistCheck);
        System.assertNotEquals(null, CIDlistCheck[0].Vendor_Source__c, 'Inquiry Vendor Source was null');
        System.assertEquals('Match CID', CIDlistCheck[0].LeadSource__c, 'CID Matched on wrong vendor source');
        
        System.debug('leadSourceListCheck = ' + leadSourceListCheck);
        System.assertNotEquals(null, leadSourceListCheck[0].Vendor_Source__c, 'Inquiry Vendor Source was null');
        System.assertEquals('findSource', leadSourceListCheck[0].LeadSource__c, 'Source__c Matched on wrong vendor source');
    }
    
    
    
    static List<Inquiry__c> createInqOnContactTest(integer numCont, integer numInq, string cid, string vsource){
        //Create Contacts
        List<Contact> contsList = new List<Contact>();        
        for(Integer i=0; i<numCont;){
            System.debug('Creating Contact ' + i);
            Contact c = new Contact(LastName='TestContact', FirstName='Number ' + i);
            contsList.add(c);
            i = i + 1;
        }         
        
        System.debug('Inserting Contacts');
        System.debug('contsList = ' + contsList);
        insert contsList;
        
        //Create Vendor Sources
        List<Vendor_Source__c> VSList = new List<Vendor_Source__c>();
        Vendor_Source__c v = new Vendor_Source__c(CID__c=cid, Source__c=vsource);
        system.debug('Vendor_Source__c being created with these variables: ' + v);
        insert v;
        
        //Insert Inquiries
        List<Inquiry__c> inqList = new List<Inquiry__c>();
        if(numInq>0){
            for(integer j=0; j<numCont;){
                Contact cont = contsList[j];
                //For each contact just created, add tasks
                for(integer l=0; l<numInq; l++){
                    System.debug('Creating Inquiry ' + l);
                    inqList.add(new Inquiry__c(Name='Inquiry #' +l,
                                               Contact__c = cont.Id,
                                               CID__c = cid,
                                               LeadSource__c = vsource
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