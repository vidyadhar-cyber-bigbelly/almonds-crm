import { LightningElement } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import syncInventory from '@salesforce/apex/almd_PaIDashboardController.syncInventory';
import productSyncFromInventoryMnl from '@salesforce/apex/almd_PaIDashboardController.productSyncFromInventoryMnl';

export default class Almd_PaIDashboard extends LightningElement {
    isLoading = false;

    handleProductSync() {
        this.showToast('Initiated', 'Product and Inventory sync has started.', 'info');
        this.isLoading = true;

        productSyncFromInventoryMnl()
            .then(result =>{
                this.showToast('Sync Successful',result,'success');
                setTimeout(() => {this.navigateToAllProducts();},3000);
            })
            .catch(error => {
                console.log(error);

                this.showToast('Sync Failed', error?.body?.message || 'Product sync failed', 'error');
            })
            .finally(() => {
                this.isLoading = false;
            });

    }

    handleInventorySync() {
        this.showToast('Initiated', 'Inventory sync has started.', 'info');
        this.isLoading = true;
        syncInventory()
            .then(result => {
                this.showToast(
                    'Sync Successful',
                    result,
                    'success'
                );
                setTimeout(() => {this.navigateToAllInventory();},3000); //adding some delay
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
        
        //this.showToast('Initiated', 'Inventory sync has started.', 'info');
    }

    navigateToAllInventory() {

        window.location.assign(
            '/lightning/o/Inventory__c/list?filterName=All'
        );

    }

    navigateToAllProducts(){
        window.location.assign('/lightning/o/Product2/list?filterName=AllProducts');
    }

    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(event);
    }
}