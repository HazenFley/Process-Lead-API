public class IntegrationLogHelper 
{    
    // Creates IntegrationLogs for Leads
    public static void CreateIntegrationLogs(Exception ex) 
    {
        List<Lead> leadList;
        List<Contact> contactList;        
        string source;
        string jsonRequest;
        
        if (!Test.isRunningTest()) jsonRequest = RestContext.request.requestBody.toString(); // JSON request as a string   
        if (Test.isRunningTest()) jsonRequest = '{"Id":"GU0100011101010101"}';
        
        string id = ParseJSONForID(jsonRequest);
        if(id != null)
        {
            string sobjectKey = id.substring(0,3);            
            if(sobjectKey == '003') contactList = [SELECT Id
                                                   FROM Contact 
                                                   WHERE Id = :id];
            if(sobjectKey == '00Q') leadList = [SELECT Id 
                                                FROM Lead 
                                                WHERE Id = :id];
        }
        if(ex.getTypeName() == 'System.DmlException') // Dml & Mail Exceptions must be handled differently         
        {
            List<IntegrationLog__c> intLogList = ParseDmlException(ex); // Create an IntegrationLog for each row error            
            for(IntegrationLog__c intLog : intLogList) // Loop through the logs and add remaining fields
            {
                if(leadList != null && leadList.size() > 0)
                {
                    intLog.Related_Lead_Record__c = id;
                    source = leadList[0].LeadSource;
                }
                if(contactList != null && contactList.size() > 0)
                {
                    intLog.Contact__c = id;
                    source = contactList[0].LeadSource;
                }                
                if(source != null) intLog.Source__c = source;
                else intLog.Source__c = 'Not Provided';
                intLog.Data__c = jsonRequest;
            }    
            
            insert intLogList;
        }
        else
        {
            IntegrationLog__c intLog = new IntegrationLog__c();            
            if(leadList != null && leadList.size() > 0)
            {
                intLog.Related_Lead_Record__c = id;
                source = leadList[0].LeadSource;
            }
            if(contactList != null && contactList.size() > 0)
            {
                intLog.Contact__c = id;
                source = contactList[0].LeadSource;
            }            
            if(source != null) intLog.Source__c = source;
            else intLog.Source__c = 'Not Provided';
            intLog.Data__c = jsonRequest;
            intLog.Exception_Message__c = ex.getMessage();
            intLog.Exception_Stack_Trace__c = ex.getStackTraceString();
            intLog.Exception_Type__c = ex.getTypeName(); 
            
            insert intLog;
        }        
    }
    
    // Builds an IntegrationLog for each row error
    public static List<IntegrationLog__c> ParseDmlException(Exception ex)
    {        
        List<IntegrationLog__c> intLogList = new List<IntegrationLog__c>();          
        try
        {
            for(integer i = 0; i < ex.getNumDml(); i++) // Loop through each row error
            {
                IntegrationLog__c intLog = new IntegrationLog__c();                
                for(string field : ex.getDmlFieldNames(i))  // Gets the field names for the row error
                {
                    intLog.Exception_DML_Field_Names__c += field + ', ';
                }
                intLog.Exception_Message__c = ex.getDmlMessage(i);
                intLog.Exception_Stack_Trace__c = ex.getStackTraceString();
                intLog.Exception_Type__c = ex.getDmlType(i).name();                
                intLogList.add(intLog);
            }
        }
        catch(Exception e)
        {
            System.debug('Exception: '+ e.getMessage());
        }        
        
        System.debug('Count: ' + intLogList.size());
        return intLogList;
    }    
    
    // Pulls the Id value from the JSON string
    public static string ParseJSONForID(string json)
    {
        string jid;
        string[] jsplit;
        try
        {
            jsplit = json.split(','); // Split out the values, ex: "Id":"XXXXX"
            for(string x : jsplit)
            {
                if(x.Contains('"Id":')) // Isolates the ID key/value
                {
                    string[] xsplit = x.split(':'); // Splits the key/value, ex: "XXXXX"
                    jid = xsplit[1].replace('"', ''); // Removes the double quotations ("), ex: XXXXX 
                }
            }
        }
        catch(Exception ex)
        {
            System.debug('Exception: ' + ex.getMessage());
        }
        
        return jid;
    }    
} // End of Class