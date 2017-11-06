

# Setup

You will need:

* ruby (tested on 2.0+, may still work on 1.9.3+ but untested)
* rubygems
* bundler (gem install bundler)

To set up the dependencies, clone this repo, then from the top-level directory:

```
bundle install
```

## Native gem compiler errors

If you see errors compiling native gems (for instance "could not create Makefile for some reason"),
you may be missing some required dev libraries. We've seen this when installing on a fresh alpine linux
Docker container, and it was fixed by installing the 'build-base' alpine package (including gcc, make, etc) - check the c compiler libraries on your distribution as appropriate.

## Environment Variables

You'll also need the following environment variables:

```
NOMIS_API_BASE_URL            - the root URL of the API you want to hit
                                e.g. https://noms-api-preprod.dsd.io/nomisapi
NOMIS_API_CLIENT_TOKEN_FILE   - path to your client token file
NOMIS_API_CLIENT_KEY_FILE     - path to your client (private) key file
```

You can obtain a client token, and guidance on how to generate a suitable client key, from:
https://nomis-api-access.service.justice.gov.uk/

# Usage

To run the main utility:

```
bundle exec ruby api_gateway_perf_test.rb (params)
```

For details of the params available, supply -h or --help :

```
bundle exec ruby api_gateway_perf_test.rb --help
```

## Modes

There are two modes in which this utility can be run: ad-hoc, or batch. 


### Ad-hoc Hits

In Ad-hoc mode, sensible defaults are used, but can be overridden by command-line parameters
(url: NOMIS_API_BASE_URL/foobar, concurrent users: 1, requests per user:1, interval between users:1, interval between requests: 1)

You can perform an ad-hoc series of requests as follows:

```
# hit a non-existent 'foobar' endpoint on the app server once:
bundle exec ruby api_gateway_perf_test.rb 

# hit a particular URL once: 
bundle exec ruby api_gateway_perf_test.rb  -u https://appgw.t3.nomis-api.hmpps.dsd.io/nomisapi/foobar

# simulate 5 concurrent users hitting a particular URL twice each: 
bundle exec ruby api_gateway_perf_test.rb  -c5 -n2 -u https://appgw.t3.nomis-api.hmpps.dsd.io/nomisapi/foobar

# simulate 5 concurrent users hitting a 'foobar' URL twice each, pausing 1s between each request, and 7s between each user starting up: 
bundle exec ruby api_gateway_perf_test.rb  -c5 -n2 -i1 -r7
```

### Batch mode

In running performance tests on our environments, it has proved useful to simulate particular situations - for instance expected usage patterns for digital prisons, or the top 10 most-used endpoints from production for increasing numbers of concurrent users. 

To this end, we've encapsulated these scenarios in 'batches' (see batches.rb)
Each batch has a label, and can optionally provide values for:
* all of the avaialable command-line parameters
* a set of endpoints from which each request will choose a random element to hit

You can supply a batch, or a comma-separated list of batches, with the -b parameter.
Each batch must be a top-level key in the BATCHES hash (defined in batches.rb).

Examples:

```
# simulate the load expected from the roll-out at Berwyn prison:
bundle exec ruby ./api_gateway_perf_test.rb -b berwyn

# run all t3 batches with 50 concurrent users, 5 requests per user
bundle exec ruby ./api_gateway_perf_test.rb -b t3_visits,t3_accounts,t3_events,t3_active_offender -n5 -c50
```