@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Booking Projection View'
@Metadata.ignorePropagatedAnnotations: true
@Search.searchable: true

@UI: {
  headerInfo: {
    typeName: 'Booking',
    typeNamePlural: 'Bookings',
    title: { type: #STANDARD, value: 'BookingId' },
    description: { type: #STANDARD, value: 'CustomerName' }
  }
}
define root view entity ZC_TRAVEL_BOOK_419
  as projection on ZR_TRAVEL_BOOK_419
{
  @UI.facet: [
    {
      id: 'BookingDetails',
      purpose: #STANDARD,
      type: #IDENTIFICATION_REFERENCE,
      label: 'Booking Details',
      position: 10
    }
  ]

  // Action Buttons ko Table Toolbar aur Detail Page par define kiya
  @UI.lineItem: [
    { position: 10, label: 'Booking ID' },
    { type: #FOR_ACTION, dataAction: 'approveBooking', label: 'Approve' },
    { type: #FOR_ACTION, dataAction: 'rejectBooking', label: 'Reject' },
    { type: #FOR_ACTION, dataAction: 'cancelBooking', label: 'Cancel' },
    { type: #FOR_ACTION, dataAction: 'completeJourney', label: 'Complete Journey' }
  ]
  @UI.identification: [
    { position: 10, label: 'Booking ID' },
    { type: #FOR_ACTION, dataAction: 'approveBooking', label: 'Approve' },
    { type: #FOR_ACTION, dataAction: 'rejectBooking', label: 'Reject' },
    { type: #FOR_ACTION, dataAction: 'cancelBooking', label: 'Cancel' },
    { type: #FOR_ACTION, dataAction: 'completeJourney', label: 'Complete Journey' }
  ]
  @Search.defaultSearchElement: true
  @EndUserText.label: 'Booking ID' // <-- Yeh line humne add kar di hai
  key BookingId,

  @UI.lineItem: [{ position: 20, label: 'Customer Name' }]
  @UI.identification: [{ position: 20, label: 'Customer Name' }]
  @Search.defaultSearchElement: true
  CustomerName,

  @UI.lineItem: [{ position: 30, label: 'Travel Date' }]
  @UI.identification: [{ position: 30, label: 'Travel Date' }]
  @UI.selectionField: [{ position: 20 }] 
  TravelDate,

  @UI.lineItem: [{ position: 35, label: 'Return Date' }]
  @UI.identification: [{ position: 35, label: 'Return Date' }]
  ReturnDate,

  @UI.lineItem: [{ position: 40, label: 'Destination' }]
  @UI.identification: [{ position: 40, label: 'Destination' }]
  @UI.selectionField: [{ position: 30 }]
  @Consumption.valueHelpDefinition: [{ entity: { name: 'ZI_COUNTRY_VH_419', element: 'Country' } }]
  Destination,

  @UI.identification: [{ position: 42, label: 'Email' }]
  Email,

  @UI.identification: [{ position: 45, label: 'Seats' }]
  Seats,

  @UI.lineItem: [{ position: 50, label: 'Booking Fee' }]
  @UI.identification: [{ position: 50, label: 'Booking Fee' }]
  @Semantics.amount.currencyCode: 'CurrencyCode'
  BookingFee,

  CurrencyCode,

  @UI.lineItem: [{ position: 60, label: 'Status', criticality: 'StatusCriticality' }]
  @UI.identification: [{ position: 60, label: 'Status', criticality: 'StatusCriticality' }]
  @UI.selectionField: [{ position: 10 }]
  Status,

  StatusCriticality,

  LocalLastChangedAt
}
