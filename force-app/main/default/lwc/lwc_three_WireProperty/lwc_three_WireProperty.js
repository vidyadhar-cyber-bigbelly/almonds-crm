import { LightningElement, wire } from 'lwc';
// import the apex method to use
// getAllOpp: user-defined name, Apex Function which is alias for Apex method, we can use same name also to avoid confusion
import getAllOpp from '@salesforce/apex/OpportunityControllerClass.fetchAllOpp';
export default class Lwc_three_WireProperty extends LightningElement {

    // wire property
    // Synatax: @wire(ApexFunction) propertyName;
    // opportunityList -> type? -> object -> {data,error}
    @wire(getAllOpp) opportunityList;
}