#! /usr/libexec/flua

-- Copyright (c) 2022-2023 Slawomir Wojciech Wojtczak (vermaden)
-- Copyright (c) 2022 Trix Farrar
-- Copyright (c) 2025 D. Bohdan
-- All rights reserved.
--
-- Redistribution and use in source and binary forms, with or without
-- modification, are permitted provided that following conditions are met:
-- 1. Redistributions of source code must retain the above copyright
--    notice, this list of conditions and the following disclaimer.
-- 2. Redistributions in binary form must reproduce the above copyright
--    notice, this list of conditions and the following disclaimer in the
--    documentation and/or other materials provided with the distribution.
--
-- THIS SOFTWARE IS PROVIDED BY THE AUTHOR AND CONTRIBUTORS 'AS IS' AND ANY
-- EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
-- WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
-- DISCLAIMED. IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE LIABLE FOR ANY
-- DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
-- (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
-- LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
-- ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
-- (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
-- THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
--
-- ------------------------------
-- SIMPLE SENSORS INFORMATION
-- ------------------------------
-- vermaden [AT] interia [DOT] pl
-- https://vermaden.wordpress.com

local NAME = arg[0]:match("([^/]+)$")
local WIDTH = "%38s"

-- Print usage and exit
local function usage()
	io.write("USAGE:\n")
	io.write("  ", NAME, " (without any arguments)\n\n")
	io.write("NOTES:\n")
	io.write("  load these modules to get all the temperature data:\n")
	io.write("    - amdtemp.ko\n")
	io.write("    - coretemp.ko\n\n")
	io.write("  install 'smartmontools' package for disks temperatures:\n")
	io.write("    # pkg install smartmontools\n\n")
	io.write("  you need to execute as 'root' to get disks temperatures\n")
	io.write("    # ", NAME, "\n")
	io.write("    % doas ", NAME, "\n")
	io.write("    $ sudo ", NAME, "\n\n")
end

-- SPLIT STRING s INTO NO MORE THAN max WORDS
local function split_words(s, max)
	if max == nil then
		max = 100
	end
	local pattern = "%S+"

	local t = {}
	for word in s:gmatch(pattern) do
		if #t + 1 > max then
			t[max] = t[max] .. " " .. word
		else
			t[#t + 1] = word
		end
	end

	return t
end

-- CHECK IF PROGRAM IS RUNNING
local function pgrep(prog)
	return os.execute('pgrep -q -x -S "' .. prog .. '"')
end

-- DISPLAY HELP
if
	arg[1] == "-h"
	or arg[1] == "help"
	or arg[1] == "-help"
	or arg[1] == "--help"
then
	usage()
	os.exit(0)
end

-- DISPLAY VERSION
if arg[1] == "--version" or arg[1] == "-version" or arg[1] == "version" then
	io.write([[
                                                   __ ____ __
                                                  / //    \\ \
   _____ _____   ____  _____ ____   _  ___ _____ / //  /  / \ \
  /  __//  _  \ /    \/  __//    \ / \/ _//  __// / \     \ / /
  \__  \\  ___//  /  /\__  \\  \  \\   /  \__  \\ \ /  /  // /
 /_____/ \___//__/__//_____/ \____/ \__\ /_____/ \_\\____//_/

sensors.lua 0.1 2025/07/19 (based on sensors.sh 0.3)

]])
	os.exit(0)
end

-- GET AND SORT sysctl(8) OUTPUT ONLY ONCE
local handle = io.popen("sysctl dev hw.acpi kern.disks 2>/dev/null")
local sysctl_out = handle:read("*a")
handle:close()

local acpi_lines = {}
local disks = {}
local system_lines = {}
local temp_max_cpu = false
local temp_max_acpi = false
for line in sysctl_out:gmatch("[^\r\n]+") do
	if line:find("dev.cpu.0.coretemp.tjmax", 1, true) then
		temp_max_cpu = true
	elseif line:find("hw.acpi.thermal.tz0._CRT", 1, true) then
		temp_max_acpi = true
	elseif line:find("kern.disks", 1, true) then
		for disk in line:gmatch("%S+") do
			disks[#disks + 1] = disk
		end
	elseif
		line:find("dev.cpu.0.freq:", 1, true)
		or line:find("hw.acpi.cpu.cx_lowest", 1, true)
		or line:find("dev.cpu.0.cx_supported", 1, true)
		or line:find("dev.cpu.0.cx_usage:", 1, true)
		or line:find("hw.acpi.acline", 1, true)
		or line:find("hw.acpi.battery.life", 1, true)
		or line:find("hw.acpi.battery.time", 1, true)
		or line:find(".fan", 1, true)
	then
		acpi_lines[#acpi_lines + 1] = line
	elseif
		line:find("temperature", 1, true)
		and not line:find("critical temperature detected", 1, true)
	then
		system_lines[#system_lines + 1] = line
	end
end
table.sort(acpi_lines)
table.sort(disks)
table.sort(system_lines)

-- HEADER: BATTERY/AC/TIME/FAN/SPEED
io.write("\n")
io.write(string.format(WIDTH .. "\n", "BATTERY/AC/TIME/FAN/SPEED "))
io.write(string.format(WIDTH .. "\n", "------------------------------------ "))

-- DISPLAY RELEVANT INFORMATION
for _, line in ipairs(acpi_lines) do
	local parts = split_words(line, 3)
	local mib, v1, v2 = parts[1], parts[2] or "", parts[3] or ""
	io.write(string.format(WIDTH .. " %s %s\n", mib, v1, v2))
end

-- CHECK IF power(8) IS RUNNING
local pd = pgrep("powerd")
if pd then
	io.write(string.format(WIDTH .. " %s\n", "powerd(8):", "running"))
end

-- CHECK IF powerxx(8) IS RUNNING
local pdxx = pgrep("powerd\\+\\+")
if pdxx then
	io.write(string.format(WIDTH .. " %s\n", "powerdxx(8):", "running"))
end

-- DISPLAY powerd(8)/powerdxx(8) STATUS
if not pd and not pdxx then
	io.write(string.format(WIDTH .. " %s\n", "powerd(8)/powerdxx(8):", "disabled"))
end

-- HEADER: SYSTEM/TEMPERATURES
io.write("\n")
io.write(string.format(WIDTH .. "\n", "SYSTEM/TEMPERATURES "))
io.write(string.format(WIDTH .. "\n", "------------------------------------ "))

for _, line in ipairs(system_lines) do
	local parts = split_words(line, 2)
	local mib, val = parts[1], parts[2] or ""

	if mib:match("^dev%.cpu%.[^%.]+") then
		-- USE 3 FIELDS FOR dev.cpu.* MIBS
		if temp_max_cpu then
			local prefix = mib:match("^(dev%.cpu%.[^%.]+%.)")
			local maxv
			for sysctl_out_line in sysctl_out:gmatch("[^\r\n]+") do
				if
					sysctl_out_line:find(prefix, 1, true)
					and sysctl_out_line:find("coretemp.tjmax", 1, true)
				then
					maxv = sysctl_out_line:match(": (.*)$")
					break
				end
			end

			io.write(string.format(WIDTH .. " %s (max: %s)\n", mib, val, maxv or "?"))
		else
			io.write(string.format(WIDTH .. " %s\n", mib, val))
		end
	elseif mib:match("^hw%.acpi%.thermal%.[^%.]+") then
		-- USE 4 FIELDS FOR hw.acpi.thermal.* MIBS
		if temp_max_acpi then
			local prefix = mib:match("^(hw%.acpi%.thermal%.[^%.]+%.)")
			local maxv
			for sysctl_out_line in sysctl_out:gmatch("[^\r\n]+") do
				if
					sysctl_out_line:find(prefix, 1, true)
					and sysctl_out_line:find("._CRT:", 1, true)
				then
					maxv = sysctl_out_line:match(": (.*)$")
					break
				end
			end

			io.write(string.format(WIDTH .. " %s (max: %s)\n", mib, val, maxv or "?"))
		else
			io.write(string.format(WIDTH .. " %s\n", mib, val))
		end
	else
		-- JUST DISPLAY WITHOUT PARSING FOR OTHER MIBS
		io.write(string.format(WIDTH .. " %s\n", mib, val))
	end
end

-- HEADER: DISKS/TEMPERATURES
io.write("\n")
io.write(string.format(WIDTH .. "\n", "DISKS/TEMPERATURES "))
io.write(string.format(WIDTH .. "\n", "------------------------------------ "))

-- WE NEED root PERMISSIONS FOR smartctl(8) COMMAND
local who = io.popen("whoami"):read("*l")
if who ~= "root" then
	local message = string.format(
		"   Run '%s' as 'root' to display disks temperatures.\n\n",
		NAME
	)
	io.write(message)
	os.exit(0)
end

-- CHECK IF smartctl() IS AVAILABLE
if os.execute("which smartctl >/dev/null 2>&1") ~= true then
	io.write(
		"	 Install 'sysutils/smartmontools' package to display disks temperatures.\n\n"
	)
	os.exit(0)
end

-- DISPLAY TEMPERATURE FOR EACH DISK
for _, disk in ipairs(disks) do
	-- IGNORE cd(4) DEVICES
	if not disk:match("^cd") then
		-- NORMALIZE NVME NAMING
		local dev = disk:gsub("nvd", "nvme"):gsub("nda", "nvme")

		local cmd = "smartctl -a /dev/" .. dev .. " 2>/dev/null"
		for line in io.popen(cmd):lines() do
			if dev:match("^nvme") and line:match("Temperature:") then
				-- nvd(4)/nda(4)/nvme(4) DEVICES NEED SPECIAL HANDLING
				local clean = line:gsub("%(.*%)", ""):gsub(":", "")
				local p = split_words(clean)
				local mib = "smart." .. dev .. "." .. p[1]:lower() .. ":"
				local t = p[#p - 1] .. ".0C"
				io.write(string.format(WIDTH .. " %s\n", mib, t))
			elseif line:match("Temperature_") then
				-- SATA/ATA/SCSI/USB DISKS
				local clean = line:gsub("%(.*%)", "")
				local p = split_words(clean)
				local mib = "smart." .. dev .. "." .. p[2]:lower() .. ":"
				local t = p[#p] .. ".0C"
				io.write(string.format(WIDTH .. " %s\n", mib, t))
			end
		end
	end
end
io.write("\n")
