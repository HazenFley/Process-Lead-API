@isTest
private class Test_IntegrationLogHelper 
{
    static testMethod void CreateIntegrationLogsDmlException_Success()
    {
        Test.startTest();     
        
        try
        {
            insert new Lead();
        }
        catch(Exception ex)
        {
            System.debug(ex.getTypeName());
            System.debug(ex.getNumDml());
            System.debug(ex.getDmlFieldNames(0));
            System.debug(ex.getDmlMessage(0));
            System.debug(ex.getStackTraceString());
            System.debug(ex.getDmlType(0).name());
            IntegrationLogHelper.CreateIntegrationLogs(ex);
        }
        
        Map<String, String> intDataMap = new Map<String, String>();
        for(IntegrationLog__c intLog : [SELECT Id, Data__c
                                        FROM IntegrationLog__c
                                        WHERE Source__c = 'Not Provided'])
        {
            intDataMap.put(intLog.Data__c, intLog.Id);
        }
        
        System.assert(intDataMap.containsKey('{"Id":"GU0100011101010101"}'));
        Test.stopTest();        
    }
    
    static testMethod void CreateIntegrationLogsException_Success()
    {
        Test.startTest();            
        NullPointerException ex = new NullPointerException();
        IntegrationLogHelper.CreateIntegrationLogs(ex);    
        Map<String, String> intDataMap = new Map<String, String>();
        for(IntegrationLog__c intLog : [SELECT Id, Data__c
                                        FROM IntegrationLog__c
                                        WHERE Source__c = 'Not Provided'])
        {
            intDataMap.put(intLog.Data__c, intLog.Id);
        }
        
        System.assert(intDataMap.containsKey('{"Id":"GU0100011101010101"}'));
        Test.stopTest();        
    }
    static testMethod void ParseDmlException_Success()
    {
        
        Test.startTest();
        List<IntegrationLog__c> intLogList;    
        try
        {
            insert new Lead();
        }
        catch(Exception ex)
        {
            intLogList = IntegrationLogHelper.ParseDmlException(ex);
        } 
        
        System.assert(intLogList.size() > 0);
        Test.stopTest();        
    }
    
    static testMethod void ParseDmlException_Failure()
    {
        string json = '{"Actual_Start_Date__c":"ABCDEFGHIJKLMNOPQRSTUVWXYZ"}';
        
        Test.startTest();
        List<IntegrationLog__c> intLogList;    
        try
        {
            Lead lead = (Lead) System.JSON.deserialize(json, Lead.class);
        }
        catch(Exception ex)
        {
            intLogList = IntegrationLogHelper.ParseDmlException(ex);
        } 
        
        System.assert(intLogList.size() == 0);
        Test.stopTest();        
    }
    
    static testMethod void ParseJSONForID_Success()
    {
        string json = '{"Id":"ABCDEFGHIJKLMNOPQRSTUVWXYZ","NotAnId":"ZYXWVUTSRQPONMLKJIHGFEDCBA"}';
        
        Test.startTest();        
        string id = IntegrationLogHelper.ParseJSONForID(json);
        System.debug(id);
        System.assert(id == 'ABCDEFGHIJKLMNOPQRSTUVWXYZ');
        Test.stopTest();        
    }
    
    static testMethod void ParseJSONForID_ReturnNullForNoID()
    {
        string json = '{"NotAnId":"ABCDEFGHIJKLMNOPQRSTUVWXYZ","AlsoNotAnId":"ZYXWVUTSRQPONMLKJIHGFEDCBA"}';
        
        Test.startTest();        
        string id = IntegrationLogHelper.ParseJSONForID(json);
        System.assert(id == null);
        Test.stopTest();        
    }
}