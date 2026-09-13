import { LightningElement } from 'lwc';
export default class Lwc_nine_CTP_child extends LightningElement {

    // DOM event handler
    // property -> customEve: it will store the entire event 
    // demo: custom event name; It should be in lowercase, No spaces allowed, Should not start with keyword 'on'.
    // msg: user-defined variable
    handleClick() {
        const customEve = new CustomEvent('demo', {
            detail: {
                msg: 'Welcome to LWC!'
            }
        })
        this.dispatchEvent(customEve); 
    }
}