import { LightningElement } from 'lwc';
export default class Lwc_fifteen_InvokeFlow extends LightningElement {

    // Properties
    flowVariables;
    showFlowOutput = false;
    userEnteredFirstName;
    userEnteredLastName;

    // Event Handler
    // we will fetch the input values after button click
    // called upon 'save' button click.
    // it will fetch the values from text-box's
    // fetch the values present at input-box's
    // this: current component
    // template: DOM/HTML
    // querySelector: search/finds the element having particular data-name
    // value: gives data present at input box
    handleClick() {
        // fetch the user entered name values from DOM page
        this.userEnteredFirstName = this.template.querySelector('lightning-input[data-name="fname"]').value;
        this.userEnteredLastName = this.template.querySelector('lightning-input[data-name="lname"]').value;
        // pass this values to flow resource variables
        this.flowVariables = [
            {
                name: 'firstName',
                type: 'String',
                value: this.userEnteredFirstName
            },
            {
                name: 'lastName',
                type: 'String',
                value: this.userEnteredLastName
            }
        ];
        // make 'showFlowOutput=true' to show the flow output, upon button click
        this.showFlowOutput = true;
    }
    // called after we click on the 'finish' button, means from running flow to finish, upon status change
    // hide flow output, and make input box's empty.
    // Flow Status: FINISHED, PAUSED, STARTED, ERROR
    // from the 'onstatuschange' event we will fetch the 'status' details, to confirm wheather it is 'FINISHED' or not.
    handleStatusChange(event) {
        if (event.detail.status == 'FINISHED') {
            // make input boxes empty
            this.userEnteredFirstName = this.template.querySelector('lightning-input[data-name="fname"]').value = '';
            this.userEnteredLastName = this.template.querySelector('lightning-input[data-name="lname"]').value = '';
            // hide the flow output
            this.showFlowOutput = false;
        }
    }
}