#!/usr/bin/bash
dbicdump -o dump_directory=. -o components='["InflateColumn::DateTime"]' DjakaWeb::DjakartaDB dbi:SQLite:../DB/djaka.db  '{ quote_char => "\"" }'

