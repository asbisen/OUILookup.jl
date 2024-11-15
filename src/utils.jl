using Downloads


"""
    download_oui_database(url=OUI_URL, dst=OUI_FILE)

Download the OUI (Organizationally Unique Identifier) database from the specified URL
and save it to the destination path. The constants (defaults) OUI_URL and OUI_FILE are defined in the
MacAddress module and can be overridden by passing in new values.

# Arguments
- `url::String`: The URL to download the OUI database from. Defaults to OUI_URL.
- `dst::String`: The local file path to save the downloaded database. Defaults to OUI_FILE.

# Returns
- `String`: The path to the downloaded file if successful
- `nothing`: If the download fails

# Example
```julia
path = download_oui_database()
```
"""
function download_oui_database(url=OUI_URL, dst=OUI_FILE)::Union{String,Nothing}
    try
        @info "Downloading OUI file to $dst"
        Downloads.download(url, dst)
        return dst
    catch e
        @error "Failed to download OUI file" exception = e
        return nothing
    end
end




"""
    clean_macaddr(mac_address::AbstractString)::String

Clean and normalize a MAC address string by:
1. Converting to lowercase
2. Removing separators (-, ., :, spaces)
3. Taking first 6 characters (OUI prefix)

# Arguments
- `mac_address::AbstractString`: MAC address in any common format (e.g. "00-11-22", "00:11:22", "001122")

# Returns
- `String`: Cleaned 6-character MAC address prefix in lowercase without separators

# Examples
```julia
clean_macaddr("00-11-22-33-44-55") # returns "001122"
clean_macaddr("00:11:22")          # returns "001122"
clean_macaddr("001122334455")      # returns "001122"
```
"""

function clean_macaddr(mac_address::AbstractString)::String
    @assert length(mac_address) ≥ 6 "MAC address must be at least 6 characters"
    res = lowercase(strip(replace(mac_address, r"[-.:\s]" => "")[1:6]))
    return res
end





function load_oui_db(ouidb::String=OUI_FILE)
    # Initialize empty dictionary to store results
    oui_dict = Dict{String,OUIRecord}()

    # Read the file
    lines = readlines(ouidb)

    # Skip header lines
    current_line = 4

    while current_line ≤ length(lines)
        # Skip empty lines
        while current_line ≤ length(lines) && isempty(strip(lines[current_line]))
            current_line += 1
        end

        # Break if we've reached the end of the file
        if current_line > length(lines)
            break
        end

        # Parse MAC prefix and manufacturer name
        line = lines[current_line]
        if !isempty(line) && contains(line, "(hex)")
            # Extract MAC prefix (removing spaces and converting to lowercase)
            mac_prefix = lowercase(replace(split(line, "(hex)")[1], "-" => ""))
            mac_prefix = strip(mac_prefix)

            # Get manufacturer name
            manufacturer = strip(split(line, "(hex)")[2])

            # Get address
            address = ""
            current_line += 2  # Skip the base16 line

            # Collect address lines until we hit an empty line or end of file
            while current_line ≤ length(lines) && !isempty(strip(lines[current_line]))
                address *= strip(lines[current_line]) * ", "
                current_line += 1
            end

            # Remove trailing comma and space
            address = rstrip(address, [' ', ','])

            # Add to dictionary using named tuple
            oui_dict[mac_prefix] = OUIRecord(mac_prefix, manufacturer, address)
        end

        current_line += 1
    end

    return oui_dict
end
