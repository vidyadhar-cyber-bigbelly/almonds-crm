import { LightningElement } from 'lwc';
export default class Lwc_sixteen_lifecycleHooks extends LightningElement {
    // local property
    counter=0;

    // Lifecycle Hooks -> called automatically based on the component's state
    constructor() {
        super();
        console.log('I am Constructor');
    }
    connectedCallback() {
        console.log('I am connectedCallback');
    }
    renderedCallback(){
        console.log('I am renderedCallback');
    }
    disconnectedCallback() {
        console.log('I am disconnectedCallback');
    }
    errorCallback(error, stack) {
        console.log('I am errorcallback');
    }

    // Event Handler -> called upon action performed(ex: button clicked)
    handleClick(){
        this.counter = this.counter + 1;
    }
}

/*

LIFECYCLE HOOKS 

Like a timeline of component's life -> from the moment the component is created in the broswer memory, till it gets destroyed.

Below lifecycle hooks methods will run automatically based on the component's state:

1. constructor()
-> this is the very first thing that runs when your component is created, It is the birth of the component. 
-> Used to initialize local properties/variables, or set initial values
-> you must call 'super()' first, for the 'LightningElement' base class which we are extending.
-> you cannot access the components UI attributes like, @api, @wire

2. connectedCallback()
-> this will be called when component is inserted into the DOM, to tell that component is now 'Live' on the page
-> Used to fetch data from apex or any external api's, with subscriber
-> we can access the @wire, @api, now component is ready to use

3. renderedCallback()
-> it will be called/renederd first time, when component in loaded/inserted into DOM
-> it will re-render/re-called, every time when the data changes and UI updates 
-> used when showing charts/graphs using JS libraries, where did will varry
-> use it carefully, it may cause infinite looping

4. disconnectedCallback()
-> this will be called when component is removed from the DOM
-> used for cleanup purpose

5. errorcallback(error,stack)
-> defined in parent
-> called when any unhandled error occures in any of its child component
-> error: JS native error object, stack:  string which give stack trace
-> use this for error logging, display message

// Parent-Child 
I am constructor
I am connectedCallback
I am child constructor
I am child connectedCallback
I am child renderedCallback
I am renderedCallback

// Error at child constructor:
I am Constructor
I am connectedCallback
I am Child Constructor
I am errorcallback
I am renderedCallback

// parent - child
I am disconnectedCallback
I am Child disconnectedCallback

*/