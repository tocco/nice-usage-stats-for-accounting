# Generate a Usage Report for Accounting

A collection of scripts to determine license fees for a [Tocco Business Framework](https://www.tocco.ch/software/branchenlosungen/ubersicht)
installations. The different measurements are described with detail in the *.sql files.

These scripts have been created as part of task 62134.

## Usage Instructions

### Get a Copy of this Repository

```
git clone https://github.com/tocco/nice-usage-stats-for-accounting.git
cd nice-usage-stats-for-accounting
```

### Open an SSH Tunnel to the DB Server

```
ssh -L 5432:localhost:5432 db01master -N &
```

### Execute Queries

The easiest way to do this is to use [n2sql-on-all-dbs.py](https://git.tocco.ch/gitweb/?p=nice2.git;a=blob;f=src/bin/n2sql-on-all-dbs.py)
which executes the queries on all DB and allows to output the result is csv.

```
n2sql-on-all-dbs -U postgres -H localhost -d '.*(?<!test)$' -f generic.sql --csv >generic.csv
n2sql-on-all-dbs -U postgres -H localhost -d '.*(?<!test)$' -f cms.sql --csv >cms.csv
```

note: Both scripts will fail on some databases. `generic.sql` will fail some very old installations (pre-v2.7.5) and
`cms.sql` on all systems older than v2.10 or without CMS.

### Merge results

```sh
csvtool join 1 2-8 generic.csv cms.csv | sed 's/,*$//' > combined.csv
```

### Get List of Published Flows and Widgets

For this the existing script [list-migration-info.py](https://git.tocco.ch/gitweb/?p=nice2.git;a=blob;f=src/bin/list-migration-info.py)
can be used. You can use `templates_and_widgets.sh` in this repository which calls `list-migration-info.py` for all
databases and limits the output to published flows and widgets.

```
export PGPASSWORD="${PASSWORD_FOR_USER_POSTGRES}"

# you must specify the location of list-migration-info.py as first argument to templates_and_widgets.sh
./templates_and_widgets.sh ${PATH_TO_NICE2_REPOSITORY}/src/bin/list-migration-info.py >widget_and_flow_list.txt

unset PGPASSWORD
```

### Collect the Results

The files `generic.csv`, `cms.csv` and `widget_and_flow_list.txt` contain the results.
