# SAP RAP Travel Booking Application

A complete, production-ready Travel Booking Application built using the **ABAP RESTful Application Programming Model (RAP)** on SAP S/4HANA. This project showcases modern ABAP Cloud development practices, including draft-enabled transactional handling, custom business logic, and a dynamic Fiori Elements UI.

## 🚀 Key Features

*   **Transactional Processing:** Managed, draft-enabled business object supporting full Create, Read, Update, and Delete (CRUD) operations.
*   **Business Actions:** Custom business actions for **Approve**, **Reject**, **Cancel**, and **Complete Journey**.
*   **Dynamic Feature Control:** State-dependent action enablement (e.g., Reject is only enabled for New status) and field-level editability locks after booking approval.
*   **Validations & Determinations:** 
    *   Automatic semantic key generation (Booking ID).
    *   Default field values on creation (Status = 'New', Currency = 'PKR', Travel Date = Today).
    *   Validations for past travel dates, invalid return dates, zero/negative pricing, and email format checking.
*   **Fiori UI & Data Export Features:** 
    *   📊 **Native Excel Export:** Standard capability enabled on the table toolbar to export booking records directly to Excel.
    *   🟢🔴 **Status Criticality (Color Coding):** Visual indicators on the Fiori UI using colors to represent booking states:
        *   **Green** for Approved
        *   **Red** for Cancelled / Rejected
        *   **Yellow** for New
        *   **Blue** for Completed
    *   Dropdown value help for Destination selection.
    *   Selection filters, search capabilities, and header facets on the Object Page.
*   **Audit Tracking:** Automated system fields tracking `Created By`, `Created At`, `Last Changed By`, and `Last Changed At`.

## 📁 Repository Structure

*   `ZTRAVEL_BOOK_419` - Primary Database Table.
*   `ZR_TRAVEL_BOOK_419` - Root CDS View Entity (Data Model).
*   `ZC_TRAVEL_BOOK_419` - Projection CDS View Entity (UI Layer).
*   `ZI_COUNTRY_VH_419` - Country Value Help CDS View.
*   `ZR_TRAVEL_BOOK_419` (BDEF) - Behavior Definition for the transactional logic.
*   `ZBP_R_TRAVEL_BOOK_419` - Behavior Implementation Class (ABAP Local Types).
*   `ZUI_TRAVEL_BOOK_419` - Service Definition & Service Binding (OData V4).

## 🛠️ How to Import and Run

1.  Create the database table `ZTRAVEL_BOOK_419` in your ABAP Development Tools (ADT).
2.  Import and activate the CDS view entities in the following order:
    *   `ZI_COUNTRY_VH_419` (Value Help)
    *   `ZR_TRAVEL_BOOK_419` (Root)
    *   `ZC_TRAVEL_BOOK_419` (Projection)
3.  Create the Behavior Definitions and implement the local handler class `ZBP_R_TRAVEL_BOOK_419`.
4.  Generate and activate the draft table `ztravel_419_drf` using ADT Quick Fix (`Ctrl+1`).
5.  Create the Service Definition and publish the Service Binding (`ODATA V4 - UI`).
6.  Open the Fiori Elements Preview from the Service Binding to run the application.
