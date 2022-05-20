import json
import re
from datetime import datetime, timedelta

import arrow
import requests
import sys

from ics import Calendar
from ics import Event

tides_list = {}


def handler(event, context):
    global tides_list

    location = 'Broadstairs'

    try:
        location = event["queryStringParameters"]['location']
    except (IndexError, KeyError, TypeError):
        pass

    date = datetime.now()

    calendar = Calendar()
    location_to_use = location.lower()

    found = True

    # check the cache between lambda calls
    if location_to_use in tides_list:
        tide_location = tides_list[location_to_use]

        # check we have all offsets
        for offset in range(0, 7):
            current_date = date + timedelta(days=offset)

            print("CHECKING {}".format(current_date))
            found_current = False

            for k, v in tide_location.items():
                print(k.day)
                if current_date.day == k.day and current_date.month == k.month:
                    # found this date
                    print('Found {}'.format(current_date.day))
                    found_current = True
                    break

            if not found_current:
                print('Not found {}'.format(current_date.day))
                found = False

    else:
        found = False

    total_tides = []

    if not found:
        tides_list[location_to_use] = {}

    for offset in range(0, 7):
        if not found:
            print("Fetching")
            add_date_to_calendar(calendar, date, location, location_to_use,
                                 offset, total_tides,
                                 tides_list[location_to_use], store=True)
        else:
            print("Caching")
            add_date_to_calendar(calendar, date, location, location_to_use,
                                 offset, total_tides,
                                 tides_list[location_to_use], store=False)

    print("Processed {} high tides".format(len(total_tides)))

    return {
        'headers': {
            'Content-Type': 'text/calendar',
        },
        'statusCode': 200,
        'body': str(calendar)
    }


def add_date_to_calendar(calendar, date, location, location_to_use, offset,
                         total_tides, cached_tides=None, store=True):
    current_date = date + timedelta(days=offset)
    base_date = current_date.strftime('%Y%m%d')
    base_url = 'https://www.tidetimes.org.uk/{0}-tide-times-' \
               '{1}'.format(location_to_use, base_date)

    tides = []

    if store:
        tides = fetch_tide_for_day(base_url)
    else:
        for k, v in cached_tides.items():
            if k.day == current_date.day:
                tides.append(v)

    total_tides += tides

    for tide in tides:
        new_event = parse_tide(datetime.strptime(base_date, '%Y%m%d'),
                               location, tide)

        if store:
            current_date = current_date.replace(hour=int(tide.split(':')[0]),
                                                minute=int(tide.split(':')[1]))
            cached_tides[current_date] = tide

        calendar.events.add(new_event)


def parse_tide(current_date, location, start_time):
    new_event = Event()
    new_event.name = 'High Tide'
    new_event.location = location

    start_time = start_time.split(':')

    tide_time = datetime(year=current_date.year, month=current_date.month,
                         day=current_date.day,
                         hour=int(start_time[0]), minute=int(start_time[1]))

    new_event.begin = arrow.get(tide_time, 'Europe/London')
    new_event.end = arrow.get(tide_time + timedelta(hours=1), 'Europe/London')
    return new_event


def fetch_tide_for_day(url):
    html = requests.get(url)

    # you shouldn't really match regex on HTML
    # but have you seen how awful it is to get lambda to install LXML?

    highs = r'^<tr\ class=\"vis2\">$\s+<td\ class=\"tal\">High<\/td>$\s+<td\ ' \
            r'class=\"tac\"><span\>(.+?)<'
    lows = r'^<tr\ class=\"vis2\">$\s+<td\ class=\"tal\">Low<\/td>$\s+<td\ ' \
           r'class=\"tac\"><span\>(.+?)<'

    matches = re.finditer(highs, html.text, re.VERBOSE | re.MULTILINE)

    ret_array = []

    for matchNum, match in enumerate(matches, start=1):
        ret_array.append(match.group(1))

    return ret_array


if __name__ == '__main__':
    handler(None, None)
