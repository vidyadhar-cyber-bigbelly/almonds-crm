import { LightningElement } from 'lwc';
export default class Lwc_two_SimpleCalculator extends LightningElement {

    //  ***  Properties

    userEnteredFirstNum;  // to store value present at 'First Number' text box
    userEnteredSecondNum;  // to store value present at 'Second Number' text box
    res;  // to store the result
    showRedColouredBadge = false;   // by default red-coloured badge wont be visible in the UI

    // use above variables in the remaining code with '.this' => 'this' it indicates current component instance, so the variables will be accessible in below whole code, also in HTML too.

    // *** Event Handlers

    // onchange: occures when value changes in the particular text-box
    // we must fetch the user entered value from DOM page
    // whenever we fetch value from DOM page, we must add parameter(name can be anything), for ex: event 
    // event.target.value => returns the value in String format, and for calculation, we need 'Number', so typecasting.
    // event: it stores the 'onchange' event details .
    // target: where the event has occured, at 'Text-Box'
    // value: value present at target(text-box)
    handleFirstNum(event){
        this.userEnteredFirstNum = Number(event.target.value);
    }
    handleSecondNum(event){
        this.userEnteredSecondNum = Number(event.target.value);
    } 

    // onclick: occures when the particular button is clicked
    // display the red coloured badge, when result is shown -> result will be shown, upon button clicked
    handleAdd(){
        this.showRedColouredBadge=true;
        this.res = this.userEnteredFirstNum + this.userEnteredSecondNum;
    } 
    handleSub(){
        this.showRedColouredBadge=true;
        this.res = this.userEnteredFirstNum - this.userEnteredSecondNum;
    } 
    handleMul(){
        this.showRedColouredBadge=true;
        this.res = this.userEnteredFirstNum * this.userEnteredSecondNum;
    } 
    handleDiv(){
        this.showRedColouredBadge=true;
        this.res = this.userEnteredFirstNum / this.userEnteredSecondNum;
    }
}