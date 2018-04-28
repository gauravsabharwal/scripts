#!/bin/bash
# Shell script to generate CSV report from SQL query
# and email to a list of users via email
# 
# http://www.opentechshed.com/?p=145&preview=true for associated blog post
#
# Requirements
# 1. Mailgun account
# 2. curl
# 3. psql
# 4. Authentication setup using pgpass
#
# Run using cron. Example below
#
# “At 04:00 on Saturday.”
# 0 4 * * 5 /bin/bash /path/to/psqlReport.sh

#--- Start Email related variables ---#
# Add a comma separate list of email addresses
to='user1@example.com'

# The from email address
from='user2@example.com'

# Subject
subject='My adhoc report'

#Any text that should be part of the email
text='Please find attached the adhoc report.'

#The report file - This should be a friendly name
# of the csv file that is generated by the SQL query
reportFile='givemeafriendlyname.csv'
#--- End Email related variables ---#

#--- Start PostgreSQL related variables ---#
#PostgreSQL Database Server IP/Hostname
pserver='192.168.1.2'

#PostgreSQL Database Name
pdb='dbname'

#PostgreSQL Database Server Username
puser='pgsqluser'

#SQL query to execute; replace with what makes sense to you.
pquery='COPY (SELECT ts AS Timestamp, orderid AS Order, qty AS Quantity, sale AS Sale FROM orderlog LIMIT 10) TO STDOUT WITH CSV HEADER'
#--- End PostgreSQL related variables ---#

#--- Start mailgun related variables ---#
# Mailgun API key
mapikey='key-REPLACE-WITH-YOUR-OWN-KEY'

# Mailgun domain - Replace with your domain name
mdomain='mailgun.example.com'

# Mailgun URL
murl="https://api.mailgun.net/v3/$mdomain/messages"

#--- End mailgun related variables ---#

# Cron-friendly: Automaticaly change directory to the current one
cd $(dirname "$0")

# Current script filename
SCRIPTNAME=$(basename "$0")

# Dump report based on SQL query to $reportFile.
# Report has header as per the query.
$output=$(psql -U $puser -h $pserver -d $pdb -c "$pquery" > $reportFile)

# Send mail via mailgun
sendmail=$(curl -s --user api:$mapikey $murl -F from="$from" -F to="$to" -F subject="$subject" -F text="$text" -F h:Reply-To="$from" -F attachment="@$reportFile")
