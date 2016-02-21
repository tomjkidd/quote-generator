[Google Signing](https://developers.google.com/identity/sign-in/web/backend-auth)

# There are 2 methods

## Method 1 uses the `tokeninfo` endpoint
A POST to the `tokeninfo` endpoint will give you back formatted data that will contain information needed to ensure that a user is who they say they are.

* Use https://www.googleapis.com/oauth2/v3/tokeninfo as the base url
* Use id_token=<token-from-signin> as a query parameter

        https://www.googleapis.com/oauth2/v3/tokeninfo?id_token=<token-from-signin>

The response comes back formatted like this

{
 "iss": "accounts.google.com",
 "at_hash": "z7wiyOuYnJxW4H5int-yWw",
 "aud": "340643924958-ihudkoaue6b2h19j95oui5rs28ebd20l.apps.googleusercontent.com",
 "sub": "103058702170230576622",
 "email_verified": "true",
 "azp": "340643924958-ihudkoaue6b2h19j95oui5rs28ebd20l.apps.googleusercontent.com",
 "email": "tomjkidd@gmail.com",
 "iat": "1456095890",
 "exp": "1456099490",
 "name": "Tom Kidd",
 "given_name": "Tom",
 "family_name": "Kidd",
 "locale": "en",
 "alg": "RS256",
 "kid": "62202de2ca18a4dcb0aa7a0565e93f25789b3e2d"
}

How does this data need to be analyzed?

* `aud` should be verified that it has the expected google client id.
* `email` should contain a valid email address that can be validated on.
* `email_verified` should be "true"
* `name` might be nice on the client to let the user know who we've identified them as.
