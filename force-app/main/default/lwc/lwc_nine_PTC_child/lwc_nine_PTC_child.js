import { LightningElement, api } from 'lwc';
export default class Lwc_nine_PTC_child extends LightningElement {

    // properties
    @api message1;
    @api message2;

    // message1; -> private property -> not accessible outside this component
    // @api message1; -> public property -> now accessible outside this component
    // @api + isExposed = false -> public property
    // @api + isExposed = true -> global property
}