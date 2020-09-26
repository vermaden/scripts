#! /bin/sh

if ! kldstat | grep -q acpi_ibm.ko
then
  doas kldload acpi_ibm 1> /dev/null 2> /dev/null
fi

doas sysctl dev.acpi_ibm.0.fan=0 1> /dev/null 2> /dev/null

TEMP=$( sysctl -n hw.acpi.thermal.tz0.temperature | awk -F'.' '{print $1}' )

[ ${TEMP} -lt 50 ] && doas sysctl dev.acpi_ibm.0.fan_level=0 1> /dev/null 2> /dev/null && exit 0
[ ${TEMP} -lt 60 ] && doas sysctl dev.acpi_ibm.0.fan_level=1 1> /dev/null 2> /dev/null && exit 0
[ ${TEMP} -lt 70 ] && doas sysctl dev.acpi_ibm.0.fan_level=3 1> /dev/null 2> /dev/null && exit 0
[ ${TEMP} -lt 80 ] && doas sysctl dev.acpi_ibm.0.fan_level=5 1> /dev/null 2> /dev/null && exit 0
[ ${TEMP} -gt 80 ] && doas sysctl dev.acpi_ibm.0.fan_level=7 1> /dev/null 2> /dev/null && exit 0
