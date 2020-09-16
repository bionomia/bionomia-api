# Bionomia-API
Sinatra app for API behind Bionomia, which is used to parse people names from structured biodiversity occurrence data, apply basic regular expressions and heuristics to disambiguate them, and then allow them to be claimed by authenticated users via [ORCID](https://orcid.org). Authenticated users may also help other users that have either ORCID or Wikidata identifiers. The web application lives at [https://bionomia.net](https://bionomia.net).

[![Build Status](https://travis-ci.org/bionomia/bionomia-api.svg?branch=master)](https://travis-ci.org/bionomia/bionomia-api)

## End User Documentation

See [https://bionomia.net/developers](https://bionomia.net/developers) on Search, Parsing and access to structured data. See [https://bionomia.net/parse](https://bionomia.net/parse) to try the parser and see [https://bionomia.net/reconcile](https://bionomia.net/reconcile) on making use of the reconciliation  endpoint in OpenRefine and as an add-on in Google Sheets.

## Development Requirements

1. ruby 2.7.1+
2. Elasticsearch 7.6.1+
