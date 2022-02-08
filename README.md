# Bionomia-API
Sinatra app for API behind Bionomia, which is used to parse people names from structured biodiversity occurrence data, apply basic regular expressions and heuristics to disambiguate them, and then allow them to be claimed by authenticated users via [ORCID](https://orcid.org). Authenticated users may also help other users that have either ORCID or Wikidata identifiers. The web application lives at [https://bionomia.net](https://bionomia.net).

[![Build Status](https://github.com/bionomia/bionomia-api/actions/workflows/ruby.yml/badge.svg)](https://github.com/bionomia/bionomia-api/actions)

## End User Documentation

See [https://bionomia.net/developers](https://bionomia.net/developers) on Search, Parsing and access to structured data. See [https://bionomia.net/parse](https://bionomia.net/parse) to try the parser and see [https://bionomia.net/reconcile](https://bionomia.net/reconcile) on making use of the reconciliation  endpoint in OpenRefine and as an add-on in Google Sheets.

## Development Requirements

1. ruby 2.7.1+
2. Elasticsearch 7.6.1+

## Synonyms File

The synonyms file for indexing of common nicknames is included in [/synonyms/synonyms.txt](synonyms/synonyms.txt) and is referenced in [https://github.com/bionomia/bionomia/blob/master/lib/elastic_user.rb](https://github.com/bionomia/bionomia/blob/master/lib/elastic_user.rb) as a relative path to the `elasticsearch.yml` configuration file, usually in `/etc/elasticsearch` on a Linux-based install. The easiest way to make use of this is to make a symlink from `/etc/elasticsearch/synonyms.txt` to this `synonyms.txt` file.

Whenever this `synonyms.txt` file is updated, the elasticsearch service must be closed and reopened as follows:

      $ curl -X POST "localhost:9200/bionomia_users/_close?pretty"
      $ curl -X POST "localhost:9200/bionomia_users/_open?pretty"
