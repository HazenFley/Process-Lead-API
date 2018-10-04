public class RESTProcessLeadRepository 
{
    public static RESTProcessLeadResponse ProcessReturn(integer statusCode, string message)
    {
        boolean success = false;  
        string jsonRequest = RestContext.request.requestBody.toString(); // JSON request as a string
        System.debug(message + '; Request: ' + jsonRequest + ';'); 
        
        if(statusCode == 200 || statusCode == 201) success = true;
        RESTProcessLeadResponse response = new RESTProcessLeadResponse(success, statusCode, message, jsonRequest);            
        RestContext.response.statusCode = response.StatusCode;
        
        return response; 
    } 
    
    public static void CreateInquiry(string id, string ownerID, Lead lead)
    {   
        try
        {
            Inquiry__c inquiry = BuildInquiryObject(id, ownerID, lead);
            insert inquiry;
            System.debug('Inquiry__c created. ID: ' + inquiry.Id);
        }
        catch(Exception ex)
        {
            System.debug('Exception: ' + ex.getMessage());
            IntegrationLogHelper.CreateIntegrationLogs(ex);
        }
    }
    
    // Map the deserialized incoming request (cast as a Lead object) to an Inquiry__c object
    private static Inquiry__c BuildInquiryObject(string id, string ownerID, Lead l)
    {
    	Inquiry__c i = new Inquiry__c(); 
        
        if(id.substring(0,3) == '003') i.Contact__c = id; // 003 is the Contact Prefix
        else if(id.substring(0,3) == '005') {i.Lead__c = id;} // 005 is the Lead Prefix
        else if(id.substring(0,3) == '00Q') {/*i.Lead__c = id;*/} // 00Q is the Queue Prefix (do we want to do anything here?)
        if(ownerID == null || ownerID.substring(0,3) == '00G') i.OwnerId = '0056A000001Z0YkQAK'; // // 00G is the QueueSobject Prefix; Check if OwnerID is a QueueSobject or null and set Inquiry OwnerID to api user
        else i.OwnerId = ownerID;
        i.adPosition__c = l.adPosition__c;
        i.Alternate_Email__c = l.Alternate_Email__c;
        i.Alternate_Phone__c = l.Alternate_Phone__c;
        i.Anticipated_Financing_Source__c = l.Anticipated_Financing_Source__c;
        i.Are_you_currently_employed__c = l.Are_you_currently_employed__c;
        i.Canyoudownloadandinstallprograms__c = l.Can_you_download_and_install_programs__c;
        i.CCM_ID__c = l.CCM_ID__c;
        i.CCMedia__c = l.CCMedia__c;
        i.CID__c = l.CID__c;
        i.CMID__c = l.CMID__c;
        i.ComputerwithInternet__c = l.Computer_with_Internet__c;    
        i.CreatedById = l.CreatedById;
        i.CreatedDate = l.CreatedDate;
        i.Currently_Deployed__c = l.Currently_Deployed__c;
        i.Data_Migration__c = l.DataMigration__c;
        i.Date_of_Birth__c = l.Date_of_Birth__c;
        i.Degree_Program__c = l.Degree_Program__c;
        i.Desired_Degree_Level__c = l.Degree_Level__c;
        i.Do_Not_Call__c = l.DoNotCall;
        i.Duty_Station__c = l.Duty_Station2__c;
        i.Email__c = l.Email;
        i.First_Name__c = l.FirstName;
        i.FOB__c = l.FOB2__c;
        i.Graduation_Date__c = l.Graduation_Date__c;
        i.High_School_or_GED__c = l.High_School_or_GED__c;
        i.Hubspot_Token__c = l.Hubspot_Token__c;
        i.IP_Address__c = l.IP_Address__c;
        i.Jornaya_Key__c = l.Jornaya_Key__c;
        i.Keyword__c = l.Keyword__c;
        i.Last_Name__c = l.LastName;
        i.LastModifiedById = l.LastModifiedById;
        i.LastModifiedDate = l.LastModifiedDate;
        i.LeadQual_LeadID__c = l.LeadQual_LeadID__c;
        i.LeadSource__c = l.LeadSource;
        i.Middle_Name__c = l.MiddleName; 
        i.Military_Affiliation__c = l.Military_Affiliation__c;
        i.Military_Branch__c = l.Military_Branch__c;
        i.Military_Occupation_Specialty_MOS_AFS__c = l.Military_Occupation_Specialty_MOS_AFS__c;
        i.Military_Status__c = l.Military_Status__c;
        i.Month_to_Start_Classes__c = l.MonthtoStartClasses__c;
        i.Motivation__c = l.Motivation__c;
        i.Name = l.FirstName + ' ' + l.Lastname;
        i.Network__c = l.Network__c;        
        i.Pay_Grade__c = l.Pay_Grade2__c;
        i.Phone__c = l.Phone;
        i.Random__c = l.Random__c;
        i.Salutation__c = l.Salutation;
        i.Scholarships__c = l.Scholarships__c;
        i.SMS_Opt_In__c = l.SMS_Opt_In__c;
        i.SSN__c = l.SSN__c;
        i.Status__c = i.Status__c;
        i.Suffix__c = l.Suffix;
        i.TCPA_Acknowledgement__c = l.TCPA_Acknowledgement__c;
		i.Term_1_Classes__c = l.Term_1_Classes__c;
        i.Term_2_Classes__c = l.Term_2_Classes__c; 
        i.UTM_Campaign__c = l.UTM_Campaign__c;
        i.UTM_Content__c = l.UTM_Content__c;
        i.UTM_Medium__c = l.UTM_Medium__c;
        i.UTM_Source__c = i.UTM_Source__c;
        i.UTM_Term__c = l.UTM_Term__c;
        i.Vendor_Source__c = l.Vendor_Source__c;
        i.Whattypeofcomputerdoyouhave__c = l.What_type_of_computer_do_you_have__c;
        i.Whendoyouplantodoyourcoursework__c = l.When_do_you_plan_to_do_your_course_work__c;
        i.Where_are_you_employed__c = l.Where_are_you_employed__c;
        
        return i;
    }
       
}