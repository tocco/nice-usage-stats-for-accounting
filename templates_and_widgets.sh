#!/bin/bash

psql -U postgres -h localhost -wqAtX0 -c "select datname from pg_database where datallowconn and datname not like '%test' order by datname" \
    | while read -d '' name; do
        echo "+++++++++++++++++++++ $name +++++++++++++++++++++";
        echo
        "$1" -w -H localhost --run FlowAndWidgetSearch -- "$name";
        echo
done
