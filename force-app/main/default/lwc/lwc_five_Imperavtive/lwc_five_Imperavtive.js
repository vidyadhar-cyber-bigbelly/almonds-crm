import { LightningElement } from 'lwc';
// import the apex method to use
// getAllOpp: user-defined name, Apex Function which is alias for Apex method, we can use same name also to avoid confusion
import getAllOpp from '@salesforce/apex/OpportunityControllerClass.fetchAllOpp';
import getWonOpp from '@salesforce/apex/OpportunityControllerClass.fetchWonOpp';
import getLostOpp from '@salesforce/apex/OpportunityControllerClass.fetchLostOpp';

export default class Lwc_five_Imperavtive extends LightningElement {

    // **** properties 
    // we are seggricating data and error at JS itself 
    resultList;  // to store the data
    errorMsg;  // to store the error

    // **** Event Handlers
    // .then: hold the data, .catch: hold the error
    // Imperative method must be called inside event handler or method, else it will show syntax error
    // Fetch All Opp, but event handler is not there, means we should call it automatically upon page load
    // way 1: wire property/method
    // way 2: lifecycle hook method -> connectedCallback() -> called automatically, everytime when page load/refresh occures
    connectedCallback() {
        getAllOpp()
            .then((result) => {
                this.resultList = result;
            }).catch((err) => {
                this.errorMsg = err;
            });
    }

    // call apex method 'fetchWonOpp' to fetch the 'Closed Won' Opportunities
    handleWonClick() {
        getWonOpp()
            .then((result) => {
                this.resultList = result;
            }).catch((err) => {
                this.errorMsg = err;
            });
    }

    // call apex method 'fetchLostOpp' to fetch the 'Closed Lost' Opportunities
    handleLostClick() {
        getLostOpp()
            .then((result) => {
                this.resultList = result;
            }).catch((err) => {
                this.errorMsg = err;
            });
    }
}