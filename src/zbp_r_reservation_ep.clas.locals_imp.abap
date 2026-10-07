CLASS lhc_Reservation DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_features FOR INSTANCE FEATURES
      keys REQUEST requested_features FOR Reservation RESULT result.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      keys REQUEST requested_authorizations FOR Reservation RESULT result.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      REQUEST requested_authorizations FOR Reservation RESULT result.

    METHODS cancel FOR MODIFY
       keys FOR ACTION Reservation~cancel RESULT result.

    METHODS confirm FOR MODIFY
       keys FOR ACTION Reservation~confirm RESULT result.

    METHODS setInitialStatus FOR DETERMINE ON MODIFY
       keys FOR Reservation~setInitialStatus.

    METHODS validateCustomer FOR VALIDATE ON SAVE
       keys FOR Reservation~validateCustomer.

    METHODS validateDate FOR VALIDATE ON SAVE
       keys FOR Reservation~validateDate.

    METHODS validateFee FOR VALIDATE ON SAVE
       keys FOR Reservation~validateFee.
    METHODS setResponsibleUser FOR DETERMINE ON MODIFY
      keys FOR Reservation~setResponsibleUser.

ENDCLASS.

CLASS lhc_Reservation IMPLEMENTATION.

  METHOD get_instance_features.

    READ ENTITIES OF ZR_Reservation_EP IN LOCAL MODE
      ENTITY Reservation
        FIELDS ( Status )
        WITH CORRESPONDING #( keys )
      RESULT DATA(reservations)
      FAILED failed.

    result = VALUE #(
      FOR reservation IN reservations
      (
        %tky = reservation-%tky

        %features-%action-confirm =
          COND #(
            WHEN reservation-Status = 'N'
            THEN if_abap_behv=>fc-o-enabled
            ELSE if_abap_behv=>fc-o-disabled
          )

        %features-%action-cancel =
          COND #(
            WHEN reservation-Status = 'N'
              OR reservation-Status = 'C'
            THEN if_abap_behv=>fc-o-enabled
            ELSE if_abap_behv=>fc-o-disabled
          )

        %features-%field-Fee =
          COND #(
            WHEN reservation-Status = 'N'
            THEN if_abap_behv=>fc-f-unrestricted
            ELSE if_abap_behv=>fc-f-read_only
          )

        %features-%field-CurrencyCode =
          COND #(
            WHEN reservation-Status = 'N'
            THEN if_abap_behv=>fc-f-unrestricted
            ELSE if_abap_behv=>fc-f-read_only
          )
      )
    ).

  ENDMETHOD.

  METHOD get_instance_authorizations.

    IF requested_authorizations-%update <> if_abap_behv=>mk-on
      AND requested_authorizations-%action-Edit <> if_abap_behv=>mk-on
      AND requested_authorizations-%delete <> if_abap_behv=>mk-on.
      RETURN.
    ENDIF.

    READ ENTITIES OF ZR_Reservation_EP IN LOCAL MODE
      ENTITY Reservation
        FIELDS ( ResponsibleUser )
        WITH CORRESPONDING #( keys )
      RESULT DATA(reservations)
      FAILED failed.

    DATA current_user TYPE abp_creation_user.
    current_user = cl_abap_context_info=>get_user_technical_name( ).

    LOOP AT reservations INTO DATA(reservation).

      DATA(is_responsible) = xsdbool( reservation-ResponsibleUser = current_user ).

      APPEND VALUE #(
          %tky = reservation-%tky
      ) TO result ASSIGNING FIELD-SYMBOL(<row>).

      IF requested_authorizations-%update = if_abap_behv=>mk-on.
        <row>-%update = COND #(
          WHEN is_responsible = abap_true THEN if_abap_behv=>auth-allowed
          ELSE if_abap_behv=>auth-unauthorized ).
      ENDIF.

      IF requested_authorizations-%action-Edit = if_abap_behv=>mk-on.
        <row>-%action-Edit = COND #(
          WHEN is_responsible = abap_true THEN if_abap_behv=>auth-allowed
          ELSE if_abap_behv=>auth-unauthorized ).
      ENDIF.

      IF requested_authorizations-%delete = if_abap_behv=>mk-on.
        <row>-%delete = COND #(
          WHEN is_responsible = abap_true THEN if_abap_behv=>auth-allowed
          ELSE if_abap_behv=>auth-unauthorized ).
      ENDIF.

      IF is_responsible = abap_false.
        APPEND VALUE #(
          %tky = reservation-%tky
          %msg = new_message_with_text(
            severity = if_abap_behv_message=>severity-error
            text     = 'You are not responsible for this reservation'
          )
        ) TO reported-reservation.
      ENDIF.

    ENDLOOP.

  ENDMETHOD.

  METHOD get_global_authorizations.

    IF requested_authorizations-%create = if_abap_behv=>mk-on.
      result-%create = if_abap_behv=>auth-allowed.
    ENDIF.

    IF requested_authorizations-%update = if_abap_behv=>mk-on.
      result-%update = if_abap_behv=>auth-allowed.
    ENDIF.

    IF requested_authorizations-%action-Edit = if_abap_behv=>mk-on.
      result-%action-Edit = if_abap_behv=>auth-allowed.
    ENDIF.

    IF requested_authorizations-%delete = if_abap_behv=>mk-on.
      result-%delete = if_abap_behv=>auth-allowed.
    ENDIF.

  ENDMETHOD.

  METHOD cancel.

    MODIFY ENTITIES OF ZR_Reservation_EP IN LOCAL MODE
      ENTITY Reservation
        UPDATE FIELDS ( Status )
        WITH VALUE #(
          FOR key IN keys
          ( %tky   = key-%tky
            Status = 'X' )
        )
      FAILED failed
      REPORTED reported.

    READ ENTITIES OF ZR_Reservation_EP IN LOCAL MODE
      ENTITY Reservation
        ALL FIELDS
        WITH CORRESPONDING #( keys )
      RESULT DATA(reservations).

    result = VALUE #(
      FOR reservation IN reservations
      ( %tky   = reservation-%tky
        %param = reservation )
    ).

  ENDMETHOD.

  METHOD confirm.

    MODIFY ENTITIES OF ZR_Reservation_EP IN LOCAL MODE
      ENTITY Reservation
        UPDATE FIELDS ( Status )
        WITH VALUE #(
          FOR key IN keys
          ( %tky   = key-%tky
            Status = 'C' )
        )
      FAILED failed
      REPORTED reported.

    READ ENTITIES OF ZR_Reservation_EP IN LOCAL MODE
      ENTITY Reservation
        ALL FIELDS
        WITH CORRESPONDING #( keys )
      RESULT DATA(reservations).

    result = VALUE #(
      FOR reservation IN reservations
      ( %tky   = reservation-%tky
        %param = reservation )
    ).

  ENDMETHOD.

  METHOD setInitialStatus.

    READ ENTITIES OF ZR_Reservation_EP IN LOCAL MODE
    ENTITY Reservation
      FIELDS ( Status )
      WITH CORRESPONDING #( keys )
    RESULT DATA(reservations).

    DATA updates TYPE TABLE FOR UPDATE ZR_Reservation_EP.

    LOOP AT reservations INTO DATA(reservation)
        WHERE status IS INITIAL.

      APPEND VALUE #(
        %tky   = reservation-%tky
        Status = 'N'
      ) TO updates.

    ENDLOOP.

    IF updates IS NOT INITIAL.

      MODIFY ENTITIES OF ZR_Reservation_EP IN LOCAL MODE
          ENTITY Reservation
              UPDATE FIELDS ( Status )
              WITH updates.
    ENDIF.


  ENDMETHOD.

  METHOD validateCustomer.

    READ ENTITIES OF ZR_Reservation_ep IN LOCAL MODE
      ENTITY Reservation
        FIELDS ( CustomerName )
        WITH CORRESPONDING #( keys )
      RESULT DATA(reservations).

    LOOP AT reservations INTO DATA(reservation).

      IF reservation-CustomerName IS INITIAL.

        APPEND VALUE #(
          %tky = reservation-%tky
        ) TO failed-reservation.

        APPEND VALUE #(
          %tky = reservation-%tky
          %msg = new_message_with_text(
            severity = if_abap_behv_message=>severity-error
            text     = 'Customer name is required'
          )
          %element-CustomerName = if_abap_behv=>mk-on
        ) TO reported-reservation.

      ENDIF.

    ENDLOOP.

  ENDMETHOD.

  METHOD validateDate.

    READ ENTITIES OF ZR_Reservation_ep IN LOCAL MODE
      ENTITY Reservation
        FIELDS ( ReservationDate )
        WITH CORRESPONDING #( keys )
      RESULT DATA(reservations).

    DATA(today) = cl_abap_context_info=>get_system_date( ).

    LOOP AT reservations INTO DATA(reservation).

      IF reservation-ReservationDate < today.

        APPEND VALUE #(
          %tky = reservation-%tky
        ) TO failed-reservation.

        APPEND VALUE #(
          %tky = reservation-%tky
          %msg = new_message_with_text(
            severity = if_abap_behv_message=>severity-error
            text     = 'Reservation date cannot be in the past'
          )
          %element-ReservationDate = if_abap_behv=>mk-on
        ) TO reported-reservation.

      ENDIF.

    ENDLOOP.

  ENDMETHOD.

   METHOD validateFee.

    READ ENTITIES OF ZR_Reservation_ep IN LOCAL MODE
      ENTITY Reservation
        FIELDS ( Fee CurrencyCode )
        WITH CORRESPONDING #( keys )
      RESULT DATA(reservations).

    LOOP AT reservations INTO DATA(reservation).

      DATA(instance_failed) = abap_false.

      IF reservation-Fee <= 0.

        instance_failed = abap_true.

        APPEND VALUE #(
          %tky = reservation-%tky
          %msg = new_message_with_text(
            severity = if_abap_behv_message=>severity-error
            text     = 'Fee must be greater than zero'
          )
          %element-Fee = if_abap_behv=>mk-on
        ) TO reported-reservation.

      ENDIF.

      IF reservation-CurrencyCode IS INITIAL.

        instance_failed = abap_true.

        APPEND VALUE #(
          %tky = reservation-%tky
          %msg = new_message_with_text(
            severity = if_abap_behv_message=>severity-error
            text     = 'Currency code is required'
          )
          %element-CurrencyCode = if_abap_behv=>mk-on
        ) TO reported-reservation.

      ENDIF.

      IF instance_failed = abap_true.
        APPEND VALUE #(
          %tky = reservation-%tky
        ) TO failed-reservation.
      ENDIF.

    ENDLOOP.

  ENDMETHOD.

METHOD setResponsibleUser.

  READ ENTITIES OF ZR_Reservation_ep IN LOCAL MODE
    ENTITY Reservation
      FIELDS ( ResponsibleUser )
      WITH CORRESPONDING #( keys )
    RESULT DATA(reservations).

  DATA updates TYPE TABLE FOR UPDATE ZR_Reservation_ep.

  DATA current_user TYPE abp_creation_user.
  current_user = cl_abap_context_info=>get_user_technical_name( ).

  LOOP AT reservations INTO DATA(reservation)
    WHERE ResponsibleUser IS INITIAL.

    APPEND VALUE #(
      %tky            = reservation-%tky
      ResponsibleUser = current_user
    ) TO updates.

  ENDLOOP.

  IF updates IS NOT INITIAL.

    MODIFY ENTITIES OF ZR_Reservation_ep IN LOCAL MODE
      ENTITY Reservation
        UPDATE FIELDS ( ResponsibleUser )
        WITH updates.

  ENDIF.

ENDMETHOD.

ENDCLASS.
