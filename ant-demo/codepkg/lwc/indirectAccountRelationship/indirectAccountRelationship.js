import { LightningElement,track,wire,api } from 'lwc';
import getIndirectContacts from '@salesforce/apex/AccountHelper.getIndirectContacts';

export default class IndirectAccountRelationship extends LightningElement {
    @api recordId;
    @api NoOfRecords;
    @api sortOption;

    @track columns = [
        { label: 'First Name', fieldName: 'Contact_First_Name__c', type: 'text' },
        { label: 'Last Name', fieldName: 'Contact_Last_Name__c', type: 'text' },
        { label: 'Roles', fieldName: 'Roles'}
    ];

    @wire(getIndirectContacts, {accId: '$recordId',noOfRecords:'$NoOfRecords',sortOption:'$sortOption'}) contacts;
    /*WireContactRecords({error, data}){
        if(data){
            this.contacts = data;
            this.error = undefined;
        }else{
            this.error = error;
            this.contacts = undefined;
        }
    }*/




}