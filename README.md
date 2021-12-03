VocalVoters.com
==========

Fax, Mail, E-Mail Your Government Representatives in 30 Seconds or Less.

=================

### Why Vocal Voters?

If you live in the United States, do you know your federal representatives name? How about your state representative or senator? How about your states Attorney General? If you don't know, that's alright -- that's why you have Vocal Voters!

The objective is to enable anyone to easily communicate with their representative(s) with as little friction as possible. To be frank, you don't even need to know who representats you, because we figure it out for you. Further, utilizing your billing information from your credit card, we can verify you live in representatives district. Implying your representative should weight your voice accordingly (i.e. more than Twitter).

===============

## Setup

Required environment variables for 3rd party services / API keys:

```
#  https://www.geocod.io/
export GEOCODIO_API_KEY=

# https://www.clicksend.com/us/
export CLICKSEND_USERNAME=
export CLICKSEND_PASSWORD=

# https://stripe.com/
export STRIPE_PUBLISHABLE_KEY_VOCALVOTERS=
export STRIPE_SECRET_KEY_VOCALVOTERS=
```

Production database setup:
```
adapter: postgresql
encoding: unicode
database: vocalvoters_production
username: vocalvoters_app
password: <%= ENV['VOCALVOTERS_DATABASE_PASSWORD'] %>
```

### Disclaimers

None of the letters we host represent the opinions of the authors, creators, committers or even users of Vocal Voters.