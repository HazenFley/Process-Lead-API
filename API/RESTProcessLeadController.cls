@RestResource(urlMapping='/ProcessLead/*')
global with sharing class RESTProcessLeadController 
{    
    @HttpPost
    global static RESTProcessLeadResponse ProcessLead()
    { 
        // Initialize our variables
        Lead lead; // The deserialized JSON request
        Inquiry__c inquiry; // Inquiry object, one for each Post
        List<Lead> leadList; // Lead search matches
        List<Contact> contactList; // Contact search matches
        
        // Gather data from request
        string jsonRequest = RestContext.request.requestBody.toString(); // JSON request as a string
        System.debug(jsonRequest);
        
        // Deserialize the incoming JSON, casting to a Lead sobject
        try
        {
            lead = (Lead) JSON.deserialize(jsonRequest, Lead.class);
        }
        catch(Exception ex)
        {
            System.debug('Exception: ' + ex.getMessage());
            IntegrationLogHelper.CreateIntegrationLogs(ex);
            return RESTProcessLeadRepository.ProcessReturn(400, 'An error occurred deserializing the request.'); 
        }
        
        // We must have last name 
        if(string.isBlank(lead.LastName))
            return RESTProcessLeadRepository.ProcessReturn(400, 'LastName parameter required.');            
        
        // Try to find a Contact record for [Email] or [LastName & Phone], sorting by the oldest record first
        try
        { 
            if(string.isBlank(lead.Email) && string.isNotBlank(lead.Phone))
                contactList = [SELECT ID, Email, FirstName, LastName, Phone, OwnerID 
                               FROM Contact 
                               WHERE Phone = :lead.Phone AND LastName = :lead.LastName 
                               ORDER BY CreatedDate DESC]; 
            if(string.isBlank(lead.Phone) && string.isNotBlank(lead.Email))
                contactList = [SELECT ID, Email, FirstName, LastName, Phone, OwnerID 
                               FROM Contact 
                               WHERE Email = :lead.Email                                                          
                               ORDER BY CreatedDate DESC];  
            if(string.isNotBlank(lead.Phone) && string.isNotBlank(lead.Email))
                contactList = [SELECT ID, Email, FirstName, LastName, Phone, OwnerID 
                               FROM Contact 
                               WHERE Email = :lead.Email                            
                               OR (Phone = :lead.Phone AND LastName = :lead.LastName) 
                               ORDER BY CreatedDate DESC];   
        }
        catch(Exception ex)
        {            
            System.debug('Exception: ' + ex.getMessage());
            IntegrationLogHelper.CreateIntegrationLogs(ex);
            return RESTProcessLeadRepository.ProcessReturn(500, 'An error occurred while searching Contacts.'); 
        } 
        
        if(contactList != null && contactList.Size() > 0)
        {
            // Here we set the logic on what to update on the Contact record
            Contact contact = contactList[0];
            if(contact.Email == lead.Email && contact.Phone != lead.Phone) contact.Phone = lead.Phone;
            
            try
            {
                update contact;   
                RESTProcessLeadRepository.CreateInquiry(contact.Id, contact.OwnerId ,lead);
                return RESTProcessLeadRepository.ProcessReturn(201,  'Contact updated. ID: ' + contact.Id); 
            }
            catch(DmlException ex)
            {
                System.debug('Exception: ' + ex.getMessage());
                IntegrationLogHelper.CreateIntegrationLogs(ex);
                return RESTProcessLeadRepository.ProcessReturn(500,  'An error occurred updating Contact: ' + contact.Id); 
            }                    
        }
        else
        {
            System.debug('No Contact record found');
            
            // Try to find a Lead record for [Email] or [LastName & Phone], sorting by the oldest record first
            try
            {
                
                if(string.isBlank(lead.Email) && string.isNotBlank(lead.Phone))
                    leadList = [SELECT ID, Email, FirstName, LastName, Phone, OwnerID 
                                FROM Lead 
                                WHERE Phone = :lead.Phone AND LastName = :lead.LastName 
                                ORDER BY CreatedDate DESC]; 
                if(string.isBlank(lead.Phone) && string.isNotBlank(lead.Email))
                    leadList = [SELECT ID, Email, FirstName, LastName, Phone, OwnerID 
                                FROM Lead 
                                WHERE Email = :lead.Email                                                          
                                ORDER BY CreatedDate DESC];  
                if(string.isNotBlank(lead.Phone) && string.isNotBlank(lead.Email))
                    leadList = [SELECT ID, Email, FirstName, LastName, Phone, OwnerID 
                                FROM Lead 
                                WHERE Email = :lead.Email                            
                                OR (Phone = :lead.Phone AND LastName = :lead.LastName) 
                                ORDER BY CreatedDate DESC];
            }
            catch(DmlException ex)
            {
                System.debug('Exception: ' + ex.getMessage());
                IntegrationLogHelper.CreateIntegrationLogs(ex);
                return RESTProcessLeadRepository.ProcessReturn(500, 'An error occurred while searching Leads.'); 
            } 
            
            if(leadList != null && leadList.Size() > 0)
            {
                // Here we set the logic on what to update on the Lead record
                Lead leadUpdate = leadList[0];
                if(leadUpdate.Email == lead.Email && leadUpdate.Phone != lead.Phone) leadUpdate.Phone = lead.Phone;
                
                try
                {
                    update leadUpdate;
                    RESTProcessLeadRepository.CreateInquiry(leadUpdate.Id, leadUpdate.OwnerId, lead);
                    return RESTProcessLeadRepository.ProcessReturn(201,  'Lead updated. ID: ' + leadUpdate.Id); 
                }
                catch(DmlException ex)
                {
                    System.debug('Exception: ' + ex.getMessage());
                    IntegrationLogHelper.CreateIntegrationLogs(ex);
                    return RESTProcessLeadRepository.ProcessReturn(500, 'An error occurred updating Lead: ' + leadUpdate.Id); 
                }
            }
            else
            {
                System.debug('No Lead record found');
                
                // If no Contact or Lead record is found, we create a new Lead record
                if(lead.Company == null) lead.Company = lead.LastName + ', ' + lead.FirstName + ' Account';
                if(lead.LeadSource == null) lead.LeadSource = 'Source Not Provided';
                
                try
                {
                    insert lead;
                    RESTProcessLeadRepository.CreateInquiry(lead.Id, lead.OwnerId, lead);
                    return RESTProcessLeadRepository.ProcessReturn(201,  'Lead created. ID: ' + lead.Id); 
                }
                catch(DmlException ex)
                {   
                    System.debug('Exception: ' + ex.getMessage());
                    IntegrationLogHelper.CreateIntegrationLogs(ex);
                    return RESTProcessLeadRepository.ProcessReturn(500, 'An error occurred creating Lead.'); 
                }
            }
        }
    }
    
}