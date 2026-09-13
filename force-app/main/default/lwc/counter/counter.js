import { LightningElement } from 'lwc';
export default class Counter extends LightningElement {
    count = 0;

    increment(){
        this.count++;
    }

    decrement(){
       this.count--;
    }

    result(){
        this.count =0;
    }
}