import { LightningElement, api, wire } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import STATUS_FIELD from '@salesforce/schema/Lead.Status';

export default class LeadStatusBanner extends LightningElement {
    @api recordId;
    status;

    @wire(getRecord, { recordId: '$recordId', fields: [STATUS_FIELD] })
    wiredLead({ error, data }) {
        if (data) {
            this.status = data.fields.Status.value;
        }
    }

    get isOnHold() {
        return this.status === 'On Hold';
    }

    get isDisqualified() {
        return this.status === 'Disqualified';
    }
}