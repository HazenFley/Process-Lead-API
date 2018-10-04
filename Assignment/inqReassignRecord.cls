public class inqReassignRecord {
    public void reassignInsert(Inquiry__c[] newInq){
        System.debug('inqReassignRecord.reassignInsert running..........................................');
        
        Set<Id> contactSet = new Set<Id>();
        Set<Id> leadSet = new Set<Id>();
        
        for(Inquiry__c i: newInq){
            if(i.lead__c != null){leadSet.add(i.lead__c);}
            if(i.contact__c != null){contactSet.add(i.Contact__c);}
        }
        
        System.debug('contactSet = ' + contactSet);
        System.debug('leadSet = ' + leadSet);
        
        if(LeadSet.size()>0){
            List<Lead> leadList = [SELECT id, ownerid, Reassign_Record__c, Default_Queue__c, phone, Lead_Source_Channel__c, LeadSource, UTM_Content__c, Sent_to_Unbridled__c,Activity_Count__c, Inquiries_Submitted__c  FROM Lead WHERE id IN :leadSet];
            Map<id,Lead> leadMap = new Map<id,Lead>([SELECT id, ownerid, Reassign_Record__c, Default_Queue__c, phone, Lead_Source_Channel__c, LeadSource, UTM_Content__c, Sent_to_Unbridled__c  FROM Lead WHERE id IN :leadSet]);
			
            List<Lead> reassignLeadList = new List<Lead>();
            for(Lead l: leadList){
                if(l.Inquiries_Submitted__c>0 && l.Inquiries_Submitted__c !=null){
                    //don't reassign leads on insert, best way to know this is to make sure they dont' have inquiries
                    reassignLeadList.add(l);
                }
            }
            
            System.debug('reassignLeadList: ' +reassignLeadList);
            leadAssignment assign = new leadAssignment();
            assign.assignNewLead(true, reassignLeadList, leadMap);
        }
    }
}