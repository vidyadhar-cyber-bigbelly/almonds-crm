import { LightningElement,wire } from 'lwc';
import records from '@salesforce/apex/test.getdata';
import getRegioanlData from '@salesforce/apex/test.getAllDeliveryConfig';
export default class Test extends LightningElement {
opp = [];
errorMessage ='';
wiredresult = [];
countryOptions;
regionalData=[];
@wire(records)
wiredData(result){
    this.wiredresult = result;
   const {data,error} = result;

    if(data){
        this.opp = data.map(opp=>({
            name : opp.Name,
            Id : opp.Id,
            closingdays : opp.days_remain_for_closing__c,
            selectedRegion: null,
            shipingConfig: null


        }));
    }
    else if(error){
       this. errorMessage = error.body.message;
    }-
     console.log('Opportunity',JSON.stringify(this.opp));
}

 get hasOpp(){
    return this.opp !=null && this.opp.length >0 ;
 }

 @wire(getRegioanlData)
    wiredRegionalData({data,error}){
    if(data){
        this.regionalData= data;
     this.countryOptions= data.map(c=>({
       value : c.DeveloperName,
       label : c.Country__c
     }));
    }
    else if(error){
        this.errorMessage = error.body.message;
    }
    
    

 }
handleChangeRegion(event){
       const region= event.detail.value;
       const oppId = event.target.dataset.id;
        console.log('Selected Id',oppId);
       
       const shipingDeatils =  this.regionalData.find(
        c => c.DeveloperName === region
       );
       this.opp = this.opp.map(o=> o.Id === oppId?
        {
            ...o,
            selectedRegion : region, 
            estimatedDays : shipingDeatils.Estimated_days__c,
            courier:shipingDeatils.Courier__c
            
        }:o
        );
         console.log('selected region ',JSON.stringify(this.opp));
    }




 
}