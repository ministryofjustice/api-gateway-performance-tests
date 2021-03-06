today = Time.now.to_date.to_s
one_week_from_today = (Time.now + 7*24*3600).to_date.to_s
one_week_ago = (Time.now - 7*24*3600).to_date.to_s

BATCHES = {
  default: [
    { label: 'default', number_of_requests: 1 }
  ],
  berwyn: [
    { label: 'Berwyn GET balances', number_of_users: 20,
      number_of_requests: 49, interval_between_requests: 74 },
    { label: 'Berwyn GET tx history', number_of_users: 10,
      number_of_requests: 19, interval_between_requests: 191 },
    { label: 'Berwyn POST tx', number_of_users: 15,
      number_of_requests: 53, interval_between_requests: 69 },
    { label: 'Berwyn POST pay event', number_of_users: 15,
      number_of_requests: 18, interval_between_requests: 204 }
  ],
  weyland: [
    { label: 'Weyland GET balances', number_of_users: 10,
      number_of_requests: 41, interval_between_requests: 89 },
    { label: 'Weyland GET tx history', number_of_users: 5,
      number_of_requests: 11, interval_between_requests: 340 },
    { label: 'Weyland POST tx', number_of_users: 10,
      number_of_requests: 35, interval_between_requests: 102 },
    { label: 'Weyland POST pay event', number_of_users: 5,
      number_of_requests: 24, interval_between_requests: 151 }
  ],
  kirklevington: [
    { label: 'Kirklevington GET balances', number_of_users: 5,
      number_of_requests: 52, interval_between_requests: 70 },
    { label: 'Kirklevington GET tx history', number_of_users: 1,
      number_of_requests: 16, interval_between_requests: 225 },
    { label: 'Kirklevington POST tx', number_of_users: 2,
      number_of_requests: 35, interval_between_requests: 103 },
    { label: 'Kirklevington POST pay event', number_of_users: 3,
      number_of_requests: 62, interval_between_requests: 58 }
  ],
  durham: [
    { label: 'Durham GET balances', number_of_users: 10,
      number_of_requests: 54, interval_between_requests: 67 },
    { label: 'Durham GET tx history', number_of_users: 3,
      number_of_requests: 28, interval_between_requests: 130 },
    { label: 'Durham POST tx', number_of_users: 6,
      number_of_requests: 70, interval_between_requests: 51 },
    { label: 'Durham POST pay event', number_of_users: 8,
      number_of_requests: 117, interval_between_requests: 31 }
  ],
  holme_house: [
    { label: 'Holme House GET balances', number_of_users: 10,
      number_of_requests: 64, interval_between_requests: 56 },
    { label: 'Holme House GET tx history', number_of_users: 5,
      number_of_requests: 21, interval_between_requests: 170 },
    { label: 'Holme House POST tx', number_of_users: 5,
      number_of_requests: 90, interval_between_requests: 40 },
    { label: 'Holme House POST pay event', number_of_users: 10,
      number_of_requests: 120, interval_between_requests: 30 }
  ],
  high_down: [
    { label: 'High Down GET balances', number_of_users: 10,
      number_of_requests: 56, interval_between_requests: 64 },
    { label: 'High Down GET tx history', number_of_users: 3,
      number_of_requests: 30, interval_between_requests: 121 },
    { label: 'High Down POST tx', number_of_users: 5,
      number_of_requests: 75, interval_between_requests: 48 },
    { label: 'High Down POST pay event', number_of_users: 10,
      number_of_requests: 100, interval_between_requests: 36 }
  ],
  cookham_wood: [
    { label: 'Cookham Wood GET balances', number_of_users: 5,
      number_of_requests: 49, interval_between_requests: 73 },
    { label: 'Cookham Wood GET tx history', number_of_users: 1,
      number_of_requests: 14, interval_between_requests: 257 },
    { label: 'Cookham Wood POST tx', number_of_users: 2,
      number_of_requests: 29, interval_between_requests: 126 },
    { label: 'Cookham Wood POST pay event', number_of_users: 3,
      number_of_requests: 51, interval_between_requests: 71 }
  ],

  t3_accounts: [
    { 
      label: 'T3 GET transactions', 
      endpoints: [
        { endpoint: "#{BASE_URL}/prison/PRISON_ID/offenders/NOMIS_ID/accounts/", method: :get },
        { endpoint: "#{BASE_URL}/prison/PRISON_ID/offenders/NOMIS_ID/accounts/spends/transactions?from_date=#{one_week_ago}", method: :get }
      ]
    },
    {
      label: 'T3 POST transaction', 
      endpoints: [
        { endpoint: "#{BASE_URL}/prison/PRISON_ID/offenders/NOMIS_ID/transactions/", method: :post, body: { type: "MRPR", description: "Misc credit", amount: 1, client_transaction_id: "1234", client_unique_ref: :random_hex } }
      ]
    }
  ],
  t3_events: [
    {
      label: 'T3 GET events', 
      endpoints: [
        { endpoint: "#{BASE_URL}/offenders/events?prison_id=PRISON_ID&from_datetime=DATETIMEENCODED", method: :get }
      ]
    }
  ],
  t3_active_offender: [
    {
      label: 'T3 GET active_offender', 
      endpoints: [
        { endpoint: "#{BASE_URL}/lookup/active_offender?date_of_birth=DOB&noms_id=NOMIS_ID", method: :get },
      ]
    }
  ],
  t3_visits: [
    {
      label: 'T3 GET visit endpoints', 
      endpoints: [
        { endpoint: "#{BASE_URL}/prison/PRISON_ID/slots?start_date=#{today}&end_date=#{one_week_from_today}", method: :get },
        { endpoint: "#{BASE_URL}/offenders/OFFENDER_ID/visits/available_dates?start_date=#{today}&end_date=#{one_week_from_today}", method: :get },
        { endpoint: "#{BASE_URL}/offenders/OFFENDER_ID/visits/restrictions", method: :get },
        { endpoint: "#{BASE_URL}/offenders/OFFENDER_ID/visits/contact_list", method: :get }
      ]
    }
  ]
}.freeze