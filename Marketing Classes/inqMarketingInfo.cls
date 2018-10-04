public class inqMarketingInfo {
    public void addVendorInfo(Inquiry__c[] newInquiry){
        Set<string> CIDSet = new Set<string>();
        Set<string> leadSourceSet = new Set<string>();
        Set<id> totalVendorSet = new Set<id>();
        
        //populate the sets and maps
        for(Inquiry__c i: newInquiry){
            if(i.Vendor_Source__c == null){CIDSet.add(i.CID__c);}
            if(i.Vendor_Source__c == null && (i.CID__c==null || i.CID__c=='')){leadSourceSet.add(i.LeadSource__c);}
        }
        
        if(CIDSet.size()>0){
            List<Vendor_Source__c> vendorCIDList = [SELECT id, CID__c FROM Vendor_Source__c WHERE CID__c IN :CIDSet];
            Map<string, id> CIDMap = new Map<string, id>();
            for(Vendor_Source__c v: vendorCIDList){
                CIDMap.put(v.CID__c, v.id);
                totalVendorSet.add(v.id);
            }
            System.debug('CIDMap = ' + CIDMap);
            
            //update the Inquiry record based on map
            for(Inquiry__c i: newInquiry){
                if(CIDMap.containsKey(i.CID__c) && CIDMap.get(i.CID__c)!=null){
                    i.Vendor_Source__c = CIDMap.get(i.CID__c);
                }
            }
        }
        
        if(leadSourceSet.size()>0){
            List<Vendor_Source__c> vendorLeadSourceList = [SELECT id, Source__c FROM Vendor_Source__c WHERE Source__c IN :leadSourceSet];
            Map<string, id> leadSourceMap = new Map<string, id>();
            for(Vendor_Source__c v: vendorLeadSourceList){
                leadSourceMap.put(v.Source__c,v.Id);
                totalVendorSet.add(v.id);
            }
            System.debug('leadSourceMap = ' + leadSourceMap);
            
            //update the Inquiry record based on map
            for(Inquiry__c i: newInquiry){
                if(leadSourceMap.containsKey(i.LeadSource__c) && leadSourceMap.get(i.LeadSource__c)!=null){
                    i.Vendor_Source__c = leadSourceMap.get(i.LeadSource__c);
                }
            }
        }
        
        //add vendor source information to the inquiry
        Map<id,Vendor_Source__c> totalVendorMap = new Map<id, Vendor_Source__c>([SELECT id, Name, ADMR_Code__c, Brand_Non_Brand_Hardcode__c, Channel__c, CID__c,Inbound_Phone_Number__c,MLVT_Code__c,Rep_Selectable__c,Source__c
                                                                                 FROM Vendor_Source__c WHERE id IN :totalVendorSet]);
        for(Inquiry__c i: newInquiry){
            if(totalVendorMap.containsKey(i.Vendor_Source__c) && totalVendorMap.get(i.Vendor_Source__c) != null){
                i.LeadSource__c = totalVendorMap.get(i.Vendor_Source__c).Source__c;
                
            }
        }
        
    }
}