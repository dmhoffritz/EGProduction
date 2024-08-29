import { LightningElement } from 'lwc';
import {
    FlowNavigationNextEvent
} from 'lightning/flowSupport';
export default class LoadRequestButton extends LightningElement {
    navRequest() {
        const navigateNextEvent = new FlowNavigationNextEvent();
        this.dispatchEvent(navigateNextEvent);
    }
}