import { LightningElement } from 'lwc';

export default class Max_Conditional_Rendering extends LightningElement {
    showContent = false;
    handleChange(event){
        this.showContent = event.target.checked;
    }
}