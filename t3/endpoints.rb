ENDPOINTS = [
  { endpoint: "#{BASE_URL}/prison/PRISON_ID/offenders/NOMIS_ID/accounts/", method: :get },
  # DATETIME FORMAT: 2017-09-24
  { endpoint: "#{BASE_URL}/prison/PRISON_ID/offenders/NOMIS_ID/accounts/spends/transactions?from_date=2017-09-26", method: :get },
  # DATETIME FORMAT: 2017-10-24%2015:36:24.380
  { endpoint: "#{BASE_URL}/offenders/events?prison_id=PRISON_ID&from_datetime=DATETIMEENCODED", method: :get },
  { endpoint: "#{BASE_URL}/lookup/active_offender?date_of_birth=DOB&noms_id=NOMIS_ID", method: :get },
  { endpoint: "#{BASE_URL}/prison/PRISON_ID/slots?start_date=2017-11-01&end_date=2017-11-09", method: :get },
  { endpoint: "#{BASE_URL}/offenders/NOMIS_ID/visits/available_dates", method: :get },
  { endpoint: "#{BASE_URL}/offenders/NOMIS_ID/visits/restrictions", method: :get },
  { endpoint: "#{BASE_URL}/offenders/NOMIS_ID/visits/contact_list", method: :get },
  { endpoint: "#{BASE_URL}/offenders/events/case_notes_for_delius?from_datetime=DATETIMEISO", method: :get },
  { endpoint: "#{BASE_URL}/prison/PRISON_ID/offenders/NOMIS_ID/transactions/", method: :post, body: { type: "MRPR", description: "Misc credit", amount: 1, client_transaction_id: "1234", client_unique_ref: "foobar" } },
]
