public class inqCreateRelRecords {
    public void createRecords(Inquiry__c[] newInquiry){
        System.debug('Starting createRecords....................................................................');
        set<id> leadSet = new set<id>();
        set<id> contSet = new set<id>();
        Map<id, Inquiry__c> inqMap = new Map<id,Inquiry__c>();
        for(Inquiry__c i: newInquiry){
            if(i.Lead__c != null){leadSet.add(i.Lead__c);}
            if(i.Contact__c != null){contSet.add(i.contact__c);}
        }
        
        List<Task> createTaskList = new List<Task>();
        List<Opportunity> createOpportunityList = new List<Opportunity>();
        List<Case> createCaseList = new List<Case>();
        
        List<Group> queueList = [SELECT id, name FROM Group WHERE Type='Queue' AND name = 'ORS Queue'];
        id ORSqueueID = null;
        if(queueList.size()>0){
            ORSqueueID = queueList[0].id;
        }
        
        if(leadSet.size()>0){
            System.debug('Working on Leads...');
            List<Lead> leadQuery = [SELECT id, lastName, ownerid, Activity_Count__c, Inquiries_Submitted__c  FROM Lead WHERE id IN :leadSet];
            
            for(Lead l: leadQuery){
                for(Inquiry__c i: newInquiry){
                    if(i.Lead__c == l.id  && userVerification.activeVerify(l.OwnerId)==true ){ //We don't want tasks created on invalid users
                        createTaskList.add(new Task(OwnerId = l.OwnerId,                                                    
                                                    WhoId = l.Id,                                                    
                                                    WhatId = i.Id,
                                                    ActivityDate = System.today(),
                                                    Status = 'Open',
                                                    Priority = 'Normal',
                                                    Subject =  'New Inquiry',
                                                    Description = 'This person has submitted an inquiry. Please investigate.'
                                                   ));
                    }
                }
            }            
        }
        
        if(contSet.size()>0){
            System.debug('Working on Contacts.....');
            
            integer oppCount = null;
            boolean validOwner = false;
            
            List<Contact> contactQuery = [SELECT id, FirstName, LastName, Opportunity_Count_Open__c, ownerid, accountid, /*Activity_Count__c,*/ Inquiries_Submitted__c FROM Contact WHERE id IN :contSet];
            
            for(Contact c: contactQuery){
                
                //Check if contact is owned by a valid user and store that value
                if(userVerification.activeVerify(c.OwnerId)==true){
                    validOwner = true;
                } else {validOwner = false;}                
                
                for(Inquiry__c i: newInquiry){
                    if(i.Contact__c == c.id){
                        
                        //If the owner is valid, then check if a new opp needs to be created
                        system.debug('Running on this contact: ' + c.id + ' and validOwner = : ' + validOwner);
                        if(validOwner == true){
                            if(c.Opportunity_Count_Open__c == 0 || c.Opportunity_Count_Open__c == null){                            
                                i.Create_Opportunity__c = true;
                                createOpportunityList.add(new Opportunity(Name = c.LastName + ' New Inquiry',
                                                                          AccountId = c.accountid,
                                                                          Contact__c = c.id,
                                                                          OwnerId = c.OwnerId,
                                                                          CloseDate = System.today() + 60,
                                                                          Follow_Up_Call_Date_Time__c = System.now(),
                                                                          StageName = 'New',
                                                                          Description = c.FirstName + ' ' + c.LastName + ' has submitted an inquiry. Please investigate.'                                                                      
                                                                         ));
                            }
                            
                            //Also create a task on the contact
                            createTaskList.add(new Task(OwnerId = c.OwnerId,                                                    
                                                    WhoId = c.Id,                                                    
                                                    WhatId = i.Id,
                                                    ActivityDate = System.today(),
                                                    Status = 'Open',
                                                    Priority = 'Normal',
                                                    Subject = c.FirstName +' '+ c.lastname + ' Inquiry Submit',
                                                    Description = 'This person has submitted an inquiry. Please investigate.'
                                                   ));     
                        }                        
                        else if(validOwner == false){ //if the owner is inactive, create a case that will be routed
                            if(ORSqueueID==null){
                                ORSqueueID='00G18000001Hra3';
                            }                            
                            createCaseList.add(new Case(ownerid=ORSqueueID,
                                                        ContactId=c.Id,
                                                        Origin='Web',
                                                        Subject = c.FirstName +' '+ c.lastname + ' Inquiry Submit',
                                                        Description = 'This person has submitted an inquiry. Please investigate.'
                                                       ));
                            System.debug('Creating case with this contact: ' + c.id);
                        }
                    }
                } 
            }            
        }
        
        //DML statements
        if(createTaskList.size()>0){
            System.debug('Inserting createTaskList: ' + createTaskList);
            Database.SaveResult[] taskDML = Database.insert(createTaskList,false);
        }
        if(createOpportunityList.size()>0){
            System.debug('Inserting createOpportunityList: ' + createOpportunityList);
            Database.SaveResult[] oppDML = Database.insert(createOpportunityList,false);
        }
        if(createCaseList.size()>0){
            System.debug('Inserting createCaseList: ' + createCaseList);
            Database.SaveResult[] caseDML = Database.insert(createCaseList,false);
        }
    }
}