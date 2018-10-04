@isTest
private class Test_RESTProcessLead 
{
    static testMethod void POST_BadRequest_CannotDeserializeRequest()
    {
        string json = '{"Actual_Start_Date__c":"ABCDEFGHIJKLMNOPQRSTUVWXYZ"}';
        
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        
        request.requestURI = '/services/apexrest/ProcessLead/';
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueOf(json);
        
        RestContext.request = request;
        RestContext.response = response;
        
        Test.startTest();
        RESTProcessLeadResponse postResponse = RESTProcessLeadController.ProcessLead();        
        System.assert(postResponse.Success == false);
        System.assert(postResponse.StatusCode == 400);
        System.assert(postResponse.Message == 'An error occurred deserializing the request.');
        Test.stopTest();
    }
    
    static testMethod void POST_BadRequest_NullLastName()
    {
        string json = '{"FirstName":"Test_RESTProcessLead"}';
        
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        
        request.requestURI = '/services/apexrest/ProcessLead/';
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueOf(json);
        
        RestContext.request = request;
        RestContext.response = response;
        
        Test.startTest();
        RESTProcessLeadResponse postResponse = RESTProcessLeadController.ProcessLead();        
        System.assert(postResponse.Success == false);
        System.assert(postResponse.StatusCode == 400);
        System.assert(postResponse.Message == 'LastName parameter required.');
        Test.stopTest();
    }
    
    static testMethod void POST_InternalServerError_ErrorUpdatingContact()
	{
        Contact contact = new Contact();
        contact.FirstName = 'Test_RESTProcessLead';
        contact.LastName = 'POST_InternalServerError_ErrorUpdatingContact';
        contact.Email = 'POST_InternalServerError_ErrorUpdatingContact@test.com';
        contact.Phone = '5555550000';
        insert contact;
        
        string json = '{"LastName":"POST_InternalServerError_ErrorUpdatingContact","Email":"POST_InternalServerError_ErrorUpdatingContact@test.com","Phone":"ABCDEFGHIJKLMNOPQRSTUVWXYZABCDEFGHIJKLMNOPQRSTUVWXYZ"}'; 
        
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        
        request.requestURI = '/services/apexrest/ProcessLead/';
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueOf(json);
        
        RestContext.request = request;
        RestContext.response = response;
        
        Test.startTest();
        RESTProcessLeadResponse postResponse = RESTProcessLeadController.ProcessLead();
        System.assert(postResponse.Success == false);
        System.assert(postResponse.StatusCode == 500);
        System.assert(postResponse.Message == 'An error occurred updating Contact: ' + contact.Id);
        Test.stopTest();   
    }
    
    static testMethod void POST_InternalServerError_ErrorUpdatingLead()
	{
        Lead lead = new Lead();
        lead.FirstName = 'Test_RESTProcessLead';
        lead.LastName = 'POST_InternalServerError_ErrorUpdatingLead';
        lead.Email = 'POST_InternalServerError_ErrorUpdatingLead@test.com';
        lead.Phone = '5555550000';
        lead.Company = 'Test';
        lead.LeadSource = 'Test';
        insert lead;
        
        string json = '{"LastName":"POST_InternalServerError_ErrorUpdatingLead","Email":"POST_InternalServerError_ErrorUpdatingLead@test.com","Phone":"ABCDEFGHIJKLMNOPQRSTUVWXYZABCDEFGHIJKLMNOPQRSTUVWXYZ"}'; 
        
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        
        request.requestURI = '/services/apexrest/ProcessLead/';
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueOf(json);
        
        RestContext.request = request;
        RestContext.response = response;
        
        Test.startTest();
        RESTProcessLeadResponse postResponse = RESTProcessLeadController.ProcessLead();
        System.assert(postResponse.Success == false);
        System.assert(postResponse.StatusCode == 500);
        System.assert(postResponse.Message == 'An error occurred updating Lead: ' + lead.Id);
        Test.stopTest();   
    }
    
    static testMethod void POST_InternalServerError_ErrorCreatingLead()
    {
        string json = '{"FirstName":"Test_RESTProcessLead","LastName":"POST_InternalServerError_ErrorCreatingLead", "Email":"test","Phone":"5555550000","Company":"Test","LeadSource":"Test"}'; 
        
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        
        request.requestURI = '/services/apexrest/ProcessLead/';
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueOf(json);
        
        RestContext.request = request;
        RestContext.response = response;
        
        Test.startTest();
        RESTProcessLeadResponse postResponse = RESTProcessLeadController.ProcessLead();
        System.assert(postResponse.Success == false);
        System.assert(postResponse.StatusCode == 500);
        System.assert(postResponse.Message == 'An error occurred creating Lead.');
        Test.stopTest(); 
    }
    
    static testMethod void POST_Success_MatchOnContactEmail()
    {
        Contact contact = new Contact();
        contact.FirstName = 'Test_RESTProcessLead';
        contact.LastName = 'POST_Success_MatchOnContactEmail';
        contact.Email = 'POST_Success_MatchOnContactEmail@test.com';
        contact.Phone = '5555550000';
        insert contact;
        
        string json = '{"LastName":"POST_Success_MatchOnContactEmail","Email":"POST_Success_MatchOnContactEmail@test.com","Phone":"5555550001"}';
        
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        
        request.requestURI = '/services/apexrest/ProcessLead/';
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueOf(json);
        
        RestContext.request = request;
        RestContext.response = response;
        
        Test.startTest();
        RESTProcessLeadResponse postResponse = RESTProcessLeadController.ProcessLead();
        System.assert(postResponse.Success == true);
        System.assert(postResponse.StatusCode == 201);
        System.assert(postResponse.Message == 'Contact updated. ID: ' + contact.Id);
        Test.stopTest();            
    }
    
	static testMethod void POST_Success_MatchOnContactPhone()
    {
        Contact contact = new Contact();
        contact.FirstName = 'Test_RESTProcessLead';
        contact.LastName = 'POST_Success_MatchOnContactPhone';
        contact.Email = 'POST_Success_MatchOnContactPhone@test.com';
        contact.Phone = '5555550000';
        insert contact;
        
        string json = '{"LastName":"POST_Success_MatchOnContactPhone","Email":"test@test.com","Phone":"5555550000"}';
        
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        
        request.requestURI = '/services/apexrest/ProcessLead/';
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueOf(json);
        
        RestContext.request = request;
        RestContext.response = response;
        
        Test.startTest();
        RESTProcessLeadResponse postResponse = RESTProcessLeadController.ProcessLead();
        System.assert(postResponse.Success == true);
        System.assert(postResponse.StatusCode == 201);
        System.assert(postResponse.Message == 'Contact updated. ID: ' + contact.Id);
        Test.stopTest();            
    }
    
    static testMethod void POST_Success_MatchOnLeadEmail()
    {
        Lead lead = new Lead();
        lead.FirstName = 'Test_RESTProcessLead';
        lead.LastName = 'POST_Success_MatchOnLeadEmail';
        lead.Email = 'POST_Success_MatchOnLeadEmail@test.com';
        lead.Phone = '5555550000';
        lead.Company = 'Test';
        lead.LeadSource = 'Test';
        insert lead;
        
        string json = '{"LastName":"POST_Success_MatchOnLeadEmail","Email":"POST_Success_MatchOnLeadEmail@test.com","Phone":"5555550001"}';
        
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        
        request.requestURI = '/services/apexrest/ProcessLead/';
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueOf(json);
        
        RestContext.request = request;
        RestContext.response = response;
        
        Test.startTest();
        RESTProcessLeadResponse postResponse = RESTProcessLeadController.ProcessLead();
        System.assert(postResponse.Success == true);
        System.assert(postResponse.StatusCode == 201);
        System.assert(postResponse.Message == 'Lead updated. ID: ' + lead.Id);
        Test.stopTest();            
    }
        
    static testMethod void POST_Success_MatchOnLeadPhone()
    {
        Lead lead = new Lead();
        lead.FirstName = 'Test_RESTProcessLead';
        lead.LastName = 'POST_Success_MatchOnLeadPhone';
        lead.Email = 'POST_Success_MatchOnLeadPhone@test.com';
        lead.Phone = '5555550000';
        lead.Company = 'Test';
        lead.LeadSource = 'Test';
        insert lead;
        
        string json = '{"LastName":"POST_Success_MatchOnLeadPhone","Email":"test@test.com","Phone":"5555550000"}';
        
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        
        request.requestURI = '/services/apexrest/ProcessLead/';
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueOf(json);
        
        RestContext.request = request;
        RestContext.response = response;
        
        Test.startTest();
        RESTProcessLeadResponse postResponse = RESTProcessLeadController.ProcessLead();
        System.assert(postResponse.Success == true);
        System.assert(postResponse.StatusCode == 201);
        System.assert(postResponse.Message == 'Lead updated. ID: ' + lead.Id);
        Test.stopTest();            
    }
}