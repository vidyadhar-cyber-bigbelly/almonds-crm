import { LightningElement, api, wire } from 'lwc';
import accountManagerCheck from '@salesforce/apex/AccountController.accountManagerCheck';
import warningMessage from '@salesforce/label/c.ALMD_Account_Manager_error';
export default class Almond_NonAmAccountOwner extends LightningElement {
    @api recordId;
    showWarning = false; 
    error;
    bannerMessage = warningMessage;

    @wire(accountManagerCheck, {accountId: '$recordId'})
    wirePScheck({error,data}){
        if (data !== undefined){
            this.showWarning = !data;
            this.error = undefined;
        }
        else if(error){
            this.error = error;
            this.showWarning = false;
            console.log(error);
        }
    }

}