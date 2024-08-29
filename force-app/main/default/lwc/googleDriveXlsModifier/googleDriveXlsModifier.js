import { LightningElement } from 'lwc';

export default class GoogleDriveXlsModifier extends LightningElement {
    constructor() {
        super();
        // Call the updateLinks function every 5 seconds (adjust as needed)
        setInterval(this.updateLinks.bind(this), 5000);
    }

    updateLinks() {
        // Find all <a> tags with a "data-id" attribute
        console.log("Finding all anchor elements");
        var linksWithDataId = document.querySelectorAll("a");
        console.log(JSON.parse(JSON.stringify(linksWithDataId)));
        /*
        linksWithDataId.forEach(link => {
            console.log("Looping link:");
            console.log(JSON.parse(JSON.stringify(link)));
            // Extract data-id attribute
            const fileId = link.getAttribute('data-id');

            // Create the new URL in the desired format
            const newLinkUrl = `https://drive.google.com/file/d/${fileId}/view`;

            // Update the data-link attribute with the new URL
            link.setAttribute('data-link', newLinkUrl);
        });
        */
    }
}