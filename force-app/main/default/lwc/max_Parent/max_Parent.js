import { LightningElement } from 'lwc';

export default class Max_Parent extends LightningElement {
    constructor(){
        super();
        console.log("Parent Constructor");
    }
    connectedCallback(){
        console.log("Parent ConnectedCallback");
    }
    renderedCallback(){
        console.log("Parent RenderedCallback");
    }
}