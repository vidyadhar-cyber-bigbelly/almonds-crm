import { LightningElement } from 'lwc';

export default class Max_Grand_Parent extends LightningElement {
    constructor(){
        super();
        console.log("Grand parent Constructor");
    }
    connectedCallback(){
        console.log("Grand parent ConnectedCallback");
    }
    renderedCallback(){
        console.log("Grand Parent RenderedCalback");
    }
}