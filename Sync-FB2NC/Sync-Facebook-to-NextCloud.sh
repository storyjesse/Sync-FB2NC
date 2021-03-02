#!/usr/bin/bash

#
# DOWNLOAD THE DATA
#

# Load settings and credentials
source ~/.local/share/WW-scripts/Sync-Facebook-to-NextCloud.conf

# Download Facebook Events In .ics format
curl --basic --user "${login}" "${FB_URL}"  | iconv -t UTF-8 -o facebook.ics -

# Download NextCloud Events In .ics format
curl --request REPORT \
     --header "Depth: 1" \
     --header "Content-Type: text/xml" \
     --data '<c:calendar-query xmlns:d="DAV:" xmlns:c="urn:ietf:params:xml:ns:caldav">
               <d:prop><d:getetag /><c:calendar-data /></d:prop> 
               <c:filter>
                 <c:comp-filter name="VCALENDAR">
                   <c:comp-filter name="VEVENT">
                     <c:time-range  start="20200130T000000" end="20200228T000000"/>
                   </c:comp-filter>
                 </c:comp-filter>
               </c:filter>
             </c:calendar-query>' \
     --user "${caldav_user}":"${caldav_pass}" "${calendar_url}" | iconv -t UTF-8 -o nextcloud.ics -

# Remove xml data from nextcloud.ics
sed -i 's/^<.*>//' nextcloud.ics

# IMPROVEMENTS: Extract the correct head from nextcloud.ics
#  file="nextcloud.ics"

#  # Get the first full VCALENDAR section
#  bcal=($(grep -n -m 1 BEGIN:VCALENDAR "${file}" | cut -d: -f1))
#  ecal=($(grep -n -m 1 END:VCALENDAR "${file}" | cut -d: -f1))

#  # Get the first VEVENT section
#  bevents=($(grep -n -m 1 BEGIN:VEVENT "${file}" | cut -d: -f1))

#  eevents=($(grep -n -m 1 BEGIN:VEVENT "${file}" | tail -1 | cut -d: -f1))

#  header=($(sed -n ${bcal[$i]},${bevents[$i]}p "${file}"))

header="BEGIN:VCALENDAR
VERSION:2.0
BEGIN:VTIMEZONE
TZID:Australia/Perth
BEGIN:STANDARD
TZOFFSETFROM:+0800
TZOFFSETTO:+0800
TZNAME:AWST
DTSTART:19700101T000000
END:STANDARD
END:VTIMEZONE"

footer="END:VCALENDAR"

#
# Split facebook.ics file into individual events
#
separate_events() {

  file="${1}"
  path="${2}"

  # If it doesn't exist make a folder/path to keep these individual events in
  [[ -e "${path}" ]] || mkdir -p "${path}"

  # First remove (CR) Carriage Return (Windows) Characters from the file
  sed -i 's/\x0D$//' "${file}"

  # Get the begining and end Line Numbers for the Vevents
  bevents=($(grep -n BEGIN:VEVENT "${file}" | cut -d: -f1))
  eevents=($(grep -n END:VEVENT "${file}" | cut -d: -f1))

#  ehead=${bevents[0]}
#  let "ehead -= 1"

#  bfoot=$(wc -l < "${file}")
#  let "bfoot -= ${eevents[-1]}"

  for (( i=0; i < ${#bevents[@]}; i++))
  do
	event_uuid=$(sed -n "${bevents[$i]},${eevents[$i]} s/UID://p" "${file}")	# extract uid for event
    echo "${header}" > "${path}/${event_uuid}.ics"
    sed -n ${bevents[$i]},${eevents[$i]}p "${file}" >> "${path}/${event_uuid}.ics"
    echo "${footer}" >> "${path}/${event_uuid}.ics"
  done
}


# Call the separate_events function "filename" "output path"
separate_events "facebook.ics" "./facebook"
separate_events "nextcloud.ics" "./nextcloud"

# Upload individual facebook events to nextcloud CalDav server
  path="./facebook"
  # get list of files excluding nextcloud.ics & facebook.ics
  for event in $(ls -I facebook.ics -I nextcloud.ics "${path}")
  do
../calendar-cli/calendar-cli.py --caldav-user="${caldav_user}" --caldav-pass="${caldav_pass}" --caldav-url="${caldav_url}" --calendar-url="${calendar_url}" calendar addics --file "${path}/${event}"
  done

exit

####
# IMPROVEMENTS
#
# calcurse-caldav creates a so-called synchronization database at ~/.calcurse/caldav/sync.db that always keeps a snapshot of the last time the script was executed. When running the script, it compares the objects on the server and the local objects with that snapshot to identify items that were added or deleted. It then
#
#    downloads new objects from the server and imports them into calcurse,
#
#    deletes local objects that no longer exist on the server,
#
#    uploads objects to the server that were added locally,
#
#    deleted objects from the server that were deleted locally,
#
#    updates the synchronization database with a new snapshot.
