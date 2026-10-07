CLASS zcl_resv_main_ep DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_resv_main_ep IMPLEMENTATION.

  METHOD if_oo_adt_classrun~main.

    DATA(user) = cl_abap_context_info=>get_user_technical_name( ).

    MODIFY ENTITIES OF ZR_Reservation_EP
        ENTITY Reservation
            CREATE FIELDS (
                ReservationNo
                CustomerName
                CustomerEmail
                WorkshopCode
                ReservationDate
                Fee
                CurrencyCode
                Notes
                ResponsibleUser )
            WITH VALUE #(
                (   %cid            = 'A'
                    ReservationNo   = '98000001'
                    CustomerName    = 'John Smith'
                    CustomerEmail   = 'j.smith@example.com'
                    WorkshopCode    = 'RAP101'
                    ReservationDate = cl_abap_context_info=>get_system_date( )
                    Fee              = '150.00'
                    CurrencyCode     = 'EUR'
                    Notes            = 'Note example 1'
                    ResponsibleUser  = user )

                (   %cid            = 'B'
                    ReservationNo   = '98000002'
                    CustomerName    = 'Maxine Daman'
                    CustomerEmail   = 'maxd@example.com'
                    WorkshopCode    = 'RAP101'
                    ReservationDate = cl_abap_context_info=>get_system_date( )
                    Fee              = '175.00'
                    CurrencyCode     = 'EUR'
                    Notes            = ''
                    ResponsibleUser  = user )
                    (   %cid            = 'C'
                    ReservationNo   = '98000003'
                    CustomerName    = 'Bobbie Bob'
                    CustomerEmail   = 'bobsquared@example.com'
                    WorkshopCode    = 'RAP101'
                    ReservationDate = cl_abap_context_info=>get_system_date( )
                    Fee              = '175.00'
                    CurrencyCode     = 'EUR'
                    Notes            = ''
                    ResponsibleUser  = user )
                    (   %cid            = 'D'
                    ReservationNo   = '98000004'
                    CustomerName    = 'Jane Johnson'
                    CustomerEmail   = 'jj@example.com'
                    WorkshopCode    = 'RAP101'
                    ReservationDate = cl_abap_context_info=>get_system_date( )
                    Fee              = '175.00'
                    CurrencyCode     = 'EUR'
                    Notes            = 'demonstration'
                    ResponsibleUser  = user )

            )

        MAPPED DATA(mapped)
        FAILED DATA(failed_create)
        REPORTED DATA(reported_create).

    COMMIT ENTITIES.

  ENDMETHOD.

ENDCLASS.
