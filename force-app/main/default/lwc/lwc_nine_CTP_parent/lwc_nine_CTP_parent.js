import { LightningElement } from 'lwc';
export default class Lwc_nine_CTP_parent extends LightningElement {

    // custom event handler
    // 'event' is user-defined parameter which stores the entire event, event=customEve(defined in child JS)
    handleDemo(event){
        alert(event.detail.msg);   // 'Welcome to LWC!'
    }
}