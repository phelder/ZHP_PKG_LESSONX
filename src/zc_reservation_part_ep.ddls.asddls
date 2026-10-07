@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Reservation Participant Projection'
@Metadata.allowExtensions: true

define view entity ZC_Reservation_Part_EP
  as projection on ZR_Reservation_Part_EP
{
  key ParticipantUuid,
      ReservationUuid,
      ParticipantNo,
      ParticipantName,
      ParticipantEmail,
      ParticipantRole,
      LocalLastChangedAt,

      _Reservation : redirected to parent ZC_Reservation_EP
}
