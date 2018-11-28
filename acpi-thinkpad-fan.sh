#! /bin/sh

if ! kldstat | grep -q acpi_ibm.ko
then
  doas kldload acpi_ibm
fi

doas sysctl dev.acpi_ibm.0.fan=0 1> /dev/null 

TEMP=$( sysctl -n hw.acpi.thermal.tz0.temperature | awk -F'.' '{print $1}' )

if [ ${TEMP} -lt 50 ]
then
  doas sysctl dev.acpi_ibm.0.fan_level=0 1> /dev/null
  exit 0
fi

if [ ${TEMP} -lt 60 ]
then
  doas sysctl dev.acpi_ibm.0.fan_level=1 1> /dev/null
  exit 0
fi

if [ ${TEMP} -ge 60 ]
then
  doas sysctl dev.acpi_ibm.0.fan_level=3 1> /dev/null
  exit 0
fi


