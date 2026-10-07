@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'data def root'
define root view entity ZR_RESERVATION_EP
  as select from zresv_ep as Reservation
  
    composition [0..*] of ZR_Reservation_Part_EP as _Participants
  
{
    _Participants,
  key Reservation.uuid                  as Uuid,

      Reservation.reservation_no        as ReservationNo,
      Reservation.customer_name         as CustomerName,
      Reservation.customer_email        as CustomerEmail,
      Reservation.workshop_code         as WorkshopCode,
      Reservation.reservation_date      as ReservationDate,
      Reservation.status                as Status,

      @Semantics.amount.currencyCode: 'CurrencyCode'
      Reservation.fee                   as Fee,
      Reservation.currency_code         as CurrencyCode,

      Reservation.notes                 as Notes,
      
      Reservation.responsible_user      as ResponsibleUser,

      @Semantics.user.createdBy: true
      Reservation.local_created_by      as LocalCreatedBy,

      @Semantics.systemDateTime.createdAt: true
      Reservation.local_created_at      as LocalCreatedAt,

      @Semantics.user.localInstanceLastChangedBy: true
      Reservation.local_last_changed_by as LocalLastChangedBy,

      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      Reservation.local_last_changed_at as LocalLastChangedAt,

      @Semantics.systemDateTime.lastChangedAt: true
      Reservation.last_changed_at       as LastChangedAt

}
