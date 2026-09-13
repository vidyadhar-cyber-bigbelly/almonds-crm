import { LightningElement } from 'lwc';
export default class Lwc_ten_grandparent extends LightningElement {

    // property
    res;

    // event handler
    handleGrandDemo(event){
        this.res = event.detail.message; // res='Hello'
    }
}