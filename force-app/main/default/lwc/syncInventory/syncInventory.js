import { LightningElement } from 'lwc';
import syncInventory from '@salesforce/apex/inventorySyncController.syncInventory';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
export default class InventorySync extends LightningElement {
    isLoading = false;
    handleSync() {
        this.isLoading = true;
        syncInventory()
            .then(result => {
                this.showToast(
                    'Sync Successful',
                    result,
                    'success'
                );
                setTimeout(() => {this.navigateToAllInventory();},5000); //adding some delay
                //this.navigateToAllInventory();

            })
            .catch(error => {
                console.log(error);

                this.showToast(
                    'Sync Failed',
                    error?.body?.message ||
                    'Inventory sync failed.',
                    'error'
                );

            })
            .finally(() => {

                this.isLoading = false;
            });
    }/*
    navigateToAllInventory() {

        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName: 'Inventory__c',
                actionName: 'list'
            },
            state: {
                filterName: 'All'
            }
        });
    }*/
    navigateToAllInventory() {

        window.location.assign(
            '/lightning/o/Inventory__c/list?filterName=All'
        );

    }
    showToast(title, message, variant) {
        this.dispatchEvent(
            new ShowToastEvent({
                title,
                message,
                variant
            })
        );
    }
}