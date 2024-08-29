import { LightningElement, api, wire } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";

import FORM_FACTOR from "@salesforce/client/formFactor";

import getReportData from "@salesforce/apex/YardReport_Cont.getReportData";
import saveReport from "@salesforce/apex/YardReport_Cont.saveReport";
import updateItems from "@salesforce/apex/YardReport_Cont.updateItems";
import updateCounts from "@salesforce/apex/YardReport_Cont.updateCounts";

import { getRecord } from "lightning/uiRecordApi";
import Id from "@salesforce/user/Id";
import ProfileName from "@salesforce/schema/User.Profile.Name";

import signature_pad from "@salesforce/resourceUrl/signature_pad";
import { loadStyle, loadScript } from "lightning/platformResourceLoader";
import yardSheetStyles from "@salesforce/resourceUrl/yardSheetStyles";

const userTimezone = Intl.DateTimeFormat().resolvedOptions().timeZone;
const today = new Date();
const year = today.getFullYear();
const month = String(today.getMonth() + 1).padStart(2, "0");
const day = String(today.getDate()).padStart(2, "0");
const todaysDate = `${year}-${month}-${day}`;

export default class YardReport extends LightningElement {
  @api recordId; //yard id
  userId = Id;
  userProfileName = '';

  @wire(getRecord, { recordId: Id, fields: [ProfileName] })
  userDetails({ error, data }) {
    if (error) {
      this.error = error;
    } else if (data) {
      if (data.fields.Profile.value != null) {
        this.userProfileName = data.fields.Profile.value.fields.Name.value;
        console.log("PROFILE: " + this.userProfileName);
      }
    }
  }

  showReports = true;
  showUngraded = false;

  matsUngraded; //for ungraded viewport

  today = todaysDate;
  date = todaysDate; //default to today. Will change on user input
  report;
  matsReceived;
  matsShipped;
  matsGradedToday;
  movements_edited;
  adjustments;
  beginningInventory;
  endingInventory;
  counts_edited;

  loading = true;

  get isToday() {
    return this.date == this.today ? true : false;
  }

  get isFieldService() {
    if (this.userProfileName == '') {
      return true; //default to true as to hide certain functions (such as adjustments) by default
    }
    return this.userProfileName.includes("Field Service") ? true : false;
  }


  toggleViewport() {
    if (this.showReports) {
      this.showReports = false;
      this.showUngraded = true;
    } else {
      this.showReports = true;
      this.showUngraded = false;
    }
  }

  get reportTitle() {
    return this.showReports ? "Daily Report" : "Ungraded Loads";
  }

  get viewportButtonLabel() {
    if (this.showReports == false) {
      return "Back to Reports";
    }
    if (this.matsUngraded != undefined) {
      return (
        "Ungraded Loads (" + this.matsUngraded.movementSummary.loadCount + ")"
      );
    }
  }

  get viewportButtonVariant() {
    return this.showReports ? "destructive" : "neutral";
  }

  get viewportButtonIcon() {
    return this.showReports ? "utility:chevronright" : "utility:chevronleft";
  }

  get viewportButtonIconPosition() {
    return this.showReports ? "right" : "left";
  }

  get hasData() {
    if (this.showReports && this.report != null && this.report != undefined) {
      return true;
    } else if (
      this.showUngraded &&
      this.matsUngraded != null &&
      this.matsUngraded != undefined
    ) {
      return true;
    } else {
      return false;
    }
  }

  connectedCallback() {
    console.log("Firing connected callback for yard report...");
    this.refreshData();
  }
  reinitializeData() {
    this.report = null;
    this.matsUngraded = null;
    this.matsReceived = null;
    this.matsShipped = null;
    this.matsGradedToday = null;
    this.beginningInventory = null;
    this.adjustments = null;
    this.endingInventory = null;
  }
  refreshData() {
    this.loading = true;
    console.log("Reporting for the following date: ");
    console.log(this.date);
    getReportData({ yardId: this.recordId, reportDate: this.date })
      .then((result) => {
        console.log("Successfully fetched report data!");
        console.log(result);
        this.report = result.report;

        this.matsUngraded = result.matsUngraded;
        this.summarizeUngraded();
        this.styleMovements("matsUngraded");

        this.matsReceived = result.matsReceived;
        this.styleMovements("matsReceived");
        this.matsShipped = result.matsShipped;
        this.styleMovements("matsShipped");
        this.matsGradedToday = result.matsGradedToday;
        this.styleMovements("matsGradedToday");

        this.beginningInventory = result.beginningInventory;
        this.styleCounts("beginningInventory");
        this.adjustments = result.adjustments;
        this.styleCounts("adjustments");
        this.endingInventory = result.endingInventory;
        this.styleEndingCounts("endingInventory");

        this.organizeFiles();

        if (
          this.report.Employee_Signature__c == null ||
          this.report.Employee_Signature__c == undefined
        ) {
          Promise.all([loadScript(this, signature_pad)])
            .then(() => {
              if (this.showReports == true) {
                var sigCanvas = this.template.querySelector(".reportSignature");
                this.initializeSignaturePad(sigCanvas, "reportSignature");
              }
            })
            .catch((error) => {
              this.showToast(
                "Error loading signature pad",
                error.message,
                "error"
              );
            });
        }

        this.loading = false;
      })
      .catch((error) => {
        //handle error
        console.log("Unable to query report data...");
        console.log(error);
        this.reinitializeData();
        this.loading = false;
      });
  }

  summarizeUngraded() {
    let ungradedLoads = this.matsUngraded;
    console.log("Summarizing following ungraded stuffs:");
    console.log(JSON.parse(JSON.stringify(ungradedLoads)));
    try {
      var newUngradedList = [];
      ungradedLoads.movementRecords.forEach((movementRecord) => {
        let jobId = movementRecord.jobIdentifier;
        let itemList = [];
        let movementMap = new Map();
        movementRecord.items.forEach((load) => {
          let searchedCommodity = movementMap.get(load.Commodity__c);
          if (searchedCommodity == undefined) {
            searchedCommodity = new Object();
            searchedCommodity = {
              Commodity__c: load.Commodity__c,
              Quantity__c: load.Quantity__c,
              New__c: load.New__c,
              A_Four__c: load.A_Four__c,
              A_Three__c: load.A_Three__c,
              B_Two__c: load.B_Two__c,
              B_One__c: load.B_One__c,
              Cull__c: load.Cull__c
            };

          } else {
            searchedCommodity.Quantity__c += load.Quantity__c;
            searchedCommodity.New__c += load.New__c;
            searchedCommodity.A_Four__c += load.A_Four__c;
            searchedCommodity.A_Three__c += load.A_Three__c;
            searchedCommodity.B_Two__c += load.B_Two__c;
            searchedCommodity.B_One__c += load.B_One__c;
            searchedCommodity.Cull__c += load.Cull__c;
          }
          movementMap.set(load.Commodity__c, searchedCommodity);
        });

        for (const val of movementMap.values()) {
          itemList.push(val);
        }

        let newUngradedRecord = {
          jobIdentifier: jobId,
          items: itemList
        };

        newUngradedList.push(newUngradedRecord);
      });

      console.log("Updated ungraded list:");
      console.log(JSON.parse(JSON.stringify(newUngradedList)));
    } catch(error) {
      console.log("Error working w/ ungraded loads: " + error.message);
    }
  }
    
  get hasAttachments() {
    if (this.report == undefined) {
      return false;
    } else if (this.report.ContentDocumentLinks == undefined) {
      return false;
    } else {
      return true;
    }
  }

  getAttachmentTitle(attachment) {

    var documentTitle = '';
    var documentExtension = '';
    documentTitle = attachment.ContentDocument.Title;
    documentExtension = attachment.ContentDocument.FileExtension;

    return documentTitle + '.' + documentExtension;
  }

  getAttachmentDownloadLink(attachment) {

    var documentId = '';
    documentId = attachment.ContentDocumentId;
    return '/lightning/r/ContentDocument/' + documentId + '/view';

  }

  organizeFiles() {
    if (!this.hasAttachments) {
      return;
    }
    for (var i = 0; i < this.report.ContentDocumentLinks.length; i++) {
      this.report.ContentDocumentLinks[i].documentTitle = this.getAttachmentTitle(this.report.ContentDocumentLinks[i]);
      if (this.report.ContentDocumentLinks.length > 1) {
        var fileCount = i + 1;
        this.report.ContentDocumentLinks[i].documentTitle += ' (' + fileCount + ')';
      }
      this.report.ContentDocumentLinks[i].documentLink = this.getAttachmentDownloadLink(this.report.ContentDocumentLinks[i]);
    }
  }

  styleMovements(movementProperty) {
    this[movementProperty].movementRecords.forEach((record) => {
      record.items.forEach((movement) => {
        if (movement.Total__c != movement.Quantity__c) {
          movement.dateCSS = "red-background";
          movement.loadCSS = "red-background";
          movement.commodityCSS = "red-background";
          movement.qtyCSS = "red-background";
          movement.ungradedCSS = "red-background";
          movement.newCSS = "red-background";
          movement.aFourCSS = "red-background";
          movement.aThreeCSS = "red-background";
          movement.bTwoCSS = "red-background";
          movement.bOneCSS = "red-background";
          movement.cullCSS = "red-background";
        } else {
          movement.dateCSS = "green-background";
          movement.loadCSS = "green-background";
          movement.commodityCSS = "green-background";
          movement.qtyCSS = "green-background";
          movement.ungradedCSS = "green-background";
          movement.newCSS = "green-background";
          movement.aFourCSS = "green-background";
          movement.aThreeCSS = "green-background";
          movement.bTwoCSS = "green-background";
          movement.bOneCSS = "green-background";
          movement.cullCSS = "green-background";
        }

        var gradedDateTime = null;
        var gradedDate = null;
        var shipperDateTime = null;
        var shipperDate = null;
        var receiverDateTime = null;
        var receiverDate = null;
        if (
          movement.Graded_On__c != undefined &&
          movement.Graded_On__c != null
        ) {
          gradedDateTime = new Date(movement.Graded_On__c);
          gradedDate = gradedDateTime.toLocaleDateString("en-US", {
            year: "numeric",
            month: "2-digit",
            day: "2-digit"
          }); // 08/19/2023 (month and day with two digits)
        }
        if (
          movement.Load__r.Shipper_Date__c != undefined &&
          movement.Load__r.Shipper_Date__c != null
        ) {
          shipperDateTime = new Date(movement.Load__r.Shipper_Date__c);
          shipperDate = shipperDateTime.toLocaleDateString("en-US", {
            year: "numeric",
            month: "2-digit",
            day: "2-digit"
          }); // 08/19/2023 (month and day with two digits)
        }
        if (
          movement.Load__r.Receiver_Date__c != undefined &&
          movement.Load__r.Receiver_Date__c != null
        ) {
          receiverDateTime = new Date(movement.Load__r.Receiver_Date__c);
          receiverDate = receiverDateTime.toLocaleDateString("en-US", {
            year: "numeric",
            month: "2-digit",
            day: "2-digit"
          }); // 08/19/2023 (month and day with two digits)
        }

        if (movementProperty == "matsShipped") {
          //evalulate shipper date
          if (shipperDate == gradedDate) {
            movement.dateCSS = "green-background";
            movement.loadCSS = "green-background";
            movement.commodityCSS = "green-background";
            movement.qtyCSS = "green-background";
            movement.ungradedCSS = "green-background";
            movement.newCSS = "green-background";
            movement.aFourCSS = "green-background";
            movement.aThreeCSS = "green-background";
            movement.bTwoCSS = "green-background";
            movement.bOneCSS = "green-background";
            movement.cullCSS = "green-background";
          } else {
            movement.dateCSS = "red-background";
            movement.loadCSS = "red-background";
            movement.commodityCSS = "red-background";
            movement.qtyCSS = "red-background";
            movement.ungradedCSS = "red-background";
            movement.newCSS = "red-background";
            movement.aFourCSS = "red-background";
            movement.aThreeCSS = "red-background";
            movement.bTwoCSS = "red-background";
            movement.bOneCSS = "red-background";
            movement.cullCSS = "red-background";
          }
        } else if (movementProperty == "matsReceived") {
          //everything else should evaluate receiver date
          if (receiverDate == gradedDate) {
            movement.dateCSS = "green-background";
            movement.loadCSS = "green-background";
            movement.commodityCSS = "green-background";
            movement.qtyCSS = "green-background";
            movement.ungradedCSS = "green-background";
            movement.newCSS = "green-background";
            movement.aFourCSS = "green-background";
            movement.aThreeCSS = "green-background";
            movement.bTwoCSS = "green-background";
            movement.bOneCSS = "green-background";
            movement.cullCSS = "green-background";
          } else {
            movement.dateCSS = "red-background";
            movement.loadCSS = "red-background";
            movement.commodityCSS = "red-background";
            movement.qtyCSS = "red-background";
            movement.ungradedCSS = "red-background";
            movement.newCSS = "red-background";
            movement.aFourCSS = "red-background";
            movement.aThreeCSS = "red-background";
            movement.bTwoCSS = "red-background";
            movement.bOneCSS = "red-background";
            movement.cullCSS = "red-background";
          }
        }
        if (movement.Commodity__c.startsWith("8x4x") == false) {
          movement.aFourCSS = "black-background";
          movement.bTwoCSS = "black-background";
        }

        /*
                movement.updateCSS = 'blue-fill';
                movement.signCSS = 'blue-fill';
                movement.deleteCSS = 'red-fill';
								*/
      });
    });
  }

  styleCounts(countProperty) {
    this[countProperty].forEach((count) => {
      if (count.Commodity_Formula__c.startsWith("8x4x") == false) {
        count.aFourCSS = "black-background";
        count.bTwoCSS = "black-background";
      }
    });
  }

  styleEndingCounts(countProperty) {
    this[countProperty].forEach((ending) => {
      var beginningMatch = this.beginningInventory.find(
        (beginning) =>
          beginning.Commodity_Lookup__c == ending.Commodity_Lookup__c
      );
      if (beginningMatch == undefined) {
        ending.commodityCSS = "blue-background";
        if (ending.New__c > 0) {
          ending.newCSS = "yellow-background";
        }
        if (ending.A_Four__c > 0) {
          ending.aFourCSS = "yellow-background";
        }
        if (ending.A_Three__c > 0) {
          ending.aThreeCSS = "yellow-background";
        }
        if (ending.B_Two__c > 0) {
          ending.bTwoCSS = "yellow-background";
        }
        if (ending.B_One__c > 0) {
          ending.bOneCSS = "yellow-background";
        }
        if (ending.Cull__c > 0) {
          ending.cullCSS = "yellow-background";
        }
        if (ending.Ungraded__c > 0) {
          ending.ungradedCSS = "yellow-background";
        }
      } else {
        if (beginningMatch.New__c != ending.New__c) {
          ending.newCSS = "yellow-background";
        }
        if (beginningMatch.A_Four__c != ending.A_Four__c) {
          ending.aFourCSS = "yellow-background";
        }
        if (beginningMatch.A_Three__c != ending.A_Three__c) {
          ending.aThreeCSS = "yellow-background";
        }
        if (beginningMatch.B_Two__c != ending.B_Two__c) {
          ending.bTwoCSS = "yellow-background";
        }
        if (beginningMatch.B_One__c != ending.B_One__c) {
          ending.bOneCSS = "yellow-background";
        }
        if (beginningMatch.Cull__c != ending.Cull__c) {
          ending.cullCSS = "yellow-background";
        }
        if (beginningMatch.Ungraded__c != ending.Ungraded__c) {
          ending.ungradedCSS = "yellow-background";
        }
      }
      if (ending.Commodity_Formula__c.startsWith("8x4x") == false) {
        ending.aFourCSS = "black-background";
        ending.bTwoCSS = "black-background";
      }
    });
  }

  get hasUngraded() {
    return (
      this.matsUngraded != undefined &&
      this.matsUngraded != null &&
      this.matsUngraded.movementRecords.length > 0
    );
  }

  get hasGradedToday() {
    return (
      this.matsGradedToday != undefined &&
      this.matsGradedToday != null &&
      this.matsGradedToday.movementRecords.length > 0
    );
  }

  get hasDeliveries() {
    return (
      this.matsReceived != undefined &&
      this.matsReceived != null &&
      this.matsReceived.movementRecords.length > 0
    );
  }

  get hasShipments() {
    return (
      this.matsShipped != undefined &&
      this.matsShipped != null &&
      this.matsShipped.movementRecords.length > 0
    );
  }

  get hasAdjustments() {
    return (
      this.adjustments != undefined &&
      this.adjustments != null &&
      this.adjustments.length > 0
    );
  }
  reportSignature;
  loadSignature;
  initializeSignaturePad(sigCanvas, signatureProperty) {
    if (this.showReports == true) {
      console.log(
        "Successfully found promised signature pad file...initializing canvas"
      );
      //var sigCanvas = this.template.querySelector(".padClass");
      console.log("Found the following pickup canvas: ");
      console.log(sigCanvas);
      this[signatureProperty] = new SignaturePad(sigCanvas);
      this[signatureProperty].minWidth = 2;
      this[signatureProperty].maxWidth = 4;
      this[signatureProperty].penColor = "#000000";
      this[signatureProperty].backgroundColor = "#FFFFFF";
      this[signatureProperty].toDataURL();
      window.onresize = this.resizeCanvas(sigCanvas);
      this.resizeCanvas(sigCanvas);
    }
  }

  resizeCanvas(canvas) {
    var ratio = Math.max(window.devicePixelRatio || 1, 1);
    canvas.width = canvas.offsetWidth * ratio;
    canvas.height = canvas.offsetHeight * ratio;
    canvas.getContext("2d").scale(ratio, ratio);
  }

  // Function to format the date as yyyy-mm-dd
  formatDate(date) {
    const year = date.getFullYear();
    const month = String(date.getMonth() + 1).padStart(2, '0');
    const day = String(date.getDate()).padStart(2, '0');
    return `${year}-${month}-${day}`;
  }

  // Function to get the local timezone offset
  getTimezoneOffset() {
    const date = new Date();
    return date.getTimezoneOffset();
  }

  // Function to get the local date string in yyyy-mm-dd format
  getLocalDate() {
    const date = new Date();
    return this.formatDate(date);
  }

  // Function to calculate the modified date based on the local timezone offset
  calculateModifiedDate(date, offset) {
    const currentDate = new Date(date);
    const adjustedDate = new Date(currentDate.getTime() + offset * 60 * 1000);
    return this.formatDate(adjustedDate);
  }

  // Function to show the previous day
  showYesterday() {
    const offset = this.getTimezoneOffset();
    const currentDate = new Date(this.date);
    currentDate.setDate(currentDate.getDate() - 1);
    const modifiedDate = this.calculateModifiedDate(currentDate, offset);
    this.date = modifiedDate;
    this.reinitializeData();
    this.refreshData();
  }

  // Function to show the next day
  showTomorrow() {
    const offset = this.getTimezoneOffset();
    const currentDate = new Date(this.date);
    currentDate.setDate(currentDate.getDate() + 1);
    const modifiedDate = this.calculateModifiedDate(currentDate, offset);
    this.date = modifiedDate;
    this.reinitializeData();
    this.refreshData();
  }
  updateReportDate(evt) {
    console.log("Updating report date...");
    console.log(evt.detail.value);
    this.date = evt.detail.value;
    this.reinitializeData();
    this.refreshData();
  }

  updateReport(evt) {
    console.log("Updating report data from client...");
    this.report[evt.target.name] = evt.detail.value;
  }

  get receivedColumns() {
    var cols = [
      {
        label: "Received On",
        fieldName: "ReceiverDate__c",
        type: "date",
        typeAttributes: {
          year: "2-digit",
          month: "2-digit",
          day: "2-digit",
          hour: "2-digit",
          minute: "2-digit"
        },
        cellAttributes: {
          class: { fieldName: "dateCSS" }
        },
        wrapText: true,
        editable: false,
        hideDefaultActions: true
      },
      {
        label: "Load #",
        fieldName: "Load_Link__c",
        type: "url",
        typeAttributes: {
          label: {
            fieldName: "Load_ID__c"
          },
          target: "_blank"
        },
        cellAttributes: {
          class: { fieldName: "loadCSS" }
        },
        hideDefaultActions: true
      },
      {
        label: "Commodity",
        type: "text",
        fieldName: "Commodity__c",
        cellAttributes: {
          class: { fieldName: "commodityCSS" }
        },
        hideDefaultActions: true
      },
      {
        label: "Qty",
        fieldName: "Quantity__c",
        type: "number",
        editable: true,
        cellAttributes: {
          class: { fieldName: "qtyCSS" }
        },
        hideDefaultActions: true
      },
      {
        label: "Ungraded",
        fieldName: "Ungraded__c",
        type: "number",
        editable: false,
        cellAttributes: {
          class: { fieldName: "ungradedCSS" }
        },
        hideDefaultActions: true
      },
      {
        label: "New",
        fieldName: "New__c",
        type: "number",
        editable: true,
        cellAttributes: {
          class: { fieldName: "newCSS" }
        },
        hideDefaultActions: true
      },
      {
        label: "A4",
        fieldName: "A_Four__c",
        type: "number",
        editable: true,
        cellAttributes: {
          class: { fieldName: "aFourCSS" }
        },
        hideDefaultActions: true
      },
      {
        label: "A3",
        fieldName: "A_Three__c",
        type: "number",
        editable: true,
        cellAttributes: {
          class: { fieldName: "aThreeCSS" }
        },
        hideDefaultActions: true
      },
      {
        label: "B2",
        fieldName: "B_Two__c",
        type: "number",
        editable: true,
        cellAttributes: {
          class: { fieldName: "bTwoCSS" }
        },
        hideDefaultActions: true
      },
      {
        label: "B1",
        fieldName: "B_One__c",
        type: "number",
        editable: true,
        cellAttributes: {
          class: { fieldName: "bOneCSS" }
        },
        hideDefaultActions: true
      },
      {
        label: "Cull",
        fieldName: "Cull__c",
        type: "number",
        editable: true,
        cellAttributes: {
          class: { fieldName: "cullCSS" }
        },
        hideDefaultActions: true
      }
    ];

    for (var i = 0; i < cols.length; i++) {
      if (this.isToday == false) {
        cols[i].editable = false;
        if (i == 1) {
          var gradedCol = {
            label: "Graded On",
            fieldName: "Graded_On__c",
            type: "date",
            typeAttributes: {
              year: "2-digit",
              month: "2-digit",
              day: "2-digit",
              hour: "2-digit",
              minute: "2-digit"
            },
            cellAttributes: {
              class: { fieldName: "dateCSS" }
            },
            wrapText: true,
            editable: false,
            hideDefaultActions: true
          };
          cols.splice(1, 0, gradedCol);
        }
      } else if (FORM_FACTOR != "Large") {
        cols[i].initialWidth = 110;
      }
    }

    return cols;
  }

  get shippedColumns() {
    var cols = [
      {
        label: "Shipped On",
        fieldName: "Shipper_Date__c",
        type: "date",
        typeAttributes: {
          year: "2-digit",
          month: "2-digit",
          day: "2-digit",
          hour: "2-digit",
          minute: "2-digit"
        },
        cellAttributes: {
          class: { fieldName: "dateCSS" }
        },
        wrapText: true,
        editable: false,
        hideDefaultActions: true
      },
      {
        label: "Load #",
        fieldName: "Load_Link__c",
        type: "url",
        typeAttributes: {
          label: {
            fieldName: "Load_ID__c"
          },
          target: "_blank"
        },
        cellAttributes: {
          class: { fieldName: "loadCSS" }
        },
        hideDefaultActions: true
      },
      {
        label: "Commodity",
        type: "text",
        fieldName: "Commodity__c",
        cellAttributes: {
          class: { fieldName: "commodityCSS" }
        },
        hideDefaultActions: true
      },
      {
        label: "Qty",
        fieldName: "Quantity__c",
        type: "number",
        editable: true,
        cellAttributes: {
          class: { fieldName: "qtyCSS" }
        },
        hideDefaultActions: true
      },
      {
        label: "Ungraded",
        fieldName: "Ungraded__c",
        type: "number",
        editable: false,
        cellAttributes: {
          class: { fieldName: "ungradedCSS" }
        },
        hideDefaultActions: true
      },
      {
        label: "New",
        fieldName: "New__c",
        type: "number",
        editable: true,
        cellAttributes: {
          class: { fieldName: "newCSS" }
        },
        hideDefaultActions: true
      },
      {
        label: "A4",
        fieldName: "A_Four__c",
        type: "number",
        editable: true,
        cellAttributes: {
          class: { fieldName: "aFourCSS" }
        },
        hideDefaultActions: true
      },
      {
        label: "A3",
        fieldName: "A_Three__c",
        type: "number",
        editable: true,
        cellAttributes: {
          class: { fieldName: "aThreeCSS" }
        },
        hideDefaultActions: true
      },
      {
        label: "B2",
        fieldName: "B_Two__c",
        type: "number",
        editable: true,
        cellAttributes: {
          class: { fieldName: "bTwoCSS" }
        },
        hideDefaultActions: true
      },
      {
        label: "B1",
        fieldName: "B_One__c",
        type: "number",
        editable: true,
        cellAttributes: {
          class: { fieldName: "bOneCSS" }
        },
        hideDefaultActions: true
      },
      {
        label: "Cull",
        fieldName: "Cull__c",
        type: "number",
        editable: true,
        cellAttributes: {
          class: { fieldName: "cullCSS" }
        },
        hideDefaultActions: true
      }
    ];

    for (var i = 0; i < cols.length; i++) {
      if (this.isToday == false) {
        cols[i].editable = false;
        if (i == 1) {
          var gradedCol = {
            label: "Graded On",
            fieldName: "Graded_On__c",
            type: "date",
            typeAttributes: {
              year: "2-digit",
              month: "2-digit",
              day: "2-digit",
              hour: "2-digit",
              minute: "2-digit"
            },
            cellAttributes: {
              class: { fieldName: "dateCSS" }
            },
            wrapText: true,
            editable: false,
            hideDefaultActions: true
          };
          cols.splice(1, 0, gradedCol);
        }
      } else if (FORM_FACTOR != "Large") {
        cols[i].initialWidth = 110;
      }
    }

    return cols;
  }

  get inventoryColumns() {
    var cols = [
      {
        label: "Commodity",
        fieldName: "Commodity_Formula__c",
        hideDefaultActions: true,
        cellAttributes: {
          class: { fieldName: "commodityCSS" }
        }
      },
      {
        label: "New",
        fieldName: "New__c",
        hideDefaultActions: true,
        cellAttributes: {
          class: { fieldName: "newCSS" }
        }
      },
      {
        label: "A4",
        fieldName: "A_Four__c",
        hideDefaultActions: true,
        cellAttributes: {
          class: { fieldName: "aFourCSS" }
        }
      },
      {
        label: "A3",
        fieldName: "A_Three__c",
        hideDefaultActions: true,
        cellAttributes: {
          class: { fieldName: "aThreeCSS" }
        }
      },
      {
        label: "B2",
        fieldName: "B_Two__c",
        hideDefaultActions: true,
        cellAttributes: {
          class: { fieldName: "bTwoCSS" }
        }
      },
      {
        label: "B1",
        fieldName: "B_One__c",
        hideDefaultActions: true,
        cellAttributes: {
          class: { fieldName: "bOneCSS" }
        }
      },
      {
        label: "Cull",
        fieldName: "Cull__c",
        hideDefaultActions: true,
        cellAttributes: {
          class: { fieldName: "cullCSS" }
        }
      },
      {
        label: "Ungraded",
        fieldName: "Ungraded__c",
        editable: false,
        cellAttributes: {
          class: { fieldName: "ungradedCSS" }
        },
        hideDefaultActions: true
      },
      {
        label: "Comments",
        fieldName: "Comments__c",
        hideDefaultActions: true,
        wrapText: true,
        editable: true
      }
    ];

    for (var i = 0; i < cols.length; i++) {
      if (this.isToday == false) {
        cols[i].editable = false;
      }
    }

    return cols;
  }

  isCssLoaded = false;
  renderedCallback() {
    console.log("Firing rendered callback for yard report...");
    if (this.isCssLoaded) return;
    this.isCssLoaded = true;
    loadStyle(this, yardSheetStyles)
      .then(() => {
        console.log("Styles Loaded Successfully");
      })
      .catch((error) => {
        console.error("Error in loading the colors: " + error.message);
      });
  }

  /*
    addDelivery() {
        console.log("Adding new delivery...");
        var modalHeader = 'Add New Delivery';
        var flowApiName = 'Inventory_Report_Add_Movement';
        var flowInputs = [
            {
                name: 'recordId',
                type: 'String',
                value: this.report.Id
            },
            {
                name: 'movementType',
                type: 'String',
                value: 'Delivery'
            }
        ];

        this.displayModal(modalHeader, flowApiName, flowInputs);
    }

    addShipment() {
        console.log("Adding new shipment...");
        var modalHeader = 'Add New Shipment';
        var flowApiName = 'Inventory_Report_Add_Movement';
        var flowInputs = [
            {
                name: 'recordId',
                type: 'String',
                value: this.report.Id
            },
            {
                name: 'movementType',
                type: 'String',
                value: 'Shipment'
            }
        ];

        this.displayModal(modalHeader, flowApiName, flowInputs);
    }
    */
  
  
  takePhoto() {
    this.displayModal(this.date + ' - Attach Paper Copy', 'Inventory_Report_File_Upload', this.fileFlowInputs);
  }

  showModal = false;
  showFlow = false;
  //showFrame = false;
  //frameURL;
  modalHeader;
  flowApiName;
  flowInputs;

  displayModal(modalHeader, flowApiName, flowInputs) {
    console.log("Passing following inputs to show modal:");
    console.log("Header: " + modalHeader);
    console.log("Flow: " + flowApiName);
    console.log("Inputs:");
    console.log(flowInputs);
    this.modalHeader = modalHeader;
    this.flowApiName = flowApiName;
    this.flowInputs = flowInputs;
    this.showFlow = true;
    this.showModal = true;
  }

  closeModal() {
    this.modalHeader = null;
    this.flowApiName = null;
    this.flowInputs = null;
    this.frameURL = null;
    this.showFlow = false;
    //this.showFrame = false;
    //this.showCommodities = false;
    //this.showSignatureBox = false;
    //this.selectedCommodity = null;
    //this.commodityOptions = null;
    //this.itemToUpdate = null;
    //this.bol_movementType = null;
    //this.hasSigned = false;
    //this.signatureToShow = null;
    //this.signDate = null;
    //this.showFooter = false;
    this.showModal = false;
  }
  addAdjustment() {
    console.log("Adding new adjustment...");
    var modalHeader = "Add New Adjustment";
    var flowApiName = "Inventory_Report_Add_Adjustment";
    var flowInputs = [
      {
        name: "reportId",
        type: "String",
        value: this.report.Id
      }
    ];

    this.displayModal(modalHeader, flowApiName, flowInputs);
  }

  handleFlowStatusChange(evt) {
    console.log("Handling flow status change...");
    console.log("Flow status: " + evt.detail.status);
    if (
      evt.detail.status === "FINISHED" ||
      evt.detail.status === "FINISHED_SCREEN"
    ) {
      // set behavior after a finished flow interview
      this.closeModal();
      this.refreshData();
    }
  }

  updateMovements(evt) {
    console.log("Updating movement...");
    this.loading = true;
    const updatedFields = evt.detail.draftValues;
    // prepare updated records for sending to server
    const updatedRecords = updatedFields.map((draft) => {
      const updatedRecord = { Id: draft.Id };
      // iterate over each field and update the record
      Object.keys(draft).forEach((field) => {
        if (draft[field] == "") {
          updatedRecord[field] = 0;
        } else {
          updatedRecord[field] = draft[field];
        }
      });
      return updatedRecord;
    });
    // call the Apex method to update records
    updateItems({ itemsToUpdate: updatedRecords })
      .then((result) => {
        // handle successful save
        this.refreshData();
        this.showToast("Successfully updated movement(s)!", "", "success");
      })
      .catch((error) => {
        console.error(error);
        this.loading = false;
        this.showToast("Unable to update movement(s)", error.message, "error");
      });
  }

  updateCounts(evt) {
    console.log("Updating counts...");
    this.loading = true;
    const updatedFields = evt.detail.draftValues;
    // prepare updated records for sending to server
    const updatedRecords = updatedFields.map((draft) => {
      const updatedRecord = { Id: draft.Id };
      // iterate over each field and update the record
      Object.keys(draft).forEach((field) => {
        updatedRecord[field] = draft[field];
      });
      return updatedRecord;
    });
    console.log("Found the following updated records:");
    console.log(JSON.parse(JSON.stringify(updatedRecords)));
    // call the Apex method to update records
    updateCounts({ countsToUpdate: updatedRecords })
      .then((result) => {
        // handle successful save
        this.refreshData();
        this.showToast("Successfully updated count(s)!", "", "success");
      })
      .catch((error) => {
        console.error(error);
        this.loading = false;
        this.showToast("Unable to update movement(s)", error.message, "error");
      });
  }


  /*
    get showModalButton() {
        return this.showCommodityOptions == true || this.showSignatureBox == true ? true : false;
    }

    handleRowAction(evt) {
        const action = evt.detail.action;
        const row = evt.detail.row;
        console.log("Handling row action...");
        console.log("Action: ");
        console.log(action);
        console.log("Row: ");
        console.log(row);
        if (action.name === 'Update') {
            this.showCommodityOptions(row, row.Load__c);
        } else if (action.name === 'Sign') {
            this.signBOL(row, row.Load__c);
        } else if (action.name === 'Remove') {
            if (window.confirm('Are you sure you want to remove this load from the report?')) {
                this.removeLoad(row);
            }
        }
    }

    selectedCommodity;
    commodityOptions;
    itemToUpdate;
    showCommodities;
    showCommodityOptions(item, loadId) {
        console.log("Getting commodity options for load w/ Id: " + loadId);
        getCommodityOptions({ loadId: loadId })
            .then(res => {
                console.log("Successfully found the following commodity options:");
                console.log(res);
                this.commodityOptions = res;
                this.itemToUpdate = item;
                var comm = this.commodityOptions.find(record => record.value === this.itemToUpdate.Commodity__c);
                if (comm != undefined) {
                    this.selectedCommodity = this.itemToUpdate.Commodity__c;
                } else {
                    this.selectedCommodity = 'Other';
                }
                this.modalHeader = item.Load__r.Name + ' - Update Commodity';
                this.showCommodities = true;
                this.showFooter = true;
                this.showModal = true;
            }).catch(err => {
                console.log("Error whenever fetching commodity options: " + err.message);
                this.showToast('Error getting commodity options', err.message, 'error');
            });
    }

    handleCommodityChange(event) {
        console.log("Updating commodity...");
        this.selectedCommodity = event.detail.value;
        if (this.selectedCommodity == 'Other') {
            return;
        }
        let selectedOption = this.commodityOptions.find(option => option.value === event.detail.value);
        console.log("Selected commodity: ");
        console.log(selectedOption);
        console.log("Updating item's order references...");
        this.itemToUpdate.Product__c = null;
        this.itemToUpdate.Equipment__c = null;
        if (selectedOption.deliveryOrder == undefined) {
            this.itemToUpdate.Delivery_Order__c = null;
            this.itemToUpdate.Delivery_Item__c = null;
        } else {
            this.itemToUpdate.Delivery_Order__c = selectedOption.deliveryOrder;
            this.itemToUpdate.Delivery_Item__c = selectedOption.deliveryItem;
        }
        if (selectedOption.pickupOrder == undefined) {
            this.itemToUpdate.Pickup_Order__c = null;
            this.itemToUpdate.Pickup_Item__c = null;
        } else {
            this.itemToUpdate.Pickup_Order__c = selectedOption.pickupOrder;
            this.itemToUpdate.Pickup_Item__c = selectedOption.pickupItem;
        }

        console.log("Updated item:");
        console.log(this.itemToUpdate);
    }

    get showProductLookup() {
        return this.selectedCommodity == 'Other' ? true : false;
    }

    logProduct(event) {
        console.log("Logging new product...");
        let selectedProduct = event.target.value;
        if (selectedProduct && selectedProduct != '') {
            this.itemToUpdate.Delivery_Order__c = null;
            this.itemToUpdate.Delivery_Item__c = null;
            this.itemToUpdate.Pickup_Order__c = null;
            this.itemToUpdate.Pickup_Item__c = null;
            this.itemToUpdate.Product__c = selectedProduct;
        } else {
            this.itemToUpdate.Product__c = null;
        }
        console.log("Updated item: ");
        console.log(this.itemToUpdate);
    }

    updateCommodity(event) {
        this.loading = true;
        console.log("Updating item...");
        updateItem({ item: this.itemToUpdate }).then(res => {
            this.closeModal();
            console.log("Successfully updated item!");
            this.loading = false;
            this.showToast('Successfully updated commodity!', '', 'success');
            this.refreshData();
        }).catch(error => {
            console.log('Error updating item: ' + error.body.message);
            this.loading = false;
            this.showToast('Error updating commodity...', error.body.message, 'error');
        });
    }

    bol_movementType;
    hasSigned;
    signatureToShow;
    signDate;
    signBOL(item, loadId) {
        console.log("Initializing signature pad for load w/ Id: " + loadId);
        //must have element shown in DOM to initialize singature pad
        this.itemToUpdate = item;
        var deliveryCheck = this.matsReceived.find((movement) => movement.Id == item.Id);
        var pickupCheck = this.matsShipped.find((movement) => movement.Id == item.Id);
        if (deliveryCheck) {
            this.bol_movementType = 'Delivery';
            if (deliveryCheck.Load__r.Receiver_Signature__c != null) {
                this.hasSigned = true;
                var parsedSig = this.parseSignatureField(deliveryCheck.Load__r.Receiver_Signature__c);
                this.signatureToShow = parsedSig;
                this.signDate = deliveryCheck.Load__r.Receiver_Date__c;
            } else {
                this.hasSigned = false;
            }
        } else if (pickupCheck) {
            this.bol_movementType = 'Pickup';
            if (pickupCheck.Load__r.Shipper_Signature__c != null) {
                this.hasSigned = true;
                var parsedSig = this.parseSignatureField(pickupCheck.Load__r.Shipper_Signature__c);
                this.signatureToShow = parsedSig;
                this.signDate = pickupCheck.Load__r.Shipper_Date__c;
            } else {
                this.hasSigned = false;
            }
        }
        this.modalHeader = item.Load__r.Name + ' - Sign BOL';
        this.showSignatureBox = true;
        this.showFooter = true;
        this.showModal = true;
        if (this.hasSigned == false) {
            setTimeout(() => {
                var sigCanvas = this.template.querySelector(".loadSignature");
                console.log("Found load signature canvas:");
                console.log(sigCanvas);
                this.initializeSignaturePad(sigCanvas, 'loadSignature');
            }, 1000);
        }

        //

    }

    parseSignatureField(field) {
        const imgTagStart = '<img src="';
        const imgTagEnd = '"></img>';
        var sig = field;
        const startIndex = sig.indexOf(imgTagStart) + imgTagStart.length;
        const endIndex = sig.indexOf(imgTagEnd);
        var sigUrl = sig.substring(startIndex, endIndex);
        return sigUrl.replace(/amp;/g, '');
    }

    saveSignature() {
        if (this.hasSigned) {
            this.closeModal();
        }
        if (this.loadSignature) {
            var signatureStrDataURI = this.loadSignature.toDataURL();
            if (this.loadSignature.isEmpty() == false) {
                console.log("Found signature!");
                console.log(signatureStrDataURI);
                console.log("Passing following input parameters:");
                var load = this.itemToUpdate.Load__r;
                if (this.bol_movementType == 'Delivery' && (load.Receiver_Signature__c == undefined || load.Receiver_Signature__c == null)) {
                    load.Receiver_Signature__c = '<img src="' + signatureStrDataURI + '">';
                } else if (this.bol_movementType == 'Pickup' && (load.Shipper_Signature__c == undefined || load.Shipper_Signature__c == null)) {
                    load.Shipper_Signature__c = '<img src="' + signatureStrDataURI + '">';
                } else {
                    this.closeModal();
                    this.showToast('Unable to store signature', 'Failed to find proper load reference', 'error');
                    return;
                }
                console.log("Load:");
                console.log(JSON.parse(JSON.stringify(load)));
                console.log("Movement Type: " + this.bol_movementType);
                this.loading = true;
                saveSignature({ loadToUpdate: load })
                    .then(res => {
                        console.log("Successfully stored signature!");
                        this.closeModal();
                        this.showToast('Successfully stored signature!', '', 'success');
                        this.refreshData();
                    })
                    .catch(error => {
                        console.log("Error storing signature: " + error.message);
                        this.closeModal();
                        this.loading = false;
                        this.showToast('Unable to store signature', error.message, 'error');
                    });
            }
        }
    }

    saveModalData(event) {
        if (this.showCommodities == true) {
            this.updateCommodity();
        } else if (this.showSignatureBox == true) {
            this.saveSignature();
        }
    }

    removeLoad(row) {
        this.loading = true;
        if (row.Pickup_Report__c == this.report.Id) {
            row.Pickup_Report__c = null;
        } 
        if (row.Delivery_Report__c == this.report.Id) {
            row.Delivery_Report__c = null;
        }

        deleteMovement({ movement: row })
            .then(result => {
                this.refreshData();
            }).catch (error => {
                this.showToast('Unable to remove load from report', error.message, 'error');
            });
    }
    */
  showToast(toastTitle, msg, toastVariant) {
    const evt = new ShowToastEvent({
      title: toastTitle,
      message: msg,
      variant: toastVariant,
      mode: "dismissable"
    });
    this.dispatchEvent(evt);
  }

  get shippedGradingComplete() {
    const shipments = this.matsShipped.movementRecords;
    console.log("Checking grades for all movements:");
    console.log(JSON.parse(JSON.stringify(shipments)));
    var graded = true;
    shipments.forEach((record) => {
				record.items.forEach((movement) => {
			      if (movement.Ungraded__c != 0) {
								graded = false;
						}			
				});
    });
    return graded;
  }

  get fileFlowInputs() {
    return [
      {
        name: 'reportId',
        type: 'String',
        value: this.report.Id
      }
    ];
  }

  save() {
    console.log("Shipments graded?" + this.shippedGradingComplete);
    if (this.shippedGradingComplete == false) {
        alert("All shipments must be graded prior to saving.\n\nPlease look over all shipments highlighted in red and make sure they have been properly graded.");
        return;
    }
    console.log("Report signature:");
    console.log(this.reportSignature);
    if (this.reportSignature.isEmpty()) {
      alert("Report must be signed to save. Please sign to the left and then try saving again.");
      return;
    }
    console.log("Has attachments?" + this.hasAttachments);
    if (this.hasAttachments == false) {
      alert("Paper report must be uploaded prior to saving. Please use camera icon above to upload paper report");
      return;
    }
    this.loading = true;
    if (this.reportSignature) {
      var signatureStrDataURI = this.reportSignature.toDataURL();
      if (this.reportSignature.isEmpty() == false) {
        this.report.Employee_Signature__c = signatureStrDataURI;
        console.log("Found signature!");
        console.log(this.report.Employee_Signature__c);
      }
    }
    console.log("Saving report...");
    console.log("Report data:");
    console.log(JSON.parse(JSON.stringify(this.report)));
    console.log("MATS IN");
    console.log(JSON.parse(JSON.stringify(this.matsReceived)));
    console.log("MATS OUT");
    console.log(JSON.parse(JSON.stringify(this.matsShipped)));
    console.log("BEGINNING INVENTORY");
    console.log(JSON.parse(JSON.stringify(this.beginningInventory)));
    console.log("ENDING INVENTORY");
    console.log(JSON.parse(JSON.stringify(this.endingInventory)));

    var dataToUpdate = {
      report: this.report,
      matsReceived: this.matsReceived,
      matsShipped: this.matsShipped,
      beginningInventory: this.beginningInventory,
      endingInventory: this.endingInventory
    };

    console.log("Passing the following data to server for update: ");
    console.log(JSON.stringify(dataToUpdate));

    saveReport({ payload: dataToUpdate })
      .then((result) => {
        console.log("Successfully updated report data!");
        this.showToast("Successfully saved report data!", "", "success");
        this.refreshData();
      })
      .catch((error) => {
        //handle error
        console.log("Unable to update report data...");
        console.log(error);
        //throw error message
        this.loading = false;
        this.showToast("Error saving report data", error.body.message, "error");
      });
  }
}