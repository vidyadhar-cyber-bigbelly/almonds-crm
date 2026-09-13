import { LightningElement } from 'lwc';
export default class Lwc_one_DisplayMessage extends LightningElement {

    // Properties -> variables
    message='Good Morning';

    // Event Handlers -> methods
    handleClick(){
        alert('Welcome to LWC');
    }
}