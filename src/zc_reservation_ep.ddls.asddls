@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Reservation Service Projection'
@Metadata.allowExtensions: true
@Search.searchable: true

define root view entity ZC_Reservation_EP
  provider contract transactional_query
  as projection on ZR_RESERVATION_EP
{
    _Participants : redirected to composition child ZC_Reservation_Part_EP,
    
  key Uuid,

      @Search.defaultSearchElement: true
      ReservationNo,

      @Search.defaultSearchElement: true
        @Search.fuzzinessThreshold: 0.7
      CustomerName,

        @Semantics.eMail.address: true
      CustomerEmail,
      WorkshopCode,
      ReservationDate,
      Status,
      ResponsibleUser,

      Fee,

      @Consumption.valueHelpDefinition: [
        {
          entity: {
            name: 'I_CurrencyStdVH',
            element: 'Currency'
          },
          useForValidation: true
        }
      ]
      CurrencyCode,

      Notes,
      LocalCreatedBy,
      LocalCreatedAt,
      LocalLastChangedBy,
      LocalLastChangedAt,
      LastChangedAt
}
