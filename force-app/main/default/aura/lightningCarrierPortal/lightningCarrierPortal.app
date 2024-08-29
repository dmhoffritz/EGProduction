<aura:application extends="ltng:outApp" access="global" implements="ltng:allowGuestAccess">
    <!-- Portal Bundle -->
    <aura:dependency resource="markup://c:onsave" type="EVENT" />
    <aura:dependency resource="markup://c:flowFinished" type="EVENT" />
    <aura:dependency resource="markup://c:deselectMenu" type="EVENT" />
    <aura:dependency resource="markup://c:navLoad" type="EVENT" />
    
    <aura:dependency resource="c:embeddedFlow"/>
    <aura:dependency resource="c:Carrier_Home_App"/>
    <aura:dependency resource="c:CarrierMenu"/>
    <aura:dependency resource="c:MyProfile_App"/>
    <aura:dependency resource="c:CarrierCompanyProfile_App"/>
    <aura:dependency resource="c:Carrier_Registration_App"/>
    <aura:dependency resource="c:LoadDetail"/>
    <aura:dependency resource="c:Carrier_Home"/>
    <aura:dependency resource="c:recordFileList"/>
    <aura:dependency resource="c:fileUpload"/>
    <aura:dependency resource="c:batchDataTable"/>
    <aura:dependency resource="c:carrierSearchBar"/>
    <aura:dependency resource="c:carrierChat"/>
    <aura:dependency resource="c:lanePicker" />

    <!-- Registration Bundle -->
    <aura:dependency resource="markup://c:navRegistration" type="EVENT" />
    <aura:dependency resource="markup://c:checkboxChange" type="EVENT" />
    <aura:dependency resource="c:CarrierRegistration" />
    <aura:dependency resource="c:FactoringRegistration" />
    <aura:dependency resource="c:termsModal" />
    
</aura:application>