import { LightningElement } from 'lwc';
export default class Lwc_ten_child extends LightningElement {

    // Event Handler
    handleClick(){
        const customEve = new CustomEvent('demo', {
            detail: {
                message: 'Hello'
            },
            bubbles: true,
            composed: true
        })
        this.dispatchEvent(customEve);
    }
}