import { LightningElement } from 'lwc';

export default class Max_Data_Binding_Dynamically extends LightningElement {
    my_Value = "Sreekanth";
    handleChange(event){
        this.my_Value = event.target.value;
    }
}