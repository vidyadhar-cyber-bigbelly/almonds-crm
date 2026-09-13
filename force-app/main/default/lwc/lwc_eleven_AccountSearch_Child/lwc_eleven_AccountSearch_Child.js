import { LightningElement } from 'lwc';
export default class Lwc_eleven_AccountSearch_Child extends LightningElement {

    // Property
    // to display user searched value above the input-box 
    searchVal;

    // Event Handler
    // customEve: storing the custom event
    // 'demo': name of the custom event
    // message value we need to pass it to parent, in this case 'message' value should be user entered string from DOM page
    // to fetch from DOM page, we will add parameter, ex: event
    // to fetch from input box: event.target.value
    // event: onchange, target: text-box, value: data/value present at text-box
    handleChange(event){

        this.searchVal=event.target.value;

        const customEve = new CustomEvent('demo', {
            detail: {
                message: event.target.value
            }
        })
        this.dispatchEvent(customEve);
    }

}