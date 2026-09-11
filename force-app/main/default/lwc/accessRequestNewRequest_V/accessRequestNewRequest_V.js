import { LightningElement, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

export default class AccessRequestNewRequest_V extends NavigationMixin(LightningElement) {

    @track step = 1;
    requestType;
    selectedAction;

    requestOptions = [
        { label: 'Self', value: 'self' },
        { label: 'For Other', value: 'other' }
    ];

    get isStepOne() { return this.step === 1; }
    get isStepTwo() { return this.step === 2; }
    get isStepThree() { return this.step === 3; }
    get isNextDisabled() { return !this.requestType; }

    get actionOptions() {
        return this.requestType === 'self'
            ? [
                { label: 'Add Permission Set', value: 'add_ps' },
                { label: 'Change Profile', value: 'change_profile' },
                { label: 'Remove Permission Set', value: 'remove_ps' }
            ]
            : [
                { label: 'Add Permission Set', value: 'add_ps' },
                { label: 'Apply for Profile', value: 'apply_profile' },
                { label: 'Remove Permission Set', value: 'remove_ps' }
            ];
    }

    handleTypeChange(e) { this.requestType = e.detail.value; }
    handleActionChange(e) { this.selectedAction = e.detail.value; }
    goToStepTwo() { this.step = 2; }
    goBack() {
        if (this.step === 2) {
            this.step = 1;
        } 
        else if (this.step === 3) {
            this.step = 2;
        }
    }

    closeModal() {
        // closes the override page
        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName: 'Access_Request_J__c',
                actionName: 'list'
            },
            state: {
            filterName: '__Recent'
        }
        });
    }

    handleContinue() {
        console.log('Proceeding...');
        if (!this.selectedAction) {
            return;
        }
        this.step = 3;
    }
}