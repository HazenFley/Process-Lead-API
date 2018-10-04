public class leadMarketingInfo {
    public void addVendorInfo(Lead[] newLead){
        System.debug('>>>>>Attaching marketing information to Lead');
        Set<string> CIDSet = new Set<string>();
        Set<string> leadSourceSet = new Set<string>();
        Set<id> totalVendorSet = new Set<id>();
        
        //populate the sets and maps
        for(Lead i: newLead){
            if(i.Vendor_Source_Lookup__c == null){CIDSet.add(i.CID__c);}
            if(i.Vendor_Source_Lookup__c == null && (i.CID__c==null || i.CID__c=='')){leadSourceSet.add(i.LeadSource);}
        }
        
        if(CIDSet.size()>0){
            System.debug('Lookup on CID');
            List<Vendor_Source__c> vendorCIDList = [SELECT id, CID__c, Channel__c FROM Vendor_Source__c WHERE CID__c IN :CIDSet];
            Map<id, Vendor_Source__c> vendorCIDMap = new Map<id,Vendor_Source__c>([SELECT id, CID__c, Channel__c FROM Vendor_Source__c WHERE CID__c IN :CIDSet]);
            Map<string, id> CIDMap = new Map<string, id>();
            for(Vendor_Source__c v: vendorCIDList){
                CIDMap.put(v.CID__c, v.id);
                totalVendorSet.add(v.id);
            }
            System.debug('CIDMap = ' + CIDMap);
            System.debug('vendorCIDMap = ' + vendorCIDMap);
            
            //update the Lead record based on map
            for(Lead i: newLead){
                if(CIDMap.containsKey(i.CID__c) && CIDMap.get(i.CID__c)!=null){
                    i.Vendor_Source_Lookup__c = CIDMap.get(i.CID__c);                    
                }
                if(vendorCIDMap.containsKey(i.Vendor_Source_Lookup__c) && vendorCIDMap.get(i.Vendor_Source_Lookup__c)!=null){
                    i.Lead_Source_Channel__c = vendorCIDMap.get(i.Vendor_Source_Lookup__c).Channel__c;
                    System.debug('Lead_Source_Channel__c = ' + i.Lead_Source_Channel__c);
                }
            }
            System.debug('>>>>>>>>>>>>>>>>>>>After addVendorInfo, newLead = ' + newLead);
        }
        
        if(leadSourceSet.size()>0){
            System.debug('Lookup on LeadSource');
            List<Vendor_Source__c> vendorLeadSourceList = [SELECT id, Source__c, Channel__c FROM Vendor_Source__c WHERE Source__c IN :leadSourceSet];
            Map<id, Vendor_Source__c> vendorLeadSourceMap = new Map<id,Vendor_Source__c>([SELECT id, CID__c, Channel__c FROM Vendor_Source__c WHERE Source__c IN :leadSourceSet]);
            Map<string, id> leadSourceMap = new Map<string, id>();
            for(Vendor_Source__c v: vendorLeadSourceList){
                leadSourceMap.put(v.Source__c,v.Id);
                totalVendorSet.add(v.Id);
            }
            System.debug('leadSourceMap = ' + leadSourceMap);
            System.debug('vendorLeadSourceMap = ' + vendorLeadSourceMap);
            
            //update the Lead record based on map
            for(Lead i: newLead){
                if(leadSourceMap.containsKey(i.LeadSource) && leadSourceMap.get(i.LeadSource)!=null){
                    i.Vendor_Source_Lookup__c = leadSourceMap.get(i.LeadSource);
                    System.debug('Vendor Source = ' + i.Vendor_Source_Lookup__c);
                }
                if(vendorLeadSourceMap.containsKey(i.Vendor_Source_Lookup__c) && vendorLeadSourceMap.get(i.Vendor_Source_Lookup__c)!=null){
                    i.Lead_Source_Channel__c = vendorLeadSourceMap.get(i.Vendor_Source_Lookup__c).Channel__c;
                    System.debug('Lead_Source_Channel__c = ' + i.Lead_Source_Channel__c);
                }
            }
            
            System.debug('>>>>>>>>>>>>>>>>>>>After addVendorInfo, newLead = ' + newLead);
        }
        
        
        //Add source and additional vendor information
        Map<id,Vendor_Source__c> totalVendorMap = new Map<id,Vendor_Source__c>([SELECT id, Name, ADMR_Code__c, Brand_Non_Brand_Hardcode__c, Channel__c, CID__c,Inbound_Phone_Number__c,MLVT_Code__c,Rep_Selectable__c,Source__c
                                                                                 FROM Vendor_Source__c WHERE id IN :totalVendorSet]);
        
        for(Lead i: newLead){
            if(totalVendorMap.containsKey(i.Vendor_Source_Lookup__c) && totalVendorMap.get(i.Vendor_Source_Lookup__c) != null){
                i.LeadSource = totalVendorMap.get(i.Vendor_Source_Lookup__c).Source__c;
                
            }
        }
    }
}