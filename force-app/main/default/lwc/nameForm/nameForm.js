import { LightningElement } from 'lwc';
export default class NameForm extends LightningElement {
    userName = '';
    message = '';

    handleInput(event){
        this.userName = event.target.value;
    }

    handleSubmit(){
        if(this.userName.trim()){
            this.message = 'welcome, ' + this.userName + '!';
        }
        else{
            this.message = 'please enter your name.';
        }
    }
}