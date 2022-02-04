import { LightningElement } from 'lwc';
import {NavigationMixin} from 'lightning/navigation';    

export default class OpportunityCreate extends NavigationMixin(LightningElement)  {
    connectedCallback() {
        
        console.log('Gopi123');

        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName: 'Opportunity',
                actionName: 'new'
            }
        });
        console.log('Last');
    }
}