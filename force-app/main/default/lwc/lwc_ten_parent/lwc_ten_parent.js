import { LightningElement } from 'lwc';
export default class Lwc_ten_parent extends LightningElement {

    // Properties
    msg1;
    msg2;

    // Event Handlers
    // event = customEve 

    handleDemo(event){
        this.msg2 = event.detail.message; // msg2='Hello'
    }

    handleDiv(event){
        this.msg1 = event.detail.message; // msg1='Hello'
    }
}