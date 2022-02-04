import { LightningElement } from 'lwc';
export default class HelloWorld extends LightningElement {
  greeting = 'Trail Blazer';
  changeHandler(event) {
    this.greeting = event.target.value;
  }
}