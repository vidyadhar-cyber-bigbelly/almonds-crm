import { LightningElement,api,wire } from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';

import ACCOUNT_ACTIVE_FIELD from '@salesforce/schema/Account.Active__c'; 
import OWNER_ACTIVE_FIELD from '@salesforce/schema/Account.Owner.IsActive';
import OWNER_NAME_FIELD from '@salesforce/schema/Account.Owner.Name';

const FIELDS = [ACCOUNT_ACTIVE_FIELD, OWNER_ACTIVE_FIELD, OWNER_NAME_FIELD];

export default class Almond_accountOwnerInactiveOrAccountInactive extends LightningElement {
    @api recordId;

    @wire(getRecord, { recordId: '$recordId', fields: FIELDS })
    account;

    get showAlert(){
        if (!this.account.data) return false;

        const isAccountActive = getFieldValue(this.account.data, ACCOUNT_ACTIVE_FIELD);
        const isOwnerActive = getFieldValue(this.account.data, OWNER_ACTIVE_FIELD);

        return isAccountActive === false || isOwnerActive === false;
    }

    get bannerMessage() {
        if (!this.account.data) return '';

        const isAccountActive = getFieldValue(this.account.data, ACCOUNT_ACTIVE_FIELD);
        const isOwnerActive = getFieldValue(this.account.data, OWNER_ACTIVE_FIELD);
        const ownerName = getFieldValue(this.account.data, OWNER_NAME_FIELD);

        if (isAccountActive === false) {
            return 'Warning: This Account is marked as Inactive.';
        }
        
        else if (isOwnerActive === false) {
            return `Warning: The Owner of this account (${ownerName}) is currently inactive.`;
        }

        return '';
    }

}