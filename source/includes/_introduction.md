# Code Generation

Swagger is available to both view and download as JSON. You can find Swagger-UI [here](https://h.app.wdesk.com/s/cerebral/swagger-ui.html) and the JSON file [here](https://h.app.wdesk.com/s/cerebral/v2/api-docs).

# Credentials

The Workiva Developer API is secured using an OAuth 2.0 [Client Credentials Grant](https://tools.ietf.org/html/rfc6749#section-4.4) implementation. This authentication flow follows three steps:

1. Obtain a client id and client secret. Steps on doing this can be found in the [Workiva developer guide](https://success.workiva.com/developers/guides/setup).
2. Using the client id and client secret, make a POST request to the `oauth2/token` endpoint to exchange these credentials for a bearer token.
3. When accessing the REST API, use the bearer token to authenticate.

Keep in mind that the consumer key/secret pair and the bearer token itself grant access to make requests on your behalf. These values should be considered as sensitive as passwords and must not be shared or distributed to untrusted parties.

This manner of authentication is only secure if SSL is used. Therefore, all requests must use HTTPS.

Authentication is handled on a different host than the rest of the api documentation, which can be found at `api.app.wdesk.com`. 

## Making Authenticated Requests

### Step 1. Obtain a Client Id and Client Secret

First, make sure you have your client id and client secret handy. Store these somewhere safe.

> Example request:

```json
POST /iam/v1/oauth2/token HTTP/1.1
Host: api.app.wdesk.com
Content-Type: application/x-www-form-urlencoded;charset=UTF-8
client_id=<your-client-id>&client_secret=<your-client-secret>&grant_type=client_credentials

```

> Example response:

```json
HTTP/1.1 200 OK
Content-Type: application/json
Date: Thu, 19 Jan 2017 19:41:37 GMT
{
    "access_token": "ey...",
    "expires_in": 599,
    "scope": "scope",
    "token_type": "Bearer"
}
```

### Step 2. Exchange Client Credentials for a Bearer Token

The client id and client secret must be exchanged for a bearer token by issuing a POST request to `/iam/v1/oauth2/token`:

* The request must be a HTTPS POST request.
* The request must include a Content-Type header with the value of `application/x-www-form-urlencoded;charset=UTF-8`.
* The body of the request must include `client_id=<your-client-id>`, `client_secret=<your-client-secret>`, and `grant_type=client_credentials`.

**Need to put in example request and example response**

The value associated with the `access_token` field in the response is the bearer token to use on subsequent requests.

> Example request:

```json
GET /api/v1/table HTTP/1.1
Host: h.app.wdesk.com/s/cerebral
Authorization: Bearer ey...
```

### Step 3. Authenticate API requests with the Bearer Token

The bearer token obtained in Step 2 is used to issue requests to Workiva Developer API endpoints. To use the bearer token, construct a normal HTTPS request and include an Authorization header with the value of `Bearer <your-bearer-token>`.
