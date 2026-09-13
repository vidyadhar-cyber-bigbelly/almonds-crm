import { LightningElement, wire } from 'lwc';
// import the apex method to use
// getAllOpp: user-defined name, Apex Function which is alias for Apex method, we can use same name also to avoid confusion
import getAllOpp from '@salesforce/apex/OpportunityControllerClass.fetchAllOpp';

export default class Lwc_four_WireMethod extends LightningElement {

    // wire property -> Syntax: @wire(ApexFunction) propertyName;
    // wire Method -> Syntax: @wire(ApexFunction) methodName(){ // logic };

    // properties
    resultList;  // to store the data
    errorMsg;  // to store the error

    // Wire Method
    // {data,error} -> single parameter -> object
    @wire(getAllOpp) displayOpp({data,error}){
        if(data){
            // WAY 1
            // this.resultList = data;   // works when we want to fetch the data from existing fields only
            
            // WAY 2    
            // But if, we want to add extra column('commission') in the UI, which is the 20% of amount (perform calculations)
            // we can use map or loop
            // LHS: field names from HTML -> it could be userdefined or api names, in this case we have used user-defined
            // RHS: field API names from apex, written with map/loop item variable
            // data: list of all the opportunities, res: one opportunity in each iteration
            this.resultList =  data.map(res => {
                return {
                    opportunityId : res.Id,
                    opportunityName : res.Name,
                    opportunityStageName : res.StageName,
                    opportunityCloseDate : res.CloseDate,
                    opportunityAmount : res.Amount,
                    opportunityCommission : res.Amount * 0.2
                };
            });
        }
        else if(error){
            this.errorMsg = error;
        }
    }
}