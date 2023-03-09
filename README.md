[VocalVoters.com](https://vocalvoters.com)
==========

Generate & Send a Letter, Fax or E-Mail Your Government Representatives in 30 Seconds or Less.

How well does it work? See the example below, generated with the prompt: `Free candy on mondays`

![Screenshot from 2023-03-09 12-32-40](https://user-images.githubusercontent.com/1498748/224122005-83166520-8ecf-4fbf-91e1-67cc6a402b27.png)


------------------------

### Why Vocal Voters?

If you live in the United States, do you know your representatives name? How about your state representative or senator? How about your state Attorney General?

If you don't know, that's alright -- that's why you have [VocalVoters.com](https://vocalvoters.com)!

The objective is to enable anyone to easily communicate with their representative(s) with as little friction as possible. To be frank, you don't even need to know who representats you, because we figure it out for you. Further, utilizing your billing information from your credit card, we can verify you live in representatives district. Implying your representative should weight your voice accordingly (i.e. more than Twitter).

------------------------

## Setup

Required environment variables for 3rd party services / API keys:

[geocode.io](https://geocod.io/) - used to determine the district(s) of a given address

```
export GEOCODIO_API_KEY=
```

[clicksend](https://clicksend.com/) - used to send a Letter, Fax or Email
```
export CLICKSEND_USERNAME=
export CLICKSEND_PASSWORD=
```

[stripe](https://stripe.com/) - used for payment processing
```
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

### Initial Setup

1. Launch application, no users or organizations will be present
2. Signup with a user account
3. Log into database and make user admin (authenticate if you have not done so)
4. Create an organization (e.g. "VocalVoters")
5. Go to user profile and add to organization
6. Create new letters


### Disclaimers

None of the letters we host represent the opinions of the authors, creators, committers or even users of Vocal Voters.
