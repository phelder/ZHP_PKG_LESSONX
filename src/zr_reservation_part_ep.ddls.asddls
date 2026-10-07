@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Reservation Participant'

define view entity ZR_Reservation_Part_EP
  as select from zrespart_ep as Participant

  association to parent ZR_RESERVATION_EP as _Reservation on $projection.ReservationUuid = _Reservation.Uuid

{
      _Reservation,

  key Participant.participant_uuid      as ParticipantUuid,
      Participant.reservation_uuid      as ReservationUuid,
      Participant.participant_no        as ParticipantNo,
      Participant.participant_name      as ParticipantName,
      Participant.participant_email     as ParticipantEmail,
      Participant.participant_role      as ParticipantRole,

      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      Participant.local_last_changed_at as LocalLastChangedAt
}
