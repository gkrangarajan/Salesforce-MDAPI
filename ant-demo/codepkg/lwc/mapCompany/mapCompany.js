import { LightningElement } from 'lwc';

export default class MapCompany extends LightningElement {
    zoomLevel;
    mapMarkers;
    listView;

    connectedCallback(){
        this.mapMarkers = [
            {
                location: {
                    City: 'San Francisco',
                    Country: 'USA',
                    PostalCode: '94105',
                    State: 'CA',
                    Street: 'Suite 300',
                },
                title: 'Bedrock’s corporate headquarters',
                description:
                    'The Landmark is considered to be one of the city&#39;s most architecturally distinct and historic properties', //escape the apostrophe in the string using &#39;
                icon: 'standard:account',
            },
        ];
        this.zoomLevel=10;
        this.listView="visible";



    }
    

}