import { LightningElement, track } from 'lwc';
import createNewBand from '@salesforce/apex/CreateNewBandController.createNewBand';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class Test extends LightningElement {
    @track isShowModal;
    @track nameValue;
    @track countryValue;
    @track yearOfFoundationValue;
    @track bandClosingYearValue;

    handleButtonClick(event) {
        this.isShowModal = true;
    }

    handleCloseModalButtonClick(event) {
        this.isShowModal = false;
    }

    handleCreateButtonClick(event) {
        createNewBand({ name: this.nameValue, country: this.countryValue, yearOfFoundation: this.yearOfFoundationValue, bandClosingYear: this.bandClosingYearValue })
            .then((result) => {
                this.showNotification('Success', 'New band successfully created', 'success');
                this.isShowModal = false;
            })
            .catch((error) => {
                this.showNotification('Error', error.body.message, 'error');
            });
    }

    handleNameValueChange(event) {
        this.nameValue = event.detail.value;
    }

    handleCountryValueChange(event) {
        this.countryValue = event.detail.value;
    }

    handleYearOfFoundationValueChange(event) {
        this.yearOfFoundationValue = event.detail.value;
    }

    handleBandClosingYearValueChange(event) {
        this.bandClosingYearValue = event.detail.value;
    }

    showNotification(title, message, variant) {
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
        });
        this.dispatchEvent(evt);
    }

}