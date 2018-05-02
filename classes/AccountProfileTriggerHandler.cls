public class AccountProfileTriggerHandler{
    
    public static void overallCalculation( List<Account_Profile__c> apList ,Map<Id, Account_Profile__c> oldMap ){
        Map<Id, Account_Profile_Settings__c> accSettingMap = getAccountSetting(apList);
        for( Account_Profile__c ap : apList ){
            if( ap.Multi_Channel__c && ap.Primary_Business__c != null ){
                multiChannelLevelCalculation( ap );
                //BIDataCalculation( ap );
            }else{
                singleChannelLevelCalculation( ap );
                BIDataCalculation( ap );
            }
            productLevelCalculation( ap,accSettingMap.get( ap.Primary_Business__c ) );
            brandLevelCalculation( ap,accSettingMap.get( ap.Primary_Business__c ) );
            calculateOpportunityValue( ap,accSettingMap.get( ap.Primary_Business__c ) );
            mohawkLevelCalculation( ap );
            DistributionPercentage( ap,accSettingMap.get( ap.Primary_Business__c ) );
            
            //RESET BI CALCULATION
            if( ap.Multi_Channel__c && ap.Multi_Channel__c != oldMap.get( ap.id ).Multi_Channel__c ){
                resetBICalculation( ap );
            }
        }
    }
    
    /************************************************************************************
    Method Name :   annualGrossSales
    Return Type :   decimal
    Parameter   :   Account_Profile__c ap
    Created By  :   Mudit Saxena
    Created On  :   12/2/2018
    Description :   Subtracting non Flooring Sales % from Annual Gross Sales
    Modified    :    
    ************************************************************************************/
    public static decimal annualGrossSales( Account_Profile__c ap ){
        decimal returnVar;
        if( ap.Annual_Retail_Sales__c != null && ap.Annual_Retail_Sales_Non_Flooring__c != null ){
            returnVar = ap.Annual_Retail_Sales__c - ( ap.Annual_Retail_Sales__c * ap.Annual_Retail_Sales_Non_Flooring__c) / 100;
        }
        return returnVar;       
    }
    
    /************************************************************************************
    Method Name :   singleBusiness_split
    Return Type :   Map<string,decimal>
    Parameter   :   Account_Profile__c ap
    Created By  :   Mudit Saxena
    Created On  :   12/2/2018
    Description :   finding single business split either retail or multi family
    Modified    :    
    ************************************************************************************/
        public static Map<string,decimal>singleBusiness_split( Account_Profile__c ap ){
        Map<string,decimal>returnMap = new Map<string,decimal>();
        if( ap.Retail_Channel_Split__c != null && ap.Retail_Channel_Split__c == 100 ){
            if(ap.Retail_Channel_Split__c!=null)
            returnMap.put( 'Retail',ap.Retail_Channel_Split__c /100 );
            returnMap.put( 'Builder',0 );
        }else{
            returnMap.put( 'Retail',0 );
            if(ap.Builder_Multi_Channel_split__c!=null)
            returnMap.put( 'Builder',ap.Builder_Multi_Channel_split__c / 100 );
        }
        return returnMap;
    }
    
    /************************************************************************************
    Method Name :   multiBusiness_split
    Return Type :   Map<string,decimal>
    Parameter   :   Account_Profile__c ap
    Created By  :   Mudit Saxena
    Created On  :   12/2/2018
    Description :   getting multi business split retail and multi family
    Modified    :    
    ************************************************************************************/
    public static Map<string,decimal>multiBusiness_split( Account_Profile__c ap ){
        Map<string,decimal>returnMap = new Map<string,decimal>();
        if(ap!=null ){ //Added null check by Susmitha while writing test class
        if( ap.Retail_Channel_Split__c != null && ap.Builder_Multi_Channel_split__c != null ){
            returnMap.put( 'Retail',ap.Retail_Channel_Split__c/100 );
            returnMap.put( 'Builder',ap.Builder_Multi_Channel_split__c/100 );
        }
        return returnMap;
    }
    
    /************************************************************************************
    Method Name :   singleChannelLevelCalculation
    Return Type :   void
    Parameter   :   Account_Profile__c ap,Account_Profile_Settings__c apSetting
    Created By  :   Mudit Saxena
    Created On  :   12/2/2018
    Description :   Calculating Single Channel Level TOTAL MOHAWK OVERVIEW.
                    "Estimated Retail Sales Total" for Retail and BUILDER/MULTI-FAMILY.
    Modified    :    
    ************************************************************************************/
    public static void singleChannelLevelCalculation( Account_Profile__c ap ){
        if(ap!=null){ //Added null check by Susmitha while writing test class

            if(singleBusiness_split( ap )!=null && annualGrossSales( ap )!=null ){
        decimal annualGrossSales = annualGrossSales( ap );
        Map<string,decimal> business_split = singleBusiness_split( ap );
        /**********TOTAL MOHAWK OVERVIEW - RETAIL**********/
        //Estimated Retail Sales Total
        ap.R_ERS_Total__c = (annualGrossSales != null ? annualGrossSales : 0) * (business_split.get( 'Retail' ) != null ? business_split.get( 'Retail' ) : 0);
        /**********TOTAL MOHAWK OVERVIEW - RETAIL**********/
        
        /**********TOTAL MOHAWK OVERVIEW - BUILDER/MULTI-FAMILY**********/
        //Estimated Retail Sales Total
        ap.B_ERS_Total__c = (annualGrossSales != null ? annualGrossSales : 0) * (business_split.get( 'Builder' ) != null ? business_split.get( 'Builder' ) : 0);
        /**********TOTAL MOHAWK OVERVIEW - BUILDER/MULTI-FAMILY**********/
    }
    }
    }
    /************************************************************************************
    Method Name :   multiChannelLevelCalculation
    Return Type :   void
    Parameter   :   Account_Profile__c ap,Account_Profile_Settings__c apSetting
    Created By  :   Mudit Saxena
    Created On  :   12/2/2018
    Description :   Calculating Multi Channel Level TOTAL MOHAWK OVERVIEW.
                    "Estimated Retail Sales Total" for Retail and BUILDER/MULTI-FAMILY.
    Modified    :    
    ************************************************************************************/
    public static void multiChannelLevelCalculation( Account_Profile__c ap ){
        if(ap!=null){ //Added null check by Susmitha while writing test class

         if(multiBusiness_split( ap )!=null && annualGrossSales( ap )!=null ){

        decimal annualGrossSales = annualGrossSales( ap );
        Map<string,decimal> business_split = multiBusiness_split( ap );        
        /**********TOTAL MOHAWK OVERVIEW - RETAIL**********/
        //Estimated Retail Sales Total
        ap.R_ERS_Total__c = (annualGrossSales != null ? annualGrossSales : 0) * (business_split.get( 'Retail' ) != null ? business_split.get( 'Retail' ) : 0);
        /**********TOTAL MOHAWK OVERVIEW - RETAIL**********/
        
        /**********TOTAL MOHAWK OVERVIEW - BUILDER/MULTI-FAMILY**********/
        //Estimated Retail Sales Total
        ap.B_ERS_Total__c = (annualGrossSales != null ? annualGrossSales : 0) * (business_split.get( 'Builder' ) != null ? business_split.get( 'Builder' ) : 0);
        /**********TOTAL MOHAWK OVERVIEW - BUILDER/MULTI-FAMILY**********/
    }
    }
    }
    /************************************************************************************
    Method Name :   productLevelCalculation
    Return Type :   void
    Parameter   :   Account_Profile__c ap,Account_Profile_Settings__c apSetting
    Created By  :   Mudit Saxena
    Created On  :   12/2/2018
    Description :   Calculating Product Level.
                    TOTAL CARPET OVERVIEW - RETAIL & TOTAL CARPET OVERVIEW - BUILDER/MULTI-FAMILY.
                    "Estimated Retail Sales-(Carpet,Cushion,Laminate,Tile,Resilient,Hardwood)".
                    "Estimated Wholesale Purchases-(Carpet,Cushion,Laminate,Tile,Resilient,Hardwood)".
    Modified    :    
    ************************************************************************************/
    public static void productLevelCalculation( Account_Profile__c ap,Account_Profile_Settings__c apSetting ){
        
        /**********PRODUCT CATEGORY OVERVIEW- CARPET OVERVIEW - RETAIL**********/
        //Estimated Retail Sales-Carpet 
        ap.R_ERS_Car__c = (ap.R_ERS_Total__c != null ? ap.R_ERS_Total__c : 0) * ( (ap.Product_Category_Allocation_Carpet__c != null ? ap.Product_Category_Allocation_Carpet__c : 0) / 100 );
        //Estimated Wholesale Purchases-Carpet
        ap.R_EWP_Car__c = (ap.R_ERS_Car__c != null ? ap.R_ERS_Car__c : 0) * ( (apSetting.Retail_Sales_Carpet__c != null ? apSetting.Retail_Sales_Carpet__c : 0) / 100 );    
        /**********PRODUCT CATEGORY OVERVIEW- CARPET OVERVIEW - RETAIL**********/
        
        /**********PRODUCT CATEGORY OVERVIEW- CUSHION OVERVIEW - RETAIL**********/
        //Estimated Retail Sales - Cushion
        ap.R_ERS_Cus__c = (ap.R_ERS_Total__c != null ? ap.R_ERS_Total__c : 0) * ( (ap.Product_Category_Allocation_Cushion__c != null ? ap.Product_Category_Allocation_Cushion__c : 0) / 100 );
        //Estimated Wholesale Purchases-Cushion
        ap.R_EWP_Cus__c = (ap.R_ERS_Cus__c != null ? ap.R_ERS_Cus__c : 0) * ( (apSetting.Retail_Sales_Cushion__c != null ? apSetting.Retail_Sales_Cushion__c : 0) / 100 );
        /**********PRODUCT CATEGORY OVERVIEW- CUSHION OVERVIEW - RETAIL**********/
        
        /**********PRODUCT CATEGORY OVERVIEW- LAMINATE OVERVIEW - RETAIL**********/
        //Estimated Retail Sales - Laminate
        ap.R_ERS_Lam__c = (ap.R_ERS_Total__c != null ? ap.R_ERS_Total__c : 0) * ( (ap.Product_Category_Allocation_Laminate__c != null ? ap.Product_Category_Allocation_Laminate__c : 0) / 100 );
        //Estimated Wholesale Purchases-Laminate
        ap.R_EWP_Lam__c = (ap.R_ERS_Lam__c != null ? ap.R_ERS_Lam__c : 0) * ( (apSetting.Retail_Sales_Laminate__c != null ? apSetting.Retail_Sales_Laminate__c : 0) / 100 );
        /**********PRODUCT CATEGORY OVERVIEW- LAMINATE OVERVIEW - RETAIL**********/
        
        /**********PRODUCT CATEGORY OVERVIEW- TILE OVERVIEW - RETAIL**********/
        //Estimated Retail Sales-Tile
        ap.R_ERS_T__c = (ap.R_ERS_Total__c != null ? ap.R_ERS_Total__c : 0) * ( (ap.Product_Category_Allocation_Tile__c != null ? ap.Product_Category_Allocation_Tile__c : 0) / 100 );
        //Estimated Wholesale Purchases-Tile
        ap.R_EWP_T__c = (ap.R_ERS_T__c != null ? ap.R_ERS_T__c : 0) * ( (apSetting.Retail_Sales_Tile__c != null ? apSetting.Retail_Sales_Tile__c : 0) / 100 );
        /**********PRODUCT CATEGORY OVERVIEW- TILE OVERVIEW - RETAIL**********/
        
        /**********PRODUCT CATEGORY OVERVIEW- RESILIENT OVERVIEW - RETAIL**********/
        //Estimated Retail Sales-Resilient
        ap.R_ERS_R__c = (ap.R_ERS_Total__c != null ? ap.R_ERS_Total__c : 0) * ( (ap.Product_Category_Allocation_Resilient__c != null ? ap.Product_Category_Allocation_Resilient__c : 0) / 100 );
        //Estimated Wholesale Purchases-Resilient
        ap.R_EWP_R__c = (ap.R_ERS_R__c != null ? ap.R_ERS_R__c : 0) * ( (apSetting.Retail_Sales_Resilient__c != null ? apSetting.Retail_Sales_Resilient__c : 0) / 100 );
        /**********PRODUCT CATEGORY OVERVIEW- RESILIENT OVERVIEW - RETAIL**********/
        
        /**********PRODUCT CATEGORY OVERVIEW- WOOD OVERVIEW - RETAIL**********/
        //Estimated Retail Sales - Hardwood
        ap.R_ERS_Har__c = (ap.R_ERS_Total__c != null ? ap.R_ERS_Total__c : 0) * ( (ap.Product_Category_Allocation_Wood__c != null ? ap.Product_Category_Allocation_Wood__c : 0) / 100 );
        //Estimated Wholesale Purchases-Hardwood
        ap.R_EWP_Har__c = (ap.R_ERS_Har__c != null ? ap.R_ERS_Har__c : 0) * ( (apSetting.Retail_Sales_Hardwood__c != null ? apSetting.Retail_Sales_Hardwood__c : 0) / 100 );
        /**********PRODUCT CATEGORY OVERVIEW- WOOD OVERVIEW - RETAIL**********/
        
        /**********PRODUCT CATEGORY OVERVIEW- ALADDIN COMMERCIAL OVERVIEW - Retail**********/
        //Estimated Aladdin Comm Retail Sales
        ap.R_ERS_AC_Total__c = (ap.R_ERS_RC__c != null ? ap.R_ERS_RC__c : 0) + (ap.R_ERS_AC__c != null ? ap.R_ERS_AC__c : 0);
        //Est. WHSLE Purch. - Aladdin Comm Total
        //ap.R_EWP_ACT__c
        /**********PRODUCT CATEGORY OVERVIEW- ALADDIN COMMERCIAL OVERVIEW - Retail**********/
        
        /**********PRODUCT CATEGORY OVERVIEW- CARPET OVERVIEW - BUILDER/MULTI-FAMILY**********/
        //Estimated Retail Sales-Carpet 
        ap.B_ERS_Car__c = (ap.B_ERS_Total__c != null ? ap.B_ERS_Total__c : 0) * ( (ap.Product_Category_Allocation_Carpet__c != null ? ap.Product_Category_Allocation_Carpet__c : 0) / 100 );
        //Estimated Wholesale Purchases-Carpet
        ap.B_EWP_Car__c = (ap.B_ERS_Car__c != null ? ap.B_ERS_Car__c : 0) * ( (apSetting.Retail_Sales_Carpet__c != null ? apSetting.Retail_Sales_Carpet__c : 0) / 100 );    
        /**********PRODUCT CATEGORY OVERVIEW- CARPET OVERVIEW - BUILDER/MULTI-FAMILY**********/

        /**********PRODUCT CATEGORY OVERVIEW- CUSHION OVERVIEW - BUILDER/MULTI-FAMILY**********/
        //Estimated Retail Sales - Cushion
        ap.B_ERS_Cus__c = (ap.B_ERS_Total__c != null ? ap.B_ERS_Total__c : 0) * ( (ap.Product_Category_Allocation_Cushion__c != null ? ap.Product_Category_Allocation_Cushion__c : 0) / 100 );
        //Estimated Wholesale Purchases-Cushion
        ap.B_EWP_Cus__c = (ap.B_ERS_Cus__c != null ? ap.B_ERS_Cus__c : 0) * ( (apSetting.Retail_Sales_Cushion__c != null ? apSetting.Retail_Sales_Cushion__c : 0) / 100 );
        /**********PRODUCT CATEGORY OVERVIEW- CUSHION OVERVIEW - BUILDER/MULTI-FAMILY**********/

        /**********PRODUCT CATEGORY OVERVIEW- LAMINATE OVERVIEW - BUILDER/MULTI-FAMILY**********/
        //Estimated Retail Sales - Laminate
        ap.B_ERS_Lam__c = (ap.B_ERS_Total__c != null ? ap.B_ERS_Total__c : 0) * ( (ap.Product_Category_Allocation_Laminate__c != null ? ap.Product_Category_Allocation_Laminate__c : 0) / 100 );
        //Estimated Wholesale Purchases-Laminate
        ap.B_EWP_Lam__c = (ap.B_ERS_Lam__c != null ? ap.B_ERS_Lam__c : 0) * ( (apSetting.Retail_Sales_Laminate__c != null ? apSetting.Retail_Sales_Laminate__c : 0) / 100 );
        /**********PRODUCT CATEGORY OVERVIEW- LAMINATE OVERVIEW - BUILDER/MULTI-FAMILY**********/

        /**********PRODUCT CATEGORY OVERVIEW- TILE OVERVIEW - BUILDER/MULTI-FAMILY**********/
        //Estimated Retail Sales-Tile
        ap.B_ERS_T__c = (ap.B_ERS_Total__c != null ? ap.B_ERS_Total__c : 0) * ( (ap.Product_Category_Allocation_Tile__c != null ? ap.Product_Category_Allocation_Tile__c : 0) / 100 );
        //Estimated Wholesale Purchases-Tile
        ap.B_EWP_T__c = (ap.B_ERS_T__c != null ? ap.B_ERS_T__c : 0) * ( (apSetting.Retail_Sales_Tile__c != null ? apSetting.Retail_Sales_Tile__c : 0) / 100 );
        /**********PRODUCT CATEGORY OVERVIEW- TILE OVERVIEW - BUILDER/MULTI-FAMILY**********/

        /**********PRODUCT CATEGORY OVERVIEW- RESILIENT OVERVIEW - BUILDER/MULTI-FAMILY**********/
        //Estimated Retail Sales-Resilient
        ap.B_ERS_R__c = (ap.B_ERS_Total__c != null ? ap.B_ERS_Total__c : 0) * ( (ap.Product_Category_Allocation_Resilient__c != null ? ap.Product_Category_Allocation_Resilient__c : 0) / 100 );
        //Estimated Wholesale Purchases-Resilient
        ap.B_EWP_R__c = (ap.B_ERS_R__c != null ? ap.B_ERS_R__c : 0) * ( (apSetting.Retail_Sales_Resilient__c != null ? apSetting.Retail_Sales_Resilient__c : 0) / 100 );
        /**********PRODUCT CATEGORY OVERVIEW- RESILIENT OVERVIEW - BUILDER/MULTI-FAMILY**********/

        /**********PRODUCT CATEGORY OVERVIEW- WOOD OVERVIEW - BUILDER/MULTI-FAMILY**********/
        //Estimated Retail Sales - Hardwood
        ap.B_ERS_Har__c = (ap.B_ERS_Total__c != null ? ap.B_ERS_Total__c : 0) * ( (ap.Product_Category_Allocation_Wood__c != null ? ap.Product_Category_Allocation_Wood__c : 0) / 100 );
        //Estimated Wholesale Purchases-Hardwood
        ap.B_EWP_Har__c = (ap.B_ERS_Har__c != null ? ap.B_ERS_Har__c : 0) * ( (apSetting.Retail_Sales_Hardwood__c != null ? apSetting.Retail_Sales_Hardwood__c : 0) / 100 );
        /**********PRODUCT CATEGORY OVERVIEW- WOOD OVERVIEW - BUILDER/MULTI-FAMILY**********/
        
        /**********PRODUCT CATEGORY OVERVIEW- ALADDIN COMMERCIAL OVERVIEW  - BUILDER/MULTI-FAMILY**********/
        //Estimated Aladdin Comm Retail Sales
        ap.B_ERS_AC_Total__c = (ap.B_ERS_RC__c != null ? ap.B_ERS_RC__c : 0) + (ap.B_ERS_AC__c != null ? ap.B_ERS_AC__c : 0);
        //Est Wholesale Purch-Aladdin Comm Total
        //B_EWP_ACT__c = 
        /**********PRODUCT CATEGORY OVERVIEW- ALADDIN COMMERCIAL OVERVIEW  - BUILDER/MULTI-FAMILY**********/
    }
    
    /************************************************************************************
    Method Name :   brandLevelCalculation
    Return Type :   void
    Parameter   :   Account_Profile__c ap,Account_Profile_Settings__c apSetting
    Created By  :   Mudit Saxena
    Created On  :   12/2/2018
    Description :   Calculating Brand Level.
                    CARPET BREAKDOWN - RETAIL & CARPET BREAKDOWN - BUILDER/MULTI-FAMILY             
                    "Estimated Retail Sales-(ALADDIN,HORIZON,KARASTAN,ALADDIN COMMERCIAL,RESILIENT RETAIL,RESILIENT ALADDIN COMMERCIAL)".
                    "Estimated Wholesale Purchases-(ALADDIN,HORIZON,KARASTAN,ALADDIN COMMERCIAL,RESILIENT RETAIL,RESILIENT ALADDIN COMMERCIAL)".
    Modified    :    
    ************************************************************************************/
    public static void brandLevelCalculation( Account_Profile__c ap,Account_Profile_Settings__c apSetting ){
        /**********PRODUCT CATEGORY BREAKDOWN - ALADDIN - RETAIL**********/
        //Estimated retail sales - Aladdin  
        ap.R_ERS_A__c = (ap.R_ERS_Car__c != null ? ap.R_ERS_Car__c : 0) * ( ap.No_Karastan__c ? (apSetting.No_Karastan_Aladdin_Carpet__c != null ? apSetting.No_Karastan_Aladdin_Carpet__c : 0) : (apSetting.Estimated_Purchase_Aladdin_Carpet__c != null ? apSetting.Estimated_Purchase_Aladdin_Carpet__c : 0) )/100;
        //Estimated Wholesale Purchases-Aladdin
        //ap.R_EWP_A__c = ap.R_EWP_Car__c * ( ap.No_Karastan__c ? apSetting.No_Karastan_Aladdin_Carpet__c : apSetting.Estimated_Purchase_Aladdin_Carpet__c );
        /**********PRODUCT CATEGORY BREAKDOWN - ALADDIN - RETAIL**********/
        
        /**********PRODUCT CATEGORY BREAKDOWN - HORIZON - RETAIL**********/
        //Estimated retail sales - HORIZON
        ap.R_ERS_Hor__c = (ap.R_ERS_Car__c != null ? ap.R_ERS_Car__c : 0) * ( ap.No_Karastan__c ? (apSetting.No_Karastan_Horizon_Carpet__c != null ? apSetting.No_Karastan_Horizon_Carpet__c : 0) : (apSetting.Estimated_Purchase_Horizon_Carpet__c != null ? apSetting.Estimated_Purchase_Horizon_Carpet__c : 0) )/100;
        //Estimated Wholesale Purchases-Horizon
        //ap.R_EWP_Hor__c = ap.R_EWP_Car__c * ( ap.No_Karastan__c ? apSetting.No_Karastan_Horizon_Carpet__c : apSetting.Estimated_Purchase_Horizon_Carpet__c );
        /**********PRODUCT CATEGORY BREAKDOWN - HORIZON - RETAIL**********/
        
        /**********PRODUCT CATEGORY BREAKDOWN - KARASTAN - RETAIL**********/
        //Estimated retail sales - KARASTAN
        ap.R_ERS_Kar__c = (ap.R_ERS_Car__c != null ? ap.R_ERS_Car__c : 0) * ( ap.No_Karastan__c ? (apSetting.No_Karastan_Karastan_Carpet__c != null ? apSetting.No_Karastan_Karastan_Carpet__c : 0) : (apSetting.Estimated_Purchase_Karastan_Carpet__c != null ? apSetting.Estimated_Purchase_Karastan_Carpet__c : 0) )/100;
        //Estimated Wholesale Purchases-Karastan
        //ap.R_EWP_Kar__c = ap.R_EWP_Car__c * ( ap.No_Karastan__c ? apSetting.No_Karastan_Karastan_Carpet__c : apSetting.Estimated_Purchase_Karastan_Carpet__c );
        /**********PRODUCT CATEGORY BREAKDOWN - KARASTAN - RETAIL**********/
        
        /**********PRODUCT CATEGORY BREAKDOWN - ALADDIN COMMERCIAL CARPET - RETAIL**********/
        //Estimated Retail Sales-Aladdin Comm
        ap.R_ERS_AC__c = (ap.R_ERS_Car__c != null ? ap.R_ERS_Car__c : 0) * (apSetting.Estimated_Purchase_Aladdin_Com_Car__c != null ? apSetting.Estimated_Purchase_Aladdin_Com_Car__c : 0)/100;
        //Est.WholesalePurchases Aladdin Comm
        //ap.R_EWP_AC__c = 
        /**********PRODUCT CATEGORY BREAKDOWN - ALADDIN COMMERCIAL CARPET - RETAIL**********/
        
        /**********PRODUCT CATEGORY BREAKDOWN - RESILIENT RETAIL - RETAIL**********/
        //Estimated Retail Sales-Resilient Retail   
        
        ap.R_ERS_RR__c = (ap.R_ERS_R__c != null ? ap.R_ERS_R__c : 0) * ( apSetting.Resilient_Retail_Hard_TM2_New__c != null ? apSetting.Resilient_Retail_Hard_TM2_New__c : 0 )/100;
        //Est. Wholesale Purch. Resilient Retail
        //ap.R_EWP_RR__c = R_EWP_R__c * 
        /**********PRODUCT CATEGORY BREAKDOWN - RESILIENT RETAIL - RETAIL**********/
        
        /**********PRODUCT CATEGORY BREAKDOWN - ALADDIN COMMERCIAL RESILIENT - RETAIL**********/
        //Estimated Retail Sales-Resilient Comm
        ap.R_ERS_RC__c = (ap.R_ERS_R__c != null ? ap.R_ERS_R__c : 0) * (apSetting.Resilient_Mainstreet_Commercial_TM2_New__c != null ? apSetting.Resilient_Mainstreet_Commercial_TM2_New__c : 0)/100;
        //Est. Wholesale Purch. Resilient Comm
        //ap.R_EWP_RC__c = R_EWP_R__c * 
        /**********PRODUCT CATEGORY BREAKDOWN - ALADDIN COMMERCIAL RESILIENT**********/
        
        /**********ALADDIN CARPET BREAKDOWN - BUILDER/MULTI-FAMILY**********/
        //Estimated Retail Sales-Aladdin    
        ap.B_ERS_A__c = (ap.B_ERS_Car__c != null ? ap.B_ERS_Car__c : 0) * ( ap.No_Karastan__c ? (apSetting.No_Karastan_Aladdin_Carpet__c != null ? apSetting.No_Karastan_Aladdin_Carpet__c : 0) : (apSetting.Estimated_Purchase_Aladdin_Carpet__c != null ? apSetting.Estimated_Purchase_Aladdin_Carpet__c : 0) )/100;
        //Estimated Wholesale Purchases - Aladdin
        //ap.B_EWP_A__c = ap.B_EWP_Car__c * ( ap.No_Karastan__c ? apSetting.No_Karastan_Aladdin_Carpet__c : apSetting.Estimated_Purchase_Aladdin_Carpet__c );
        /**********ALADDIN CARPET BREAKDOWN - BUILDER/MULTI-FAMILY**********/

        /**********HORIZON CARPET BREAKDOWN - BUILDER/MULTI-FAMILY**********/
        //Estimated Retail Sales-Horizon
        ap.B_ERS_Hor__c = (ap.B_ERS_Car__c != null ? ap.B_ERS_Car__c : 0) * ( ap.No_Karastan__c ? (apSetting.No_Karastan_Horizon_Carpet__c != null ? apSetting.No_Karastan_Horizon_Carpet__c : 0) : (apSetting.Estimated_Purchase_Horizon_Carpet__c != null ? apSetting.Estimated_Purchase_Horizon_Carpet__c : 0) )/100;
        //Estimated Wholesale Purchases - Horizon
        //ap.B_EWP_Hor__c = ap.B_EWP_Car__c * ( ap.No_Karastan__c ? apSetting.No_Karastan_Horizon_Carpet__c : apSetting.Estimated_Purchase_Horizon_Carpet__c );
        /**********HORIZON CARPET BREAKDOWN - BUILDER/MULTI-FAMILY**********/

        /**********KARASTAN CARPET BREAKDOWN - BUILDER/MULTI-FAMILY**********/
        //Estimated Retail Sales-Karastan
        ap.B_ERS_Kar__c = (ap.B_ERS_Car__c != null ? ap.B_ERS_Car__c : 0) * ( ap.No_Karastan__c ? (apSetting.No_Karastan_Karastan_Carpet__c != null ? apSetting.No_Karastan_Karastan_Carpet__c : 0) : (apSetting.Estimated_Purchase_Karastan_Carpet__c != null ? apSetting.Estimated_Purchase_Karastan_Carpet__c : 0) )/100;
        //Estimated Wholesale Purch - Karastan
        //ap.B_EWP_Kar__c = ap.B_EWP_Car__c * ( ap.No_Karastan__c ? apSetting.No_Karastan_Karastan_Carpet__c : apSetting.Estimated_Purchase_Karastan_Carpet__c );
        /**********KARASTAN CARPET BREAKDOWN - BUILDER/MULTI-FAMILY**********/

        /**********ALADDIN COMMERCIAL CARPET BREAKDOWN - BUILDER/MULTI-FAMILY**********/
        //Estimated Retail Sales-Aladdin Comm
        ap.B_ERS_AC__c = (ap.B_ERS_Car__c != null ? ap.B_ERS_Car__c : 0) * (apSetting.Estimated_Purchase_Aladdin_Com_Car__c != null ? apSetting.Estimated_Purchase_Aladdin_Com_Car__c : 0)/100;
        //Est. Wholesale Purchases - Aladdin Comm
        //ap.B_EWP_AC__c = 
        /**********ALADDIN COMMERCIAL CARPET BREAKDOWN - BUILDER/MULTI-FAMILY**********/

        /**********RESILIENT RETAIL BREAKDOWN - BUILDER/MULTI-FAMILY**********/
        //Estimated Retail Sales-Resilient Retail
        ap.B_ERS_RR__c = (ap.B_ERS_R__c != null ? ap.B_ERS_R__c : 0) * ( apSetting.Resilient_Retail_Hard_TM2_New__c != null ? apSetting.Resilient_Retail_Hard_TM2_New__c : 0 )/100;
        //Est. Wholesale Purch-Resilient Retail
        //ap.B_EWP_RR__c = 
        /**********RESILIENT RETAIL BREAKDOWN - BUILDER/MULTI-FAMILY**********/

        /**********RESILIENT ALADDIN COMMERCIAL BREAKDOWN - BUILDER/MULTI-FAMILY**********/
        //Estimated Retail Sales-Resilient Comm
        ap.B_ERS_RC__c = (ap.B_ERS_R__c != null ? ap.B_ERS_R__c : 0) * (apSetting.Resilient_Mainstreet_Commercial_TM2_New__c != null ? apSetting.Resilient_Mainstreet_Commercial_TM2_New__c : 0)/100;
        //Est. Wholesale Purch. - Resilient Comm
        //ap.B_EWP_RC__c = 
        /**********RESILIENT ALADDIN COMMERCIAL BREAKDOWN - BUILDER/MULTI-FAMILY**********/
    }
    
    /************************************************************************************
    Method Name :   BIDataCalculation
    Return Type :   void
    Parameter   :   Account_Profile__c ap,Account_Profile_Settings__c apSetting
    Created By  :   Mudit Saxena
    Created On  :   12/2/2018
    Description :   Calculating BI Data.
    Modified    :    
    ************************************************************************************/
    public static void BIDataCalculation( Account_Profile__c ap ){
        //if( ap.Retail_Channel_Split__c > 0 ){
        if( ap.Retail_Channel_Split__c == 100 ){
            ap.R_AMP_ACT__c = ap.Actual_Mohawk_Purchases_Mainstreet_Com__c;
            ap.R_AMP_AC__c = ap.Actual_Mohawk_Purchases_Aladdin_Comm__c;
            ap.R_AMP_RC__c = ap.Actual_Mohawk_Purchases_Re_Comm__c;
            ap.R_AMP_RR__c = ap.Actual_Mohawk_Purchases_Re_Retail__c;
            ap.R_AMP_A__c = ap.Actual_Mohawk_Purchases_Aladdin__c;
            ap.R_AMP_Car__c = ap.Actual_Mohawk_Purchases_Carpet__c;
            ap.R_AMP_Cus__c = ap.Actual_Mohawk_Purchases_Cushion__c;
            ap.R_AMP_Har__c = ap.Actual_Mohawk_Purchases_Hardwood__c;
            ap.R_AMP_Hor__c = ap.Actual_Mohawk_Purchases_Horizon__c;
            ap.R_AMP_Kar__c = ap.Actual_Mohawk_Purchases_Karastan__c;
            ap.R_AMP_Lam__c = ap.Actual_Mohawk_Purchases_Laminate__c;
            ap.R_AMP_R__c =  ap.Actual_Mohawk_Purchases_Resilient__c;
            ap.R_AMP_T__c =  ap.Actual_Mohawk_Purchases_Tile__c;
            //Portico and Non Properties Retail
            ap.R_AMP_Car_Por__c = ap.Actual_Mohawk_Purchases_Ca_Portico__c;
            ap.R_AMP_Car_Prop__c = ap.Actual_Mohawk_Purchases_Ca_Prop__c;
            ap.R_AMP_Cus_Por__c = ap.Actual_Mohawk_Purchases_Cu_Po__c;
            ap.R_AMP_Cus_Prop__c = ap.Actual_Mohawk_Purchases_Cu_Prop__c;
            ap.R_AMP_Wood_Por__c = ap.Actual_Mohawk_Purchases_Ha_Po__c;
            ap.R_AMP_Wood_Prop__c = ap.Actual_Mohawk_Purchases_Ha_Prop__c;
            ap.R_AMP_Resil_Por__c = ap.Actual_Mohawk_Purchases_Re_Portico__c;
            ap.R_AMP_Resil_Prop__c = ap.Actual_Mohawk_Purchases_Re_Prop__c;
            ap.R_AMP_Lam_Por__c = ap.Actual_Mohawk_Purchases_La_Po__c;
            ap.R_AMP_Lam_Prop__c = ap.Actual_Mohawk_Purchases_La_Prop__c;
            ap.R_AMP_Tile_Por__c = ap.Actual_Mohawk_Purchases_Ti_Po__c;
            ap.R_AMP_Tile_Prop__c = ap.Actual_Mohawk_Purchases_Ti_Prop__c;
        }else
        {
            ap.R_AMP_ACT__c = 0;
            ap.R_AMP_AC__c = 0;
            ap.R_AMP_RC__c = 0;
            ap.R_AMP_RR__c = 0;
            ap.R_AMP_A__c = 0;
            ap.R_AMP_Car__c = 0;
            ap.R_AMP_Cus__c = 0;
            ap.R_AMP_Har__c = 0;
            ap.R_AMP_Hor__c = 0;
            ap.R_AMP_Kar__c = 0;
            ap.R_AMP_Lam__c = 0;
            ap.R_AMP_R__c =  0;
            ap.R_AMP_T__c =  0;
            //Portico and Non Properties Retail
            ap.R_AMP_Car_Por__c = 0;
            ap.R_AMP_Car_Prop__c = 0;
            ap.R_AMP_Cus_Por__c = 0;
            ap.R_AMP_Cus_Prop__c = 0;
            ap.R_AMP_Wood_Por__c = 0;
            ap.R_AMP_Wood_Prop__c = 0;
            ap.R_AMP_Resil_Por__c = 0;
            ap.R_AMP_Resil_Prop__c = 0;
            ap.R_AMP_Lam_Por__c = 0;
            ap.R_AMP_Lam_Prop__c = 0;
            ap.R_AMP_Tile_Por__c = 0;
            ap.R_AMP_Tile_Prop__c = 0;
        }
        
        //if(ap.Builder_Multi_Channel_split__c > 0)
        if(ap.Builder_Multi_Channel_split__c == 100)
        {
            ap.B_AMP_ACT__c = ap.Actual_Mohawk_Purchases_Mainstreet_Com__c;
            ap.B_AMP_AC__c = ap.Actual_Mohawk_Purchases_Aladdin_Comm__c;
            ap.B_AMP_RC__c = ap.Actual_Mohawk_Purchases_Re_Comm__c;
            ap.B_AMP_RR__c = ap.Actual_Mohawk_Purchases_Re_Retail__c;
            ap.B_AMP_A__c = ap.Actual_Mohawk_Purchases_Aladdin__c;      
            ap.B_AMP_Car__c = ap.Actual_Mohawk_Purchases_Carpet__c;
            ap.B_AMP_Cus__c = ap.Actual_Mohawk_Purchases_Cushion__c;
            ap.B_AMP_Har__c = ap.Actual_Mohawk_Purchases_Hardwood__c;
            ap.B_AMP_Hor__c = ap.Actual_Mohawk_Purchases_Horizon__c;
            ap.B_AMP_Kar__c = ap.Actual_Mohawk_Purchases_Karastan__c;
            ap.B_AMP_Lam__c = ap.Actual_Mohawk_Purchases_Laminate__c;
            ap.B_AMP_R__c =  ap.Actual_Mohawk_Purchases_Resilient__c;       
            ap.B_AMP_T__c =  ap.Actual_Mohawk_Purchases_Tile__c;
            //Portico and Non Properties Retail
            ap.B_AMP_Car_Por__c = ap.Actual_Mohawk_Purchases_Ca_Portico__c;
            ap.B_AMP_Car_Prop__c = ap.Actual_Mohawk_Purchases_Ca_Prop__c;
            ap.B_AMP_Cus_Por__c = ap.Actual_Mohawk_Purchases_Cu_Po__c;
            ap.B_AMP_Cus_Prop__c = ap.Actual_Mohawk_Purchases_Cu_Prop__c;
            ap.B_AMP_Wood_Por__c = ap.Actual_Mohawk_Purchases_Ha_Po__c;
            ap.B_AMP_Wood_Prop__c = ap.Actual_Mohawk_Purchases_Ha_Prop__c;
            ap.B_AMP_Resil_Por__c = ap.Actual_Mohawk_Purchases_Re_Portico__c;
            ap.B_AMP_Resil_Prop__c = ap.Actual_Mohawk_Purchases_Re_Prop__c;
            ap.B_AMP_Lam_Por__c = ap.Actual_Mohawk_Purchases_La_Po__c;
            ap.B_AMP_Lam_Prop__c = ap.Actual_Mohawk_Purchases_La_Prop__c;
            ap.B_AMP_Tile_Por__c = ap.Actual_Mohawk_Purchases_Ti_Po__c;
            ap.B_AMP_Tile_Prop__c = ap.Actual_Mohawk_Purchases_Ti_Prop__c;
        }else
        {
            ap.B_AMP_ACT__c = 0;
            ap.B_AMP_AC__c = 0;
            ap.B_AMP_RC__c = 0;
            ap.B_AMP_RR__c = 0;
            ap.B_AMP_A__c = 0;     
            ap.B_AMP_Car__c = 0;
            ap.B_AMP_Cus__c = 0;
            ap.B_AMP_Har__c = 0;
            ap.B_AMP_Hor__c = 0;
            ap.B_AMP_Kar__c = 0;
            ap.B_AMP_Lam__c = 0;
            ap.B_AMP_R__c =  0;      
            ap.B_AMP_T__c =  0;
            //Portico and Non Properties Retail
            ap.B_AMP_Car_Por__c = 0;
            ap.B_AMP_Car_Prop__c = 0;
            ap.B_AMP_Cus_Por__c = 0;
            ap.B_AMP_Cus_Prop__c = 0;
            ap.B_AMP_Wood_Por__c = 0;
            ap.B_AMP_Wood_Prop__c = 0;
            ap.B_AMP_Resil_Por__c = 0;
            ap.B_AMP_Resil_Prop__c = 0;
            ap.B_AMP_Lam_Por__c = 0;
            ap.B_AMP_Lam_Prop__c = 0;
            ap.B_AMP_Tile_Por__c = 0;
            ap.B_AMP_Tile_Prop__c = 0;
        }
    }
    
    public static void resetBICalculation( Account_Profile__c ap ){
        ap.R_AMP_ACT__c = 0;
        ap.R_AMP_AC__c = 0;
        ap.R_AMP_RC__c = 0;
        ap.R_AMP_RR__c = 0;
        ap.R_AMP_A__c = 0;
        ap.R_AMP_Car__c = 0;
        ap.R_AMP_Cus__c = 0;
        ap.R_AMP_Har__c = 0;
        ap.R_AMP_Hor__c = 0;
        ap.R_AMP_Kar__c = 0;
        ap.R_AMP_Lam__c = 0;
        ap.R_AMP_R__c =  0;
        ap.R_AMP_T__c =  0;
        //Portico and Non Properties Retail
        ap.R_AMP_Car_Por__c = 0;
        ap.R_AMP_Car_Prop__c = 0;
        ap.R_AMP_Cus_Por__c = 0;
        ap.R_AMP_Cus_Prop__c = 0;
        ap.R_AMP_Wood_Por__c = 0;
        ap.R_AMP_Wood_Prop__c = 0;
        ap.R_AMP_Resil_Por__c = 0;
        ap.R_AMP_Resil_Prop__c = 0;
        ap.R_AMP_Lam_Por__c = 0;
        ap.R_AMP_Lam_Prop__c = 0;
        ap.R_AMP_Tile_Por__c = 0;
        ap.R_AMP_Tile_Prop__c = 0;
        ap.B_AMP_ACT__c = 0;
        ap.B_AMP_AC__c = 0;
        ap.B_AMP_RC__c = 0;
        ap.B_AMP_RR__c = 0;
        ap.B_AMP_A__c = 0;     
        ap.B_AMP_Car__c = 0;
        ap.B_AMP_Cus__c = 0;
        ap.B_AMP_Har__c = 0;
        ap.B_AMP_Hor__c = 0;
        ap.B_AMP_Kar__c = 0;
        ap.B_AMP_Lam__c = 0;
        ap.B_AMP_R__c =  0;      
        ap.B_AMP_T__c =  0;
        //Portico and Non Properties Retail
        ap.B_AMP_Car_Por__c = 0;
        ap.B_AMP_Car_Prop__c = 0;
        ap.B_AMP_Cus_Por__c = 0;
        ap.B_AMP_Cus_Prop__c = 0;
        ap.B_AMP_Wood_Por__c = 0;
        ap.B_AMP_Wood_Prop__c = 0;
        ap.B_AMP_Resil_Por__c = 0;
        ap.B_AMP_Resil_Prop__c = 0;
        ap.B_AMP_Lam_Por__c = 0;
        ap.B_AMP_Lam_Prop__c = 0;
        ap.B_AMP_Tile_Por__c = 0;
        ap.B_AMP_Tile_Prop__c = 0;      
    }
    
    /************************************************************************************
    Method Name :   calculateMarketShare
    Return Type :   void
    Parameter   :   Account_Profile__c ap,Account_Profile_Settings__c apSetting
    Created By  :   Mudit Saxena
    Created On  :   12/2/2018
    Description :   Calculating Market Share.
    Modified    :    
    ************************************************************************************/
    public static void calculateMarketShare( Account_Profile__c ap ){
        /**********TOTAL MOHAWK OVERVIEW- ALL CHANNELS**********/
        //ap.Current_Mohawk_Share_Total__c = ((ap.AMP_Total__c != null ? ap.AMP_Total__c : 0)/(ap.EWP_Total__c != null ? ap.EWP_Total__c : 0))*100;
        /**********TOTAL MOHAWK OVERVIEW- ALL CHANNELS**********/
        
        /**********TOTAL MOHAWK OVERVIEW - RETAIL**********/
        /**********TOTAL MOHAWK OVERVIEW - RETAIL**********/
    }
    
    /************************************************************************************
    Method Name :   calculateOpportunityValue
    Return Type :   void
    Parameter   :   Account_Profile__c ap,Account_Profile_Settings__c apSetting
    Created By  :   Mudit Saxena
    Created On  :   12/2/2018
    Description :   Calculating Red, Yellow and Green Opportunitys.
    Modified    :    
    ************************************************************************************/
    public static void calculateOpportunityValue( Account_Profile__c ap,Account_Profile_Settings__c apSetting ){
        /**********PRODUCT CATEGORY OVERVIEW- CARPET OVERVIEW - (RETAIL SECTION)**********/
        ap.R_GOpp_Car__c = (ap.R_EWP_Car__c != null ? ap.R_EWP_Car__c : 0) * (apSetting.Yellow_Threshold_Carpet__c != null ? apSetting.Yellow_Threshold_Carpet__c : 0) /100; 
        ap.R_Yellow_Opportunity_Carpet__c = (ap.R_EWP_Car__c != null ? ap.R_EWP_Car__c : 0) * ((apSetting.Red_Threshold_Carpet__c != null ? apSetting.Red_Threshold_Carpet__c : 0) - (apSetting.Yellow_Threshold_Carpet__c != null ? apSetting.Yellow_Threshold_Carpet__c : 0))/100;
        ap.R_ROpp_Car__c = (ap.R_EWP_Car__c != null ? ap.R_EWP_Car__c : 0) * (100 - (apSetting.Red_Threshold_Carpet__c != null ? apSetting.Red_Threshold_Carpet__c : 0))/100;
        /**********PRODUCT CATEGORY OVERVIEW- CARPET OVERVIEW - (RETAIL SECTION)**********/

        /**********PRODUCT CATEGORY BREAKDOWN - ALADDIN - (RETAIL SECTION)**********/
        //ap.R_GOpp_A__c = (ap.R_EWP_A__c != null ? ap.R_EWP_A__c : 0) * (apSetting.Yellow_Threshold_Carpet__c != null ? apSetting.Yellow_Threshold_Carpet__c : 0)/100;
        //ap.R_Yellow_Opportunity_Aladdin__c = (ap.R_EWP_A__c != null ? ap.R_EWP_A__c : 0) * ((apSetting.Red_Threshold_Carpet__c != null ? apSetting.Red_Threshold_Carpet__c : 0) - (apSetting.Yellow_Threshold_Carpet__c != null ? apSetting.Yellow_Threshold_Carpet__c : 0))/100;
        //ap.R_ROpp_A__c = (ap.R_EWP_A__c != null ? ap.R_EWP_A__c : 0) * (100 - (apSetting.Red_Threshold_Carpet__c != null ? apSetting.Red_Threshold_Carpet__c : 0))/100;
        /**********PRODUCT CATEGORY BREAKDOWN - ALADDIN - (RETAIL SECTION)**********/

        /**********PRODUCT CATEGORY BREAKDOWN - HORIZON - (RETAIL SECTION)**********/
        //ap.R_GOpp_Hor__c = (ap.R_EWP_Hor__c != null ? ap.R_EWP_Hor__c : 0) * (apSetting.Yellow_Threshold_Carpet__c != null ? apSetting.Yellow_Threshold_Carpet__c : 0)/100;
        //ap.R_Yellow_Opportunity_Horizon__c = (ap.R_EWP_Hor__c != null ? ap.R_EWP_Hor__c : 0) * ((apSetting.Red_Threshold_Carpet__c != null ? apSetting.Red_Threshold_Carpet__c : 0) - (apSetting.Yellow_Threshold_Carpet__c != null ? apSetting.Yellow_Threshold_Carpet__c : 0))/100;
        //ap.R_ROpp_Hor__c = (ap.R_EWP_Hor__c != null ? ap.R_EWP_Hor__c : 0) * (100 - (apSetting.Red_Threshold_Carpet__c != null ? apSetting.Red_Threshold_Carpet__c : 0))/100;
        /**********PRODUCT CATEGORY BREAKDOWN - HORIZON - (RETAIL SECTION)**********/

        /**********PRODUCT CATEGORY BREAKDOWN - KARASTAN - (RETAIL SECTION)**********/
        //ap.R_GOpp_Kar__c = (ap.R_EWP_Kar__c != null ? ap.R_EWP_Kar__c : 0) * (apSetting.Yellow_Threshold_Carpet__c != null ? apSetting.Yellow_Threshold_Carpet__c : 0)/100;
        //ap.R_Yellow_Opportunity_Karastan__c = (ap.R_EWP_Kar__c != null ? ap.R_EWP_Kar__c : 0) * ((apSetting.Red_Threshold_Carpet__c != null ? apSetting.Red_Threshold_Carpet__c : 0) - (apSetting.Yellow_Threshold_Carpet__c != null ? apSetting.Yellow_Threshold_Carpet__c : 0))/100;
        //ap.R_ROpp_K__c = (ap.R_EWP_Kar__c != null ? ap.R_EWP_Kar__c : 0) * (100 - (apSetting.Red_Threshold_Carpet__c != null ? apSetting.Red_Threshold_Carpet__c : 0))/100;
        /**********PRODUCT CATEGORY BREAKDOWN - KARASTAN - (RETAIL SECTION)**********/

        /**********PRODUCT CATEGORY BREAKDOWN - ALADDIN COMMERCIAL CARPET - (RETAIL SECTION)**********/
        //ap.R_GOpp_AC__c = (ap.R_EWP_AC__c != null ? ap.R_EWP_AC__c : 0) * (apSetting.Yellow_Threshold_Carpet__c != null ? apSetting.Yellow_Threshold_Carpet__c : 0)/100;
        //ap.R_Yellow_Opportunity_Aladdin_Comm__c = (ap.R_EWP_AC__c != null ? ap.R_EWP_AC__c : 0) * ((apSetting.Red_Threshold_Carpet__c != null ? apSetting.Red_Threshold_Carpet__c : 0) - (apSetting.Yellow_Threshold_Carpet__c != null ? apSetting.Yellow_Threshold_Carpet__c : 0))/100;
        //ap.R_ROpp_AC__c = (ap.R_EWP_AC__c != null ? ap.R_EWP_AC__c : 0) * (100 - (apSetting.Red_Threshold_Carpet__c != null ? apSetting.Red_Threshold_Carpet__c : 0))/100;
        /**********PRODUCT CATEGORY BREAKDOWN - ALADDIN COMMERCIAL CARPET - (RETAIL SECTION)**********/

        /**********PRODUCT CATEGORY OVERVIEW- CUSHION OVERVIEW - (RETAIL SECTION)**********/
        ap.R_GOpp_Cus__c = (ap.R_EWP_Cus__c != null ? ap.R_EWP_Cus__c : 0) * (apSetting.Yellow_Threshold_Cushion__c != null ? apSetting.Yellow_Threshold_Cushion__c : 0)/100;
        ap.R_Yellow_Opportunity_Cushion__c = (ap.R_EWP_Cus__c != null ? ap.R_EWP_Cus__c : 0) * ((apSetting.Red_Threshold_Cushion__c != null ? apSetting.Red_Threshold_Cushion__c : 0) - (apSetting.Yellow_Threshold_Cushion__c != null ? apSetting.Yellow_Threshold_Cushion__c : 0))/100;
        ap.R_ROpp_Cus__c = (ap.R_EWP_Cus__c != null ? ap.R_EWP_Cus__c : 0) * (100 - (apSetting.Red_Threshold_Cushion__c != null ? apSetting.Red_Threshold_Cushion__c : 0))/100;
        /**********PRODUCT CATEGORY OVERVIEW- CUSHION OVERVIEW - (RETAIL SECTION)**********/

        /**********PRODUCT CATEGORY OVERVIEW- WOOD OVERVIEW - (RETAIL SECTION)**********/
        ap.R_GOpp_Har__c = (ap.R_EWP_Har__c != null ? ap.R_EWP_Har__c : 0) * (apSetting.Yellow_Threshold_Hardwood__c != null ? apSetting.Yellow_Threshold_Hardwood__c : 0)/100;
        ap.R_Yellow_Opportunity_Hardwood__c = (ap.R_EWP_Har__c != null ? ap.R_EWP_Har__c : 0) * ((apSetting.Red_Threshold_Hardwood__c != null ? apSetting.Red_Threshold_Hardwood__c : 0) - (apSetting.Yellow_Threshold_Hardwood__c != null ? apSetting.Yellow_Threshold_Hardwood__c : 0))/100;
        ap.R_ROpp_Har__c = (ap.R_EWP_Har__c != null ? ap.R_EWP_Har__c : 0) * (100 - (apSetting.Red_Threshold_Hardwood__c != null ? apSetting.Red_Threshold_Hardwood__c : 0))/100;
        /**********PRODUCT CATEGORY OVERVIEW- WOOD OVERVIEW - (RETAIL SECTION)**********/

        /**********PRODUCT CATEGORY OVERVIEW- LAMINATE OVERVIEW - (RETAIL SECTION)**********/
        ap.R_GOpp_L__c = (ap.R_EWP_Lam__c != null ? ap.R_EWP_Lam__c : 0) * (apSetting.Yellow_Threshold_Laminate__c != null ? apSetting.Yellow_Threshold_Laminate__c : 0)/100;
        ap.R_Yellow_Opportunity_Laminate__c = (ap.R_EWP_Lam__c != null ? ap.R_EWP_Lam__c : 0) * ((apSetting.Red_Threshold_Laminate__c != null ? apSetting.Red_Threshold_Laminate__c : 0) - (apSetting.Yellow_Threshold_Laminate__c != null ? apSetting.Yellow_Threshold_Laminate__c : 0))/100;
        ap.R_ROpp_L__c = (ap.R_EWP_Lam__c != null ? ap.R_EWP_Lam__c : 0) * (100 - (apSetting.Red_Threshold_Laminate__c != null ? apSetting.Red_Threshold_Laminate__c : 0))/100;
        /**********PRODUCT CATEGORY OVERVIEW- LAMINATE OVERVIEW - (RETAIL SECTION)**********/

        /**********PRODUCT CATEGORY OVERVIEW- TILE OVERVIEW - (RETAIL SECTION)**********/
        ap.R_GOpp_T__c = (ap.R_EWP_T__c != null ? ap.R_EWP_T__c : 0) * ( apSetting.Yellow_Threshold_Tile__c != null ? apSetting.Yellow_Threshold_Tile__c : 0 )/100;
        ap.R_Yellow_Opportunity_Tile__c = (ap.R_EWP_T__c != null ? ap.R_EWP_T__c : 0) * ( (apSetting.Red_Threshold_Tile__c != null ? apSetting.Red_Threshold_Tile__c : 0) - ( apSetting.Yellow_Threshold_Tile__c != null ? apSetting.Yellow_Threshold_Tile__c : 0 ))/100;
        ap.R_Red_Opportunity_Tile__c = (ap.R_EWP_T__c != null ? ap.R_EWP_T__c : 0) * ( 100 - (apSetting.Red_Threshold_Tile__c != null ? apSetting.Red_Threshold_Tile__c : 0))/100;
        /**********PRODUCT CATEGORY OVERVIEW- TILE OVERVIEW - (RETAIL SECTION)**********/

        /**********PRODUCT CATEGORY OVERVIEW- RESILIENT OVERVIEW - (RETAIL SECTION)**********/
        ap.R_GOpp_R__c = (ap.R_EWP_R__c != null ? ap.R_EWP_R__c : 0) * (apSetting.Yellow_Threshold_Resilient__c != null ? apSetting.Yellow_Threshold_Resilient__c : 0)/100;
        ap.R_Yellow_Opportunity_Resilient__c = (ap.R_EWP_R__c != null ? ap.R_EWP_R__c : 0) * ((apSetting.Red_Threshold_Resilient__c != null ? apSetting.Red_Threshold_Resilient__c : 0) - (apSetting.Yellow_Threshold_Resilient__c != null ? apSetting.Yellow_Threshold_Resilient__c : 0))/100;
        ap.R_ROpp_R__c = (ap.R_EWP_R__c != null ? ap.R_EWP_R__c : 0) * (100 - (apSetting.Red_Threshold_Resilient__c != null ? apSetting.Red_Threshold_Resilient__c : 0))/100;
        /**********PRODUCT CATEGORY OVERVIEW- RESILIENT OVERVIEW - (RETAIL SECTION)**********/

        /**********PRODUCT CATEGORY BREAKDOWN - RESILIENT RETAIL - (RETAIL SECTION)**********/
        //ap.R_GOpp_RR__c = (ap.R_EWP_RR__c != null ? ap.R_EWP_RR__c : 0) * (apSetting.Yellow_Threshold_Resilient__c != null ? apSetting.Yellow_Threshold_Resilient__c : 0)/100;
        //ap.R_Yellow_Opportunity_Resilient_Retail__c = (ap.R_EWP_RR__c != null ? ap.R_EWP_RR__c : 0) * ((apSetting.Red_Threshold_Resilient__c != null ? apSetting.Red_Threshold_Resilient__c : 0) - (apSetting.Yellow_Threshold_Resilient__c != null ? apSetting.Yellow_Threshold_Resilient__c : 0))/100;
        //ap.R_Red_Opportunity_Resilient_Retail__c = (ap.R_EWP_RR__c != null ? ap.R_EWP_RR__c : 0) * (100 - (apSetting.Red_Threshold_Resilient__c != null ? apSetting.Red_Threshold_Resilient__c : 0))/100;
        /**********PRODUCT CATEGORY BREAKDOWN - RESILIENT RETAIL - (RETAIL SECTION)**********/

        /**********PRODUCT CATEGORY BREAKDOWN - ALADDIN COMMERCIAL RESILIENT - (RETAIL SECTION)**********/
        //ap.R_GOpp_RC__c =(ap.R_EWP_RC__c != null ? ap.R_EWP_RC__c : 0) * (apSetting.Yellow_Threshold_Resilient__c != null ? apSetting.Yellow_Threshold_Resilient__c : 0)/100;
        //ap.R_Yellow_Opportunity_Resilient_Comm__c = (ap.R_EWP_RC__c != null ? ap.R_EWP_RC__c : 0) * ((apSetting.Red_Threshold_Resilient__c != null ? apSetting.Red_Threshold_Resilient__c : 0) - (apSetting.Yellow_Threshold_Resilient__c != null ? apSetting.Yellow_Threshold_Resilient__c : 0))/100;
        //ap.R_Red_Opportunity_Resilient_Comm__c = (ap.R_EWP_RC__c != null ? ap.R_EWP_RC__c : 0) * (100 - (apSetting.Red_Threshold_Resilient__c != null ? apSetting.Red_Threshold_Resilient__c : 0))/100;
        /**********PRODUCT CATEGORY BREAKDOWN - ALADDIN COMMERCIAL RESILIENT - (RETAIL SECTION)**********/

        /**********PRODUCT CATEGORY OVERVIEW- ALADDIN COMMERCIAL OVERVIEW - (RETAIL SECTION)**********
        ap.R_GOpp_ACT__c = apSetting.
        ap.R_Yellow_Opportunity_Aladdin_Comm_Total__c = apSetting.
        ap.R_ROpp_ACT__c = apSetting.
        **********PRODUCT CATEGORY OVERVIEW- ALADDIN COMMERCIAL OVERVIEW - (RETAIL SECTION)**********/
        
        /**********PRODUCT CATEGORY OVERVIEW- CARPET OVERVIEW - (BUILDER/MULTI-FAMILY SECTION)**********/
        ap.B_GOpp_Car__c = (ap.B_EWP_Car__c != null ? ap.B_EWP_Car__c : 0) * (apSetting.Yellow_Threshold_Carpet__c != null ? apSetting.Yellow_Threshold_Carpet__c : 0)/100;
        ap.B_Yellow_Opportunity_Carpet__c = (ap.B_EWP_Car__c != null ? ap.B_EWP_Car__c : 0) * ( (apSetting.Red_Threshold_Carpet__c != null ? apSetting.Red_Threshold_Carpet__c : 0) - (apSetting.Yellow_Threshold_Carpet__c != null ? apSetting.Yellow_Threshold_Carpet__c : 0) )/100;
        ap.B_ROpp_Car__c = (ap.B_EWP_Car__c != null ? ap.B_EWP_Car__c : 0) * (100 - (apSetting.Red_Threshold_Carpet__c != null ? apSetting.Red_Threshold_Carpet__c : 0))/100;
        /**********PRODUCT CATEGORY OVERVIEW- CARPET OVERVIEW - (BUILDER/MULTI-FAMILY SECTION)**********/
        
        /**********PRODUCT CATEGORY BREAKDOWN - ALADDIN - (BUILDER/MULTI-FAMILY SECTION)**********/
        //ap.B_GOpp_A__c = (ap.B_EWP_A__c != null ? ap.B_EWP_A__c : 0) * (apSetting.Yellow_Threshold_Carpet__c != null ? apSetting.Yellow_Threshold_Carpet__c : 0)/100;
        //ap.B_Yellow_Opportunity_Aladdin__c = (ap.B_EWP_A__c != null ? ap.B_EWP_A__c : 0) * ( (apSetting.Red_Threshold_Carpet__c != null ? apSetting.Red_Threshold_Carpet__c : 0) - (apSetting.Yellow_Threshold_Carpet__c != null ? apSetting.Yellow_Threshold_Carpet__c : 0) )/100;
        //ap.B_ROpp_A__c = (ap.B_EWP_A__c != null ? ap.B_EWP_A__c : 0) * (100 - (apSetting.Red_Threshold_Carpet__c != null ? apSetting.Red_Threshold_Carpet__c : 0))/100;
        /**********PRODUCT CATEGORY BREAKDOWN - ALADDIN - (BUILDER/MULTI-FAMILY SECTION)**********/

        /**********PRODUCT CATEGORY BREAKDOWN - HORIZON - (BUILDER/MULTI-FAMILY SECTION)**********/
        //ap.B_GOpp_Hor__c = (ap.B_EWP_Hor__c != null ? ap.B_EWP_Hor__c : 0) * (apSetting.Yellow_Threshold_Carpet__c != null ? apSetting.Yellow_Threshold_Carpet__c : 0)/100;
        //ap.B_Yellow_Opportunity_Horizon__c = (ap.B_EWP_Hor__c != null ? ap.B_EWP_Hor__c : 0) * ( (apSetting.Red_Threshold_Carpet__c != null ? apSetting.Red_Threshold_Carpet__c : 0) - (apSetting.Yellow_Threshold_Carpet__c != null ? apSetting.Yellow_Threshold_Carpet__c : 0) )/100;
        //ap.B_ROpp_Hor__c = (ap.B_EWP_Hor__c != null ? ap.B_EWP_Hor__c : 0) * (100 - (apSetting.Red_Threshold_Carpet__c != null ? apSetting.Red_Threshold_Carpet__c : 0))/100;
        /**********PRODUCT CATEGORY BREAKDOWN - HORIZON - (BUILDER/MULTI-FAMILY SECTION)**********/
        
        /**********PRODUCT CATEGORY BREAKDOWN - KARASTAN - (BUILDER/MULTI-FAMILY SECTION)**********/
        //ap.B_GOpp_Kar__c = (ap.B_EWP_K__c != null ? ap.B_EWP_K__c : 0) * (apSetting.Yellow_Threshold_Carpet__c != null ? apSetting.Yellow_Threshold_Carpet__c : 0)/100;
        //ap.B_Yellow_Opportunity_Karastan__c = (ap.B_EWP_K__c != null ? ap.B_EWP_K__c : 0) * ( (apSetting.Red_Threshold_Carpet__c != null ? apSetting.Red_Threshold_Carpet__c : 0) - (apSetting.Yellow_Threshold_Carpet__c != null ? apSetting.Yellow_Threshold_Carpet__c : 0) )/100;
        //ap.B_ROpp_K__c = (ap.B_EWP_K__c != null ? ap.B_EWP_K__c : 0) * (100 - (apSetting.Red_Threshold_Carpet__c != null ? apSetting.Red_Threshold_Carpet__c : 0))/100;
        /**********PRODUCT CATEGORY BREAKDOWN - KARASTAN - (BUILDER/MULTI-FAMILY SECTION)**********/
        
        /**********PRODUCT CATEGORY BREAKDOWN - ALADDIN COMMERCIAL CARPET - (BUILDER/MULTI-FAMILY SECTION)**********/
        //ap.B_GOpp_AC__c = (ap.B_EWP_AC__c != null ? ap.B_EWP_AC__c : 0) * (apSetting.Yellow_Threshold_Carpet__c != null ? apSetting.Yellow_Threshold_Carpet__c : 0)/100;
        //ap.B_Yellow_Opportunity_Aladdin_Comm__c = (ap.B_EWP_AC__c != null ? ap.B_EWP_AC__c : 0) * ( (apSetting.Red_Threshold_Carpet__c != null ? apSetting.Red_Threshold_Carpet__c : 0) - (apSetting.Yellow_Threshold_Carpet__c != null ? apSetting.Yellow_Threshold_Carpet__c : 0) )/100;
        //ap.B_ROpp_AC__c = (ap.B_EWP_AC__c != null ? ap.B_EWP_AC__c : 0) * (100 - (apSetting.Red_Threshold_Carpet__c != null ? apSetting.Red_Threshold_Carpet__c : 0))/100;
        /**********PRODUCT CATEGORY BREAKDOWN - ALADDIN COMMERCIAL CARPET - (BUILDER/MULTI-FAMILY SECTION)**********/
        
        /**********PRODUCT CATEGORY OVERVIEW- CUSHION OVERVIEW - (BUILDER/MULTI-FAMILY SECTION)**********/
        ap.B_GOpp_Cus__c = ( ap.B_EWP_Cus__c != null ? ap.B_EWP_Cus__c : 0 ) * (apSetting.Yellow_Threshold_Cushion__c != null ? apSetting.Yellow_Threshold_Cushion__c : 0)/100;
        ap.B_Yellow_Opportunity_Cushion__c = ( ap.B_EWP_Cus__c != null ? ap.B_EWP_Cus__c : 0 ) * ((apSetting.Red_Threshold_Cushion__c != null ? apSetting.Red_Threshold_Cushion__c : 0) - (apSetting.Yellow_Threshold_Cushion__c != null ? apSetting.Yellow_Threshold_Cushion__c : 0))/100;
        ap.B_ROpp_Cus__c = ( ap.B_EWP_Cus__c != null ? ap.B_EWP_Cus__c : 0 ) * (100 - (apSetting.Red_Threshold_Cushion__c != null ? apSetting.Red_Threshold_Cushion__c : 0))/100;
        /**********PRODUCT CATEGORY OVERVIEW- CUSHION OVERVIEW - (BUILDER/MULTI-FAMILY SECTION)**********/
        
        /**********PRODUCT CATEGORY OVERVIEW- WOOD OVERVIEW - (BUILDER/MULTI-FAMILY SECTION)**********/
        ap.B_GOpp_Har__c = (ap.B_EWP_Har__c != null ? ap.B_EWP_Har__c : 0) * (apSetting.Yellow_Threshold_Hardwood__c != null ? apSetting.Yellow_Threshold_Hardwood__c : 0)/100;
        ap.B_Yellow_Opportunity_Hardwood__c = (ap.B_EWP_Har__c != null ? ap.B_EWP_Har__c : 0) * ((apSetting.Red_Threshold_Hardwood__c != null ? apSetting.Red_Threshold_Hardwood__c : 0) - (apSetting.Yellow_Threshold_Hardwood__c != null ? apSetting.Yellow_Threshold_Hardwood__c : 0))/100;
        ap.B_ROpp_Har__c = (ap.B_EWP_Har__c != null ? ap.B_EWP_Har__c : 0) * (100 - (apSetting.Red_Threshold_Hardwood__c != null ? apSetting.Red_Threshold_Hardwood__c : 0))/100;
        /**********PRODUCT CATEGORY OVERVIEW- WOOD OVERVIEW - (BUILDER/MULTI-FAMILY SECTION)**********/
        
        /**********PRODUCT CATEGORY OVERVIEW- LAMINATE OVERVIEW - (BUILDER/MULTI-FAMILY SECTION)**********/
        ap.B_GOpp_L__c = (ap.B_EWP_Lam__c != null ? ap.B_EWP_Lam__c : 0) * (apSetting.Yellow_Threshold_Laminate__c != null ? apSetting.Yellow_Threshold_Laminate__c : 0)/100;
        ap.B_Yellow_Opportunity_Laminate__c = (ap.B_EWP_Lam__c != null ? ap.B_EWP_Lam__c : 0) * ((apSetting.Red_Threshold_Laminate__c != null ? apSetting.Red_Threshold_Laminate__c : 0) - (apSetting.Yellow_Threshold_Laminate__c != null ? apSetting.Yellow_Threshold_Laminate__c : 0))/100;
        ap.B_ROpp_L__c = (ap.B_EWP_Lam__c != null ? ap.B_EWP_Lam__c : 0) * (100 - (apSetting.Red_Threshold_Laminate__c != null ? apSetting.Red_Threshold_Laminate__c : 0))/100;
        /**********PRODUCT CATEGORY OVERVIEW- LAMINATE OVERVIEW - (BUILDER/MULTI-FAMILY SECTION)**********/
        
        /**********PRODUCT CATEGORY OVERVIEW- TILE OVERVIEW - (BUILDER/MULTI-FAMILY SECTION)**********/
        ap.B_GOpp_T__c = (ap.B_EWP_T__c != null ? ap.B_EWP_T__c : 0) * (apSetting.Yellow_Threshold_Tile__c != null ? apSetting.Yellow_Threshold_Tile__c : 0)/100;
        ap.B_Yellow_Opportunity_Tile__c = (ap.B_EWP_T__c != null ? ap.B_EWP_T__c : 0) * ((apSetting.Red_Threshold_Tile__c != null ? apSetting.Red_Threshold_Tile__c : 0) - (apSetting.Yellow_Threshold_Tile__c != null ? apSetting.Yellow_Threshold_Tile__c : 0))/100;
        ap.B_Red_Opportunity_Tile__c = (ap.B_EWP_T__c != null ? ap.B_EWP_T__c : 0) * (100 - (apSetting.Red_Threshold_Tile__c != null ? apSetting.Red_Threshold_Tile__c : 0))/100;
        /**********PRODUCT CATEGORY OVERVIEW- TILE OVERVIEW - (BUILDER/MULTI-FAMILY SECTION)**********/
        
        /**********PRODUCT CATEGORY OVERVIEW- RESILIENT OVERVIEW - (BUILDER/MULTI-FAMILY SECTION)**********/
        ap.B_GOpp_R__c = (ap.B_EWP_R__c != null ? ap.B_EWP_R__c : 0) * (apSetting.Yellow_Threshold_Resilient__c != null ? apSetting.Yellow_Threshold_Resilient__c : 0)/100;
        ap.B_Yellow_Opportunity_Resilient__c = (ap.B_EWP_R__c != null ? ap.B_EWP_R__c : 0) *  ((apSetting.Red_Threshold_Resilient__c != null ? apSetting.Red_Threshold_Resilient__c : 0) - (apSetting.Yellow_Threshold_Resilient__c != null ? apSetting.Yellow_Threshold_Resilient__c : 0))/100;
        ap.B_ROpp_R__c = (ap.B_EWP_R__c != null ? ap.B_EWP_R__c : 0) * (100 - (apSetting.Red_Threshold_Resilient__c != null ? apSetting.Red_Threshold_Resilient__c : 0))/100;
        /**********PRODUCT CATEGORY OVERVIEW- RESILIENT OVERVIEW - (BUILDER/MULTI-FAMILY SECTION)**********/
        
        /**********PRODUCT CATEGORY BREAKDOWN - RESILIENT RETAIL - (BUILDER/MULTI-FAMILY SECTION)**********/
        //ap.B_GOpp_RR__c = (ap.B_GOpp_RR__c != null ? ap.B_GOpp_RR__c : 0) * (apSetting.Yellow_Threshold_Resilient__c != null ? apSetting.Yellow_Threshold_Resilient__c : 0)/100;
        //ap.B_Yellow_Opportunity_Resilient_Retail__c = (ap.B_GOpp_RR__c != null ? ap.B_GOpp_RR__c : 0) * (ap.B_EWP_T__c != null ? ap.B_EWP_T__c : 0) * ((apSetting.Red_Threshold_Resilient__c != null ? apSetting.Red_Threshold_Resilient__c : 0) - (apSetting.Yellow_Threshold_Resilient__c != null ? apSetting.Yellow_Threshold_Resilient__c : 0))/100;
        //ap.B_Red_Opportunity_Resilient_Retail__c = (ap.B_GOpp_RR__c != null ? ap.B_GOpp_RR__c : 0) * (100 - (apSetting.Red_Threshold_Resilient__c != null ? apSetting.Red_Threshold_Resilient__c : 0))/100;
        /**********PRODUCT CATEGORY BREAKDOWN - RESILIENT RETAIL - (BUILDER/MULTI-FAMILY SECTION)**********/
        
        /**********PRODUCT CATEGORY BREAKDOWN - ALADDIN COMMERCIAL RESILIENT - (BUILDER/MULTI-FAMILY SECTION)**********/
        //ap.B_GOpp_RC__c = (ap.B_EWP_RC__c != null ? ap.B_EWP_RC__c : 0) * (apSetting.Yellow_Threshold_Resilient__c != null ? apSetting.Yellow_Threshold_Resilient__c : 0)/100;
        //ap.B_Yellow_Opportunity_Resilient_Comm__c = (ap.B_EWP_RC__c != null ? ap.B_EWP_RC__c : 0) * (ap.B_EWP_T__c != null ? ap.B_EWP_T__c : 0) * ((apSetting.Red_Threshold_Resilient__c != null ? apSetting.Red_Threshold_Resilient__c : 0) - (apSetting.Yellow_Threshold_Resilient__c != null ? apSetting.Yellow_Threshold_Resilient__c : 0))/100;
        //ap.B_Red_Opportunity_Resilient_Comm__c = (ap.B_EWP_RC__c != null ? ap.B_EWP_RC__c : 0) * (100 - (apSetting.Red_Threshold_Resilient__c != null ? apSetting.Red_Threshold_Resilient__c : 0))/100;
        /**********PRODUCT CATEGORY BREAKDOWN - ALADDIN COMMERCIAL RESILIENT - (BUILDER/MULTI-FAMILY SECTION)**********/
        
        /**********PRODUCT CATEGORY OVERVIEW- ALADDIN COMMERCIAL OVERVIEW - (BUILDER/MULTI-FAMILY SECTION)**********
        ap.B_GOpp_ACT__c = apSetting.
        ap.B_Yellow_Opportunity_Aladdin_Comm_Total__c = apSetting.
        ap.B_ROpp_ACT__c = apSetting.
        **********PRODUCT CATEGORY OVERVIEW- ALADDIN COMMERCIAL OVERVIEW - (BUILDER/MULTI-FAMILY SECTION)**********/
    }
    
    public static void mohawkLevelCalculation( Account_Profile__c ap ){
        try{
        if(ap!=null ){ //Added null check by Susmitha while writing test class

        /*//CHannel Level
        ap.R_EWP_Total__c = ap.R_EWP_Car__c + ap.R_EWP_Cus__c + ap.R_EWP_Lam__c + ap.R_EWP_T__c + ap.R_EWP_R__c + ap.R_EWP_Har__c + ap.R_EWP_ACT__c ;          
        ap.B_EWP_Total__c = ap.B_EWP_Car__c + ap.B_EWP_Cus__c + ap.B_EWP_Lam__c + ap.B_EWP_T__c + ap.B_EWP_R__c + ap.B_EWP_Har__c + ap.B_EWP_ACT__c;
        //CHannel Level
        //Mohawk Level  
        ap.ERS_Total__c = ap.R_ERS_Total__c + ap.B_ERS_Total__c;
        ap.EWP_Total__c = ap.R_EWP_Total__c + ap.B_EWP_Total__c;
        ap.AMP_Total__c = ap.R_Actual_Mohawk_Purchases_Total__c + ap.B_Actual_Mohawk_Purchases_Total__c;
        ap.Current_Mohawk_Share_Total__c = ap.EWP_Total__c > 0 ? ( ap.AMP_Total__c / ap.EWP_Total__c ) * 100 : 0;
        //Mohawk Level  
        */
        if( ap.Retail_Channel_Split__c > 0 ){
            //CHannel Level
            ap.R_EWP_Total__c = ap.R_EWP_Car__c + ap.R_EWP_Cus__c + ap.R_EWP_Lam__c + ap.R_EWP_T__c + ap.R_EWP_R__c + ap.R_EWP_Har__c; // Bug-59401 + ap.R_EWP_ACT__c ;
        }else{
            ap.R_EWP_Total__c = 0;
        }
        if(ap.Builder_Multi_Channel_split__c > 0 ){
            ap.B_EWP_Total__c = ap.B_EWP_Car__c + ap.B_EWP_Cus__c + ap.B_EWP_Lam__c + ap.B_EWP_T__c + ap.B_EWP_R__c + ap.B_EWP_Har__c; // Bug-59401 + ap.B_EWP_ACT__c;
        }else{
            ap.B_EWP_Total__c = 0;
        }
        //Mohawk Level  
        ap.ERS_Total__c = ap.R_ERS_Total__c + ap.B_ERS_Total__c;
        ap.EWP_Total__c = ap.R_EWP_Total__c + ap.B_EWP_Total__c;
        ap.AMP_Total__c = ap.R_Actual_Mohawk_Purchases_Total__c + ap.B_Actual_Mohawk_Purchases_Total__c;
        ap.Current_Mohawk_Share_Total__c = ap.EWP_Total__c > 0 ? ( ap.AMP_Total__c / ap.EWP_Total__c ) * 100 : 0;
        //Mohawk Level  
    }
        }
        catch(exception e){
            system.debug('Error e'+e);
        }
    }
    public static void DistributionPercentage( Account_Profile__c ap,Account_Profile_Settings__c apSetting ){
        if( ap.Retail_Channel_Split__c > 0 ){
            //Product Level - Retail        
            ap.R_Distribution_Carpet__c = ap.Product_Category_Allocation_Carpet__c;
            ap.R_Distribution_Cushion__c = ap.Product_Category_Allocation_Cushion__c;
            ap.R_Distribution_Hardwood__c = ap.Product_Category_Allocation_Wood__c;
            ap.R_Distribution_Laminate__c = ap.Product_Category_Allocation_Laminate__c;
            ap.R_Distribution_Tile__c = ap.Product_Category_Allocation_Tile__c;
            ap.R_Distribution_Resilient__c = ap.Product_Category_Allocation_Resilient__c;
            ap.R_Distribution_Aladdin_Comm_Total__c = ( (ap.R_EWP_ACT__c != null ? ap.R_EWP_ACT__c : 0) / (ap.R_EWP_Total__c != null ? ap.R_EWP_Total__c : 0) )*100;
            //Brand Level
            ap.R_Distribution_Aladdin__c = (ap.No_Karastan__c ? apSetting.No_Karastan_Aladdin_Carpet__c :apSetting.Estimated_Purchase_Aladdin_Carpet__c);
            ap.R_Distribution_Horizon__c = (ap.No_Karastan__c ? apSetting.No_Karastan_Horizon_Carpet__c :apSetting.Estimated_Purchase_Horizon_Carpet__c);
            ap.R_Distribution_Karastan__c = (ap.No_Karastan__c ? apSetting.No_Karastan_Karastan_Carpet__c :apSetting.Estimated_Purchase_Karastan_Carpet__c);
            ap.R_Distribution_Aladdin_Comm__c = apSetting.Estimated_Purchase_Aladdin_Com_Car__c;
            
            ap.R_Distribution_Resilient_Retail__c = apSetting.Resilient_Retail_Hard_TM2_New__c;
            ap.R_Distribution_Resilient_Comm__c = apSetting.Resilient_Mainstreet_Commercial_TM2_New__c;
        }else
        {
            ap.R_Distribution_Carpet__c = 0;
            ap.R_Distribution_Cushion__c = 0;
            ap.R_Distribution_Hardwood__c = 0;
            ap.R_Distribution_Laminate__c = 0;
            ap.R_Distribution_Tile__c = 0;
            ap.R_Distribution_Resilient__c = 0;
            ap.R_Distribution_Aladdin_Comm_Total__c = 0;
            //Brand Level
            ap.R_Distribution_Aladdin__c = 0;
            ap.R_Distribution_Horizon__c = 0;
            ap.R_Distribution_Karastan__c = 0;
            ap.R_Distribution_Aladdin_Comm__c = 0;
            
            ap.R_Distribution_Resilient_Retail__c = 0;
            ap.R_Distribution_Resilient_Comm__c = 0;
        }
        
        if(ap.Builder_Multi_Channel_split__c >0)
        {
            //Product Level - Builder/MultiFamily
            ap.B_Distribution_Carpet__c = ap.Product_Category_Allocation_Carpet__c;
            ap.B_Distribution_Cushion__c = ap.Product_Category_Allocation_Cushion__c;
            ap.B_Distribution_Hardwood__c = ap.Product_Category_Allocation_Wood__c;
            ap.B_Distribution_Laminate__c = ap.Product_Category_Allocation_Laminate__c;
            ap.B_Distribution_Tile__c = ap.Product_Category_Allocation_Tile__c;
            ap.B_Distribution_Resilient__c = ap.Product_Category_Allocation_Resilient__c;
            ap.B_Distribution_Aladdin_Comm_Total__c = ( (ap.B_EWP_ACT__c != null ? ap.B_EWP_ACT__c : 0) / (ap.B_EWP_Total__c != null ? ap.B_EWP_Total__c : 0) )*100;
            //Brand Level
            ap.B_Distribution_Aladdin__c = (ap.No_Karastan__c ? apSetting.No_Karastan_Aladdin_Carpet__c :apSetting.Estimated_Purchase_Aladdin_Carpet__c);
            ap.B_Distribution_Horizon__c = (ap.No_Karastan__c ? apSetting.No_Karastan_Horizon_Carpet__c :apSetting.Estimated_Purchase_Horizon_Carpet__c);
            ap.B_Distribution_Karastan__c = (ap.No_Karastan__c ? apSetting.No_Karastan_Karastan_Carpet__c :apSetting.Estimated_Purchase_Karastan_Carpet__c);
            ap.B_Distribution_Aladdin_Comm__c = apSetting.Estimated_Purchase_Aladdin_Com_Car__c;
            
            //ap.B_Distribution_Resilient_Retail__c = apSetting.Resilient_Mainstreet_Commercial_TM2_New__c;
            ap.B_Distribution_Resilient_Comm__c = apSetting.Resilient_Mainstreet_Commercial_TM2_New__c;
        }
        else
        {
            //Product Level - Builder/MultiFamily
            ap.B_Distribution_Carpet__c = 0;
            ap.B_Distribution_Cushion__c = 0;
            ap.B_Distribution_Hardwood__c = 0;
            ap.B_Distribution_Laminate__c = 0;
            ap.B_Distribution_Tile__c = 0;
            ap.B_Distribution_Resilient__c = 0;
            ap.B_Distribution_Aladdin_Comm_Total__c = 0;
            //Brand Level
            ap.B_Distribution_Aladdin__c = 0;
            ap.B_Distribution_Horizon__c = 0;
            ap.B_Distribution_Karastan__c = 0;
            ap.B_Distribution_Aladdin_Comm__c = 0;
            
            //ap.B_Distribution_Resilient_Retail__c = 0;
            ap.B_Distribution_Resilient_Comm__c = 0;
        }
    }
    
    
    
    //NEED TO MODIFy THIS
    public static Map<Id, Account_Profile_Settings__c> getAccountSetting( List<Account_Profile__c> newAccountProfileList ){
            Map<Id, Account_Profile_Settings__c> accProfileIdAndSettingMap = new Map<Id, Account_Profile_Settings__c>(); 
            Set<Id> idAccSettingSet = new Set<Id>();
            for(Account_Profile__c accProfile :newAccountProfileList){
                if(accProfile.Primary_Business__c != null){
                    idAccSettingSet.add(accProfile.Primary_Business__c);
                }
            }
     
            for( Account_Profile_Settings__c ap : [
                    SELECT  Builder_Multi_Family_1_Channel_Split__c,
                            Retail_1_channel_split__c,
                            Retail_Multi_channel_split__c,
                            Builder_Multi_Family_Multi_Channel_Split__c,
                            Multi_Family_Business_Split_1team__c,
                            Multi_Family_Business_Split_2Team__c,   
                            Retail_Business_Split_1Team__c,
                            Retail_Business_Split_2Team__c, 
                            Builder_Business_Split_1Team__c,
                            Builder_Business_Split_2_Team__c,           
                            Distribution_Resilient__c,
                            Distribution_Tile__c,
                            Distribution_Hardwood__c,
                            Distribution_Laminate__c,
                            Distribution_Cushion__c,
                            Retail_Sales_Hardwood__c,
                            Retail_Sales_Laminate__c,
                            Retail_Sales_Cushion__c,
                            Retail_Sales_Resilient__c,
                            No_Karastan_Karastan_Carpet__c,
                            Estimated_Purchase_Karastan_Carpet__c,
                            Estimated_Purchase_Horizon_Carpet__c,
                            No_Karastan_Horizon_Carpet__c,
                            Estimated_Purchase_Aladdin_Carpet__c,
                            No_Karastan_Aladdin_Carpet__c,
                            Retail_Sales_Carpet__c,
                            Retail_Sales_Tile__c,
                            Distribution_Carpet__c,
                            Yellow_Threshold_Carpet__c,
                            Yellow_Threshold_Tile__c,
                            Yellow_Threshold_Laminate__c,
                            Yellow_Threshold_Hardwood__c,
                            Yellow_Threshold_Cushion__c,
                            Yellow_Threshold_Resilient__c,
                            Yellow_Threshold_Mainstreet__c,
                            Red_Threshold_Carpet__c,
                            Red_Threshold_Tile__c,
                            Red_Threshold_Laminate__c,
                            Red_Threshold_Hardwood__c,
                Red_Threshold_Cushion__c,
                Red_Threshold_Mainstreet__c,
                Red_Threshold_Resilient__c,
                Resilient_Retail_Hard_TM2_New__c,
                Resilient_Mainstreet_Commercial_TM2_New__c,
                Estimated_Purchase_Aladdin_Com_Car__c
                    FROM    Account_Profile_Settings__c
                    WHERE   Id IN:idAccSettingSet]){
                
                  ap.Distribution_Carpet__c = ap.Distribution_Carpet__c != null ? ap.Distribution_Carpet__c :0;
                  ap.Distribution_Cushion__c = ap.Distribution_Cushion__c != null ? ap.Distribution_Cushion__c :0;
                  ap.Distribution_Hardwood__c = ap.Distribution_Hardwood__c != null ? ap.Distribution_Hardwood__c :0;
                  ap.Distribution_Laminate__c = ap.Distribution_Laminate__c != null ? ap.Distribution_Laminate__c :0;
                  ap.Distribution_Mainstreet__c = ap.Distribution_Mainstreet__c != null ? ap.Distribution_Mainstreet__c :0;
                  ap.Distribution_Resilient__c = ap.Distribution_Resilient__c != null ? ap.Distribution_Resilient__c :0;
                  ap.Distribution_Tile__c = ap.Distribution_Tile__c != null ? ap.Distribution_Tile__c :0;
                  ap.Estimated_Purchase_Aladdin_Carpet__c = ap.Estimated_Purchase_Aladdin_Carpet__c != null ? ap.Estimated_Purchase_Aladdin_Carpet__c :0;
                  ap.Estimated_Purchase_Horizon_Carpet__c = ap.Estimated_Purchase_Horizon_Carpet__c != null ? ap.Estimated_Purchase_Horizon_Carpet__c :0;
                  ap.Estimated_Purchase_Karastan_Carpet__c = ap.Estimated_Purchase_Karastan_Carpet__c != null ? ap.Estimated_Purchase_Karastan_Carpet__c :0;
                  ap.Multi_Family_Business_Split_1team__c = ap.Multi_Family_Business_Split_1team__c != null ? ap.Multi_Family_Business_Split_1team__c :0;
                  ap.Multi_Family_Business_Split_2Team__c = ap.Multi_Family_Business_Split_2Team__c != null ? ap.Multi_Family_Business_Split_2Team__c :0;
                  ap.No_Karastan_Aladdin_Carpet__c = ap.No_Karastan_Aladdin_Carpet__c != null ? ap.No_Karastan_Aladdin_Carpet__c :0;
                  ap.No_Karastan_Horizon_Carpet__c = ap.No_Karastan_Horizon_Carpet__c != null ? ap.No_Karastan_Horizon_Carpet__c :0;
                  ap.No_Karastan_Karastan_Carpet__c = ap.No_Karastan_Karastan_Carpet__c != null ? ap.No_Karastan_Karastan_Carpet__c :0;
                  ap.Red_Threshold_Carpet__c = ap.Red_Threshold_Carpet__c != null ? ap.Red_Threshold_Carpet__c :0;
                  ap.Red_Threshold_Cushion__c = ap.Red_Threshold_Cushion__c != null ? ap.Red_Threshold_Cushion__c :0;
                  ap.Red_Threshold_Hardwood__c = ap.Red_Threshold_Hardwood__c != null ? ap.Red_Threshold_Hardwood__c :0;
                  ap.Red_Threshold_Laminate__c = ap.Red_Threshold_Laminate__c != null ? ap.Red_Threshold_Laminate__c :0;
                  ap.Red_Threshold_Resilient__c = ap.Red_Threshold_Resilient__c != null ? ap.Red_Threshold_Resilient__c :0;
                  ap.Red_Threshold_Tile__c = ap.Red_Threshold_Tile__c != null ? ap.Red_Threshold_Tile__c :0;            
                  ap.Retail_Sales_Carpet__c = ap.Retail_Sales_Carpet__c != null ? ap.Retail_Sales_Carpet__c :0;
                  ap.Retail_Sales_Cushion__c = ap.Retail_Sales_Cushion__c != null ? ap.Retail_Sales_Cushion__c :0;
                  ap.Retail_Sales_Hardwood__c = ap.Retail_Sales_Hardwood__c != null ? ap.Retail_Sales_Hardwood__c :0;
                  ap.Retail_Sales_Laminate__c = ap.Retail_Sales_Laminate__c != null ? ap.Retail_Sales_Laminate__c :0;
                  ap.Retail_Sales_Resilient__c = ap.Retail_Sales_Resilient__c != null ? ap.Retail_Sales_Resilient__c :0;
                  ap.Retail_Sales_Tile__c = ap.Retail_Sales_Tile__c != null ? ap.Retail_Sales_Tile__c :0;
                  ap.Yellow_Threshold_Carpet__c = ap.Yellow_Threshold_Carpet__c != null ? ap.Yellow_Threshold_Carpet__c :0;
                  ap.Yellow_Threshold_Cushion__c = ap.Yellow_Threshold_Cushion__c != null ? ap.Yellow_Threshold_Cushion__c :0;
                  ap.Yellow_Threshold_Hardwood__c = ap.Yellow_Threshold_Hardwood__c != null ? ap.Yellow_Threshold_Hardwood__c :0;
                  ap.Yellow_Threshold_Laminate__c = ap.Yellow_Threshold_Laminate__c != null ? ap.Yellow_Threshold_Laminate__c :0;
                  ap.Yellow_Threshold_Resilient__c = ap.Yellow_Threshold_Resilient__c != null ? ap.Yellow_Threshold_Resilient__c :0;
                  ap.Yellow_Threshold_Tile__c = ap.Yellow_Threshold_Tile__c != null ? ap.Yellow_Threshold_Tile__c :0;
                  ap.Yellow_Threshold_Mainstreet__c =  ap.Yellow_Threshold_Mainstreet__c != null ? ap.Yellow_Threshold_Mainstreet__c :0;
                  ap.Retail_Business_Split_1Team__c = ap.Retail_Business_Split_1Team__c != null ? ap.Retail_Business_Split_1Team__c :0;
                  ap.Retail_Business_Split_2Team__c = ap.Retail_Business_Split_2Team__c != null ? ap.Retail_Business_Split_2Team__c :0;
                  ap.Builder_Business_Split_1Team__c = ap.Builder_Business_Split_1Team__c != null ? ap.Builder_Business_Split_1Team__c :0;
                  ap.Builder_Business_Split_2_Team__c = ap.Builder_Business_Split_2_Team__c != null ? ap.Builder_Business_Split_2_Team__c :0;
                  accProfileIdAndSettingMap.put(ap.Id, ap);
            }
                  
            return accProfileIdAndSettingMap;
    }
}
