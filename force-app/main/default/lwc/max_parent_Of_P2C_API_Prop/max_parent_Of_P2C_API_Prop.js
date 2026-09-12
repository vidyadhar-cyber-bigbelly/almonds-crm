import { LightningElement } from 'lwc';

export default class Max_parent_Of_P2C_API_Prop extends LightningElement {
    percentage =20;
    handleOnChange(event) {
        this.percentage = event.target.value;
    }
}