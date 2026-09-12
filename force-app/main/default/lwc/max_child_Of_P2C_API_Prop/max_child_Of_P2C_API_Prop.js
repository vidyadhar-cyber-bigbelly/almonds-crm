import { LightningElement,api } from 'lwc';

export default class Max_child_Of_P2C_API_Prop extends LightningElement {
    @api percentage;
    get style(){
        return `background-color:red; min-height:10px; width:${this.percentage}%; min-width:20px; border: 1px solid black;`
    }
}