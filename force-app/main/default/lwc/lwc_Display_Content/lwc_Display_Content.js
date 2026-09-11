import { LightningElement } from 'lwc';
export default class Lwc_Display_Content extends LightningElement {
    message = '';
    text='hello all';

    handleClick(){
        this.message='Hello1';
    }

    handleRemove(){
        this.message='';
    }

    handleClick1(){
        console.log('Clicked');
    }
}