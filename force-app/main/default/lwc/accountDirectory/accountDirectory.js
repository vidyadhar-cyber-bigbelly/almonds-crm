import { LightningElement } from 'lwc';
import getAccounts from '@salesforce/apex/AccountController.getAccounts';

export default class AccountDirectory extends LightningElement {
    
    isLoading = false;
    accounts = [];
    error;

    handleLoadAccounts(){
        this.isLoading = true;

        getAccounts()
            .then(result => {
                this.accounts = result;
                this.isLoading = false;
            })
            .catch(error => {
                console.log("Records id not fetch or some error to show users");
                this.isLoading = false;
            })
    }
}