public class leadAssignment {
    public void assignNewLead(boolean IsUpdate, List<Lead> newLead, Map<Id, Lead> oldMap_Leads){
        System.debug('leadAssignment.assignNewLead is running........................................................................');
        
        List<Lead> newLeadList = new List<Lead>();
        Set<string> queueSet = new Set<string>();
        
        //before triggers do not update formula fields, so a dummy field has to be created
        for(Lead l: newLead){
            if(l.Id == null){
                System.debug('Updating Default_Queue_Text__c. Lead_Source_Channel__c = ' + l.Lead_Source_Channel__c);
                if(l.Lead_Source_Channel__c == 'PPL'){
                    l.Default_Queue_Text__c = 'Q&T Queue';
                }
                else if(l.Lead_Source_Channel__c == 'Social'){
                    l.Default_Queue_Text__c = 'Q&T Queue';
                }
                else if(l.Lead_Source_Channel__c == 'PPC' && l.UTM_Content__c == 'Nonbrand'){
                    l.Default_Queue_Text__c = 'Q&T Queue';
                }            
                else if(l.Default_Queue_Text__c == null){
                    l.Default_Queue_Text__c = 'Organic Queue';
                }
                if(l.Default_Queue_Text__c == 'Q&T Queue' && l.State == 'MA'){
                    l.Default_Queue_Text__c = 'Overflow Lead Queue';
                }
            } else {
                l.Default_Queue_Text__c = l.Default_Queue__c;
            }
        }
        
        for(Lead l: newLead){
            //l.recalculateFormulas();
            if(userVerification.activeVerify(l.OwnerId)==false){ //if owned by invalid user
                System.debug(l.LastName + ' Default Queue = ' + l.Default_Queue_Text__c);
                queueSet.add(l.Default_Queue_Text__c);
                newLeadList.add(l);
            }
            
        }
        
        System.debug('assignNewLead running on these leads: ' +newLeadList);
        
        //Only do work if the lead is owned by an invalid user
        //This is because reps might create leads, so we don't want those reassigned
        if(newLeadList.size()>0){            
            
            //Create a map with the queue name as the key
            List<Group> queueList = [SELECT id, name FROM Group WHERE Type='Queue' AND name IN :queueSet];
            Map<string, id> queueNameMap = new Map<string,id>();
            for(Group g: queueList){
                queueNameMap.put(g.name, g.Id);
            }
            
            //List to pass to Round Robin assignment
            List<Lead> reassignLeadList = new List<Lead>();
            
            //Check if the owner is owned by a queue, if so, assign round robin
            for(Lead l: newLead){
                //Separate out the Q&T Leads first
                if(l.Default_Queue_Text__c == 'Q&T Queue' && l.Sent_to_Unbridled__c == false){
                    if(queueNameMap.containsKey(l.Default_Queue_Text__c) && queueNameMap.get(l.Default_Queue_Text__c) != null){ //null check
                        l.ownerId = queueNameMap.get(l.Default_Queue_Text__c); //Assign to the Q&T queue
                        l.Sent_to_Unbridled__c = true; //Mark for the after trigger
                    }
                
                } else if(businessHoursVerification.checkBusinessHours(System.now()) && l.Default_Queue_Text__c == 'Organic Queue'){
                    //Send email to phone handler if within business hours
                    //avtexEmailSend handler = new avtexEmailSend();
                    //handler.sendEmail(l.Id,l.Phone,l.Lead_Source_Channel__c,l.LeadSource,l.UTM_Content__c);
                    l.Avtex_Send_Email__c = true;
                    //Since the phone handler will reassign, no other action is needed
                
                } else if(queueNameMap.containsKey(l.Default_Queue_Text__c) && queueNameMap.get(l.Default_Queue_Text__c) != null){ 
                    //If not in business hours, round robin assignment
                        l.ownerId = queueNameMap.get(l.Default_Queue_Text__c); //Assign to a queue
                        reassignLeadList.add(l); //add to reassignLeadList
                    }
                }
            
            if(reassignLeadList.size()>0){
                //Send to another class to assign the leads to users in round robin fashion
                AssignmentGroup_LeadRoundRobin.AssignLead(false, newLead, oldMap_Leads);
            }
        }
    }

    public void queueOwnerCheck(boolean IsUpdate, List<Lead> newLead, Map<Id, Lead> oldMap_Leads){
        System.debug('queueOwnerCheck running....................................................');
        List<Lead> queueLeads = new List<Lead>();
        for(Lead l: newLead){
            if(string.valueOf(l.OwnerId).startsWith('00G')){
                queueLeads.add(l);
                System.debug(l.id + ' owned by Queue');
            } else {System.debug(l.id + ' not owned by Queue');}
        }
        
        if(queueLeads.size()>0){
            //Send to another class to assign the leads to users in round robin fashion
            AssignmentGroup_LeadRoundRobin.AssignLead(true, newLead, oldMap_Leads);
        }
    }    
}