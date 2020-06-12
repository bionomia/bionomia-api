# Bionomia-API
Sinatra app for API behind Bionomia, which is used to parse people names from structured biodiversity occurrence data, apply basic regular expressions and heuristics to disambiguate them, and then allow them to be claimed by authenticated users via [ORCID](https://orcid.org). Authenticated users may also help other users that have either ORCID or Wikidata identifiers. The web application lives at [https://bionomia.net](https://bionomia.net).

[![Build Status](https://travis-ci.org/bionomia/bionomia-api.svg?branch=master)](https://travis-ci.org/bionomia/bionomia-api)

## Requirements

1. ruby 2.6.3+
2. Elasticsearch 7.6.1+
