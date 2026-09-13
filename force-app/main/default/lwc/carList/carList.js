import { LightningElement } from 'lwc';
export default class CarList extends LightningElement {
    cars = [
        { id: 1, brand: 'Toyota', model: 'Camry', price: 2500000},
        { id: 2, brand: 'Honda', model: 'Civic', price: 2200000},
        { id: 3, brand:'Ford', model: 'Mustang', price: 3500000}
    ];

    get totalCars(){
        return this.cars.length;
    } 

}