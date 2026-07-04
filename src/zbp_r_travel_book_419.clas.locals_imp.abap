CLASS lhc_Booking DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR Booking RESULT result.

    METHODS setInitialValues FOR DETERMINE ON MODIFY
      IMPORTING keys FOR Booking~setInitialValues.

    METHODS validatePassenger FOR VALIDATE ON SAVE
      IMPORTING keys FOR Booking~validatePassenger.

    METHODS validateDates FOR VALIDATE ON SAVE
      IMPORTING keys FOR Booking~validateDates.

    METHODS validatePrice FOR VALIDATE ON SAVE
      IMPORTING keys FOR Booking~validatePrice.

    METHODS approveBooking FOR MODIFY
      IMPORTING keys FOR ACTION Booking~approveBooking RESULT result.

    METHODS rejectBooking FOR MODIFY
      IMPORTING keys FOR ACTION Booking~rejectBooking RESULT result.

    METHODS cancelBooking FOR MODIFY
      IMPORTING keys FOR ACTION Booking~cancelBooking RESULT result.

    METHODS completeJourney FOR MODIFY
      IMPORTING keys FOR ACTION Booking~completeJourney RESULT result.

    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR Booking RESULT result.
ENDCLASS.

CLASS lhc_Booking IMPLEMENTATION.
  METHOD get_global_authorizations.
    result-%create = if_abap_behv=>auth-allowed.
    result-%update = if_abap_behv=>auth-allowed.
    result-%delete = if_abap_behv=>auth-allowed.
  ENDMETHOD.

  METHOD setInitialValues.
    " Read current records
    READ ENTITIES OF ZR_TRAVEL_BOOK_419 IN LOCAL MODE
      ENTITY Booking
        FIELDS ( Status CurrencyCode TravelDate )
        WITH CORRESPONDING #( keys )
      RESULT DATA(bookings).

    LOOP AT bookings ASSIGNING FIELD-SYMBOL(<booking>).
      " Status default 'N' (New)
      IF <booking>-Status IS INITIAL.
        <booking>-Status = 'N'.
      ENDIF.

      " Currency default 'PKR'
      IF <booking>-CurrencyCode IS INITIAL.
        <booking>-CurrencyCode = 'PKR'.
      ENDIF.

      " Travel Date default to Today if initial
      IF <booking>-TravelDate IS INITIAL.
        <booking>-TravelDate = cl_abap_context_info=>get_system_date( ).
      ENDIF.
    ENDLOOP.

    " Update back
    MODIFY ENTITIES OF ZR_TRAVEL_BOOK_419 IN LOCAL MODE
      ENTITY Booking
        UPDATE FIELDS ( Status CurrencyCode TravelDate )
        WITH VALUE #( FOR b IN bookings (
                        %tky         = b-%tky
                        Status       = b-Status
                        CurrencyCode = b-CurrencyCode
                        TravelDate   = b-TravelDate
                      ) )
      REPORTED DATA(lt_reported).
  ENDMETHOD.

  " 2. Validation: Passenger, Email & Seats Checks
  METHOD validatePassenger.
    READ ENTITIES OF ZR_TRAVEL_BOOK_419 IN LOCAL MODE
      ENTITY Booking
        FIELDS ( CustomerName Email Seats )
        WITH CORRESPONDING #( keys )
      RESULT DATA(bookings).

    LOOP AT bookings ASSIGNING FIELD-SYMBOL(<booking>).
      " Passenger Name Empty Check
      IF <booking>-CustomerName IS INITIAL.
        APPEND VALUE #( %tky = <booking>-%tky ) TO failed-booking.
        APPEND VALUE #( %tky = <booking>-%tky
                        %msg = new_message_with_text( severity = if_abap_behv_message=>severity-error text = 'Passenger Name cannot be empty.' )
                        %element-customername = if_abap_behv=>mk-on ) TO reported-booking.
      ENDIF.

      " Minimum 1 Seat Check
      IF <booking>-Seats < 1.
        APPEND VALUE #( %tky = <booking>-%tky ) TO failed-booking.
        APPEND VALUE #( %tky = <booking>-%tky
                        %msg = new_message_with_text( severity = if_abap_behv_message=>severity-error text = 'Seats must be minimum 1.' )
                        %element-seats = if_abap_behv=>mk-on ) TO reported-booking.
      ENDIF.

      " Email Validation (Contains '@' symbol)
     IF <booking>-Email IS NOT INITIAL AND NOT <booking>-Email CS '@'.
        APPEND VALUE #( %tky = <booking>-%tky ) TO failed-booking.
        APPEND VALUE #( %tky = <booking>-%tky
                        %msg = new_message_with_text( severity = if_abap_behv_message=>severity-error text = 'Please enter a valid Email Address.' )
                        %element-email = if_abap_behv=>mk-on ) TO reported-booking.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  " 2. Validation: Dates Checks (Past Date & Return Date)
  METHOD validateDates.
    READ ENTITIES OF ZR_TRAVEL_BOOK_419 IN LOCAL MODE
      ENTITY Booking
        FIELDS ( TravelDate ReturnDate )
        WITH CORRESPONDING #( keys )
      RESULT DATA(bookings).

    DATA(lv_today) = cl_abap_context_info=>get_system_date( ).

    LOOP AT bookings ASSIGNING FIELD-SYMBOL(<booking>).
      " Travel Date Past Check
      IF <booking>-TravelDate IS NOT INITIAL AND <booking>-TravelDate < lv_today.
        APPEND VALUE #( %tky = <booking>-%tky ) TO failed-booking.
        APPEND VALUE #( %tky = <booking>-%tky
                        %msg = new_message_with_text( severity = if_abap_behv_message=>severity-error text = 'Travel date cannot be in the past.' )
                        %element-traveldate = if_abap_behv=>mk-on ) TO reported-booking.
      ENDIF.

      " Return Date Before Travel Date Check
      IF <booking>-ReturnDate IS NOT INITIAL AND <booking>-ReturnDate < <booking>-TravelDate.
        APPEND VALUE #( %tky = <booking>-%tky ) TO failed-booking.
        APPEND VALUE #( %tky = <booking>-%tky
                        %msg = new_message_with_text( severity = if_abap_behv_message=>severity-error text = 'Return date cannot be before travel date.' )
                        %element-returndate = if_abap_behv=>mk-on ) TO reported-booking.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  " 2. Validation: Price Check (>0)
  METHOD validatePrice.
    READ ENTITIES OF ZR_TRAVEL_BOOK_419 IN LOCAL MODE
      ENTITY Booking
        FIELDS ( BookingFee )
        WITH CORRESPONDING #( keys )
      RESULT DATA(bookings).

    LOOP AT bookings ASSIGNING FIELD-SYMBOL(<booking>).
      IF <booking>-BookingFee <= 0.
        APPEND VALUE #( %tky = <booking>-%tky ) TO failed-booking.
        APPEND VALUE #( %tky = <booking>-%tky
                        %msg = new_message_with_text( severity = if_abap_behv_message=>severity-error text = 'Price must be greater than 0.' )
                        %element-bookingfee = if_abap_behv=>mk-on ) TO reported-booking.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  " 3. Action: Approve Booking (Status = 'A')
  METHOD approveBooking.
    MODIFY ENTITIES OF ZR_TRAVEL_BOOK_419 IN LOCAL MODE
      ENTITY Booking
        UPDATE FIELDS ( Status )
        WITH VALUE #( FOR key IN keys ( %tky = key-%tky Status = 'A' ) )
      FAILED DATA(lt_failed)
      REPORTED DATA(lt_reported).

    READ ENTITIES OF ZR_TRAVEL_BOOK_419 IN LOCAL MODE
      ENTITY Booking
        ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(lt_bookings).

    result = VALUE #( FOR b IN lt_bookings ( %tky = b-%tky %param = b ) ).
  ENDMETHOD.

  " 3. Action: Reject Booking (Status = 'R')
  METHOD rejectBooking.
    MODIFY ENTITIES OF ZR_TRAVEL_BOOK_419 IN LOCAL MODE
      ENTITY Booking
        UPDATE FIELDS ( Status )
        WITH VALUE #( FOR key IN keys ( %tky = key-%tky Status = 'R' ) )
      FAILED DATA(lt_failed)
      REPORTED DATA(lt_reported).

    READ ENTITIES OF ZR_TRAVEL_BOOK_419 IN LOCAL MODE
      ENTITY Booking
        ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(lt_bookings).

    result = VALUE #( FOR b IN lt_bookings ( %tky = b-%tky %param = b ) ).
  ENDMETHOD.

  " 3. Action: Cancel Booking (Status = 'C')
  METHOD cancelBooking.
    MODIFY ENTITIES OF ZR_TRAVEL_BOOK_419 IN LOCAL MODE
      ENTITY Booking
        UPDATE FIELDS ( Status )
        WITH VALUE #( FOR key IN keys ( %tky = key-%tky Status = 'C' ) )
      FAILED DATA(lt_failed)
      REPORTED DATA(lt_reported).

    READ ENTITIES OF ZR_TRAVEL_BOOK_419 IN LOCAL MODE
      ENTITY Booking
        ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(lt_bookings).

    result = VALUE #( FOR b IN lt_bookings ( %tky = b-%tky %param = b ) ).
  ENDMETHOD.

  " 3. Action: Complete Journey (Status = 'O')
  METHOD completeJourney.
    MODIFY ENTITIES OF ZR_TRAVEL_BOOK_419 IN LOCAL MODE
      ENTITY Booking
        UPDATE FIELDS ( Status )
        WITH VALUE #( FOR key IN keys ( %tky = key-%tky Status = 'O' ) )
      FAILED DATA(lt_failed)
      REPORTED DATA(lt_reported).

    READ ENTITIES OF ZR_TRAVEL_BOOK_419 IN LOCAL MODE
      ENTITY Booking
        ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(lt_bookings).

    result = VALUE #( FOR b IN lt_bookings ( %tky = b-%tky %param = b ) ).
  ENDMETHOD.

  " 4. Feature Control & 12. Read-Only After Approval
  METHOD get_instance_features.
    READ ENTITIES OF ZR_TRAVEL_BOOK_419 IN LOCAL MODE
      ENTITY Booking
        FIELDS ( Status )
        WITH CORRESPONDING #( keys )
      RESULT DATA(bookings).

    result = VALUE #( FOR b IN bookings
      ( %tky = b-%tky
        " Status-based Buttons Enable/Disable logic
        %features-%action-approveBooking   = COND #( WHEN b-Status = 'N' OR b-Status IS INITIAL THEN if_abap_behv=>fc-o-enabled ELSE if_abap_behv=>fc-o-disabled )
        %features-%action-rejectBooking    = COND #( WHEN b-Status = 'N' OR b-Status IS INITIAL THEN if_abap_behv=>fc-o-enabled ELSE if_abap_behv=>fc-o-disabled )
        %features-%action-cancelBooking    = COND #( WHEN b-Status = 'A' THEN if_abap_behv=>fc-o-enabled ELSE if_abap_behv=>fc-o-disabled )
        %features-%action-completeJourney  = COND #( WHEN b-Status = 'A' THEN if_abap_behv=>fc-o-enabled ELSE if_abap_behv=>fc-o-disabled )

        " Fields locks: Approved ('A'), Cancelled ('C'), Completed ('O'), Rejected ('R') hone par READONLY
        %features-%field-CustomerName      = COND #( WHEN b-Status = 'A' OR b-Status = 'C' OR b-Status = 'O' OR b-Status = 'R' THEN if_abap_behv=>fc-f-read_only ELSE if_abap_behv=>fc-f-unrestricted )
        %features-%field-TravelDate        = COND #( WHEN b-Status = 'A' OR b-Status = 'C' OR b-Status = 'O' OR b-Status = 'R' THEN if_abap_behv=>fc-f-read_only ELSE if_abap_behv=>fc-f-unrestricted )
        %features-%field-ReturnDate        = COND #( WHEN b-Status = 'A' OR b-Status = 'C' OR b-Status = 'O' OR b-Status = 'R' THEN if_abap_behv=>fc-f-read_only ELSE if_abap_behv=>fc-f-unrestricted )
        %features-%field-Destination       = COND #( WHEN b-Status = 'A' OR b-Status = 'C' OR b-Status = 'O' OR b-Status = 'R' THEN if_abap_behv=>fc-f-read_only ELSE if_abap_behv=>fc-f-unrestricted )
        %features-%field-BookingFee        = COND #( WHEN b-Status = 'A' OR b-Status = 'C' OR b-Status = 'O' OR b-Status = 'R' THEN if_abap_behv=>fc-f-read_only ELSE if_abap_behv=>fc-f-unrestricted )
        %features-%field-Email             = COND #( WHEN b-Status = 'A' OR b-Status = 'C' OR b-Status = 'O' OR b-Status = 'R' THEN if_abap_behv=>fc-f-read_only ELSE if_abap_behv=>fc-f-unrestricted )
        %features-%field-Seats             = COND #( WHEN b-Status = 'A' OR b-Status = 'C' OR b-Status = 'O' OR b-Status = 'R' THEN if_abap_behv=>fc-f-read_only ELSE if_abap_behv=>fc-f-unrestricted )
      ) ).
  ENDMETHOD.
ENDCLASS.
