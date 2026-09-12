import { LightningElement } from 'lwc';

export default class Max_Contact_Card extends LightningElement {
    firstname = "Sales";
    lastname = "force";
    email = "salesforce@abc.com";
    phone = "1234567897";
    showDetails = false;
    handleChange(event) {
        this.showDetails = event.target.checked;
    }
}