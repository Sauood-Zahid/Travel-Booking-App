@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Booking Root View'
define root view entity ZR_TRAVEL_BOOK_419
  as select from ztravel_book_419
{
  key booking_id            as BookingId,
      customer_name         as CustomerName,
      travel_date           as TravelDate,
      return_date           as ReturnDate,
      destination           as Destination,
      email                 as Email,
      seats                 as Seats,
      @Semantics.amount.currencyCode: 'CurrencyCode'
      booking_fee           as BookingFee,
      currency_code         as CurrencyCode,
      status                as Status,
      local_last_changed_at as LocalLastChangedAt,
      
      // CASE statement ko yahan shuru mein add kiya
      case status
        when 'N' then 2
        when 'A' then 3
        when 'C' then 1
        when 'O' then 5
        else 0
      end                   as StatusCriticality,
      
      @Semantics.user.createdBy: true
      created_by            as CreatedBy,
      @Semantics.systemDateTime.createdAt: true
      created_at            as CreatedAt,
      @Semantics.user.localInstanceLastChangedBy: true
      last_changed_by       as LastChangedBy,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      last_changed_at       as LastChangedAt
}
