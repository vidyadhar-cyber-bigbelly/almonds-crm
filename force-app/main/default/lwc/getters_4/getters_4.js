import { LightningElement } from 'lwc';
export default class Getters_4 extends LightningElement {

    firstName = 'Jack';
    LastName = 'Sharma';

    get fullName(){
        return this.firstName + ' ' + this.LastName;
    }

    get greetings(){
        return 'welcome back ' + this.fullName + ' !';
    }

}