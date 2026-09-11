import { LightningElement, api, wire } from 'lwc';
import getOwnerPermissionSets from '@salesforce/apex/almond_Utility.getOwnerPermissionSets';

const columns = [
    //{ label: 'Permission Set Name', fieldName: 'name' },
    { label: 'Permission Set Name', fieldName: 'label' },
];


export default class Almond_showUserPerSet extends LightningElement {
    @api recordId;
    columns = columns;
    data;
    error;
    perSetCount = 0;

    @wire(getOwnerPermissionSets, { recordId: '$recordId' })
    wiredPermSets({ error, data }) {
        if (data) {
            this.data = data;
            this.perSetCount = data.length > 0 ? data[0].pscount : 0;
            this.error = undefined;
        } else if (error) {
            this.error = error;
            this.data = undefined;
        }
    }
    get hasPermissionSets() {
        return this.perSetCount > 0;
    }
}