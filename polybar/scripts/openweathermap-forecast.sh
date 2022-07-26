#!/bin/sh

get_icon() {
    case $1 in
        01*) icon="🌞";;
		02*) icon="🌤️";;
		03*) icon="☁️";;
		04*) icon="☁️";;
		09*) icon="🌧️";;
		10*) icon="🌦️";;
		11*) icon="🌩️";;
		13*) icon="❄️";;
        50*) icon="🌫️";;
		wind) icon="💨";;
		*) icon="🤷";;
	esac
    echo $icon
}

KEY="1ed5dab5baed841d690147e4c1d60b8c"
CITY="arpajon"
UNITS="metric"
SYMBOL="°C"

API="https://api.openweathermap.org/data/2.5"

if [ -n "$CITY" ]; then
    if [ "$CITY" -eq "$CITY" ] 2>/dev/null; then
        CITY_PARAM="id=$CITY"
    else
        CITY_PARAM="q=$CITY"
    fi

    current=$(curl -sf "$API/weather?appid=$KEY&$CITY_PARAM&units=$UNITS")
    forecast=$(curl -sf "$API/forecast?appid=$KEY&$CITY_PARAM&units=$UNITS&cnt=1")
else
    location=$(curl -sf https://location.services.mozilla.com/v1/geolocate?key=geoclue)

    if [ -n "$location" ]; then
        location_lat="$(echo "$location" | jq '.location.lat')"
        location_lon="$(echo "$location" | jq '.location.lng')"

        current=$(curl -sf "$API/weather?appid=$KEY&lat=$location_lat&lon=$location_lon&units=$UNITS")
        forecast=$(curl -sf "$API/forecast?appid=$KEY&lat=$location_lat&lon=$location_lon&units=$UNITS&cnt=1")
    fi
fi

if [ -n "$current" ] && [ -n "$forecast" ]; then
    current_desc=$(echo "$current" | jq -r ".weather[0].description")
    current_wind=$(echo "$current" | jq -r ".wind.speed" | cut -d "." -f 1)
    current_temp=$(echo "$current" | jq ".main.temp" | cut -d "." -f 1)
    current_icon=$(echo "$current" | jq -r ".weather[0].icon")

    forecast_temp=$(echo "$forecast" | jq ".list[].main.temp" | cut -d "." -f 1)
    forecast_icon=$(echo "$forecast" | jq -r ".list[].weather[0].icon")

    if [ "$current_temp" -gt "$forecast_temp" ]; then
        trend="↘️"
    elif [ "$forecast_temp" -gt "$current_temp" ]; then
        trend="↗️"
    else
        trend="🟰"
    fi

	echo "$(get_icon "$current_icon") "$current_desc", $current_temp$SYMBOL $(get_icon "wind") $(( $current_wind * 3600/1000 )) km/h  $trend  $(get_icon "$forecast_icon") $forecast_temp$SYMBOL"
fi
