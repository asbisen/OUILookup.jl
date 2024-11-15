
struct OUIRecord
    mac_prefix::String
    manufacturer::String
    address::String
end


"""
    query_from_dbfile(mac_address::AbstractString, ouidb::String=OUI_FILE) -> Union{OUIRecord, Nothing}

Query the OUI database file to find manufacturer information for a given MAC address. Takes a MAC address
string in any common format (e.g. "AA:BB:CC:DD:EE:FF", "AA-BB-CC", "AABBCC") and searches the IEEE OUI
database file for matching vendor information.

**Note**: This function reads the entire OUI database for each query, which is efficient for memory but
would be slow for many queries.

Returns an `OUIRecord` containing the MAC prefix, manufacturer name and address if found,
or `nothing` if no match is found.

# Arguments
- `mac_address::AbstractString`: MAC address to look up
- `ouidb::String=OUI_FILE`: Path to the OUI database file

# Returns
- `OUIRecord` with vendor info if found
- `nothing` if MAC prefix not found in database

# Example
```julia
result = query_from_dbfile("00:50:C2:00:00:00")
if !isnothing(result)
    println("Manufacturer: \$(result.manufacturer)")
end
```
"""
function query_from_dbfile(mac_address::AbstractString, ouidb::String=OUI_FILE)
    mac_prefix = clean_macaddr(mac_address) # normalize and get first 6 characters in lowercase
    @assert length(mac_prefix) == 6

    result = nothing

    # Read through file line by line
    open(ouidb) do file
        # Skip header lines
        for _ in 1:3
            readline(file)
        end

        while !eof(file)
            line = readline(file)

            # Skip empty lines
            isempty(strip(line)) && continue

            # Check if line contains a MAC prefix
            if contains(line, "(hex)")
                # Extract and clean current MAC prefix
                current_prefix = lowercase(strip(replace(split(line, "(hex)")[1], r"[-.:\s]" => "")))

                # If this is our MAC prefix
                if current_prefix == mac_prefix
                    # Get manufacturer name
                    manufacturer = strip(split(line, "(hex)")[2])

                    # Skip base16 line
                    readline(file)

                    # Collect address lines
                    address = ""
                    while !eof(file)
                        line = readline(file)
                        if isempty(strip(line))
                            break
                        end
                        address *= strip(line) * ", "
                    end

                    # Remove trailing comma and space
                    address = rstrip(address, [' ', ','])

                    # Return named tuple
                    result = OUIRecord(mac_prefix, manufacturer, address)
                    # break
                end
            end
        end
    end

    # Return nothing if MAC address not found
    return result
end


"""
    query_from_dict(mac_address::AbstractString, ouidb::Dict{String,OUIRecord}) -> Union{OUIRecord, Nothing}

Look up manufacturer information for a MAC address in a preloaded OUI database dictionary.

# Arguments
- `mac_address::AbstractString`: MAC address to look up in any common format (e.g. "AA:BB:CC", "AA-BB-CC")
- `ouidb::Dict{String,OUIRecord}`: Preloaded dictionary mapping MAC prefixes to OUIRecords

# Returns
- `OUIRecord` with vendor info if found
- `nothing` if MAC prefix not found in dictionary

# Example
```julia
db = load_oui_database()
result = query_from_dict("00:50:C2:00:00:00", db)
```
"""
function query_from_dict(mac_address::AbstractString, ouidb::Dict{String,OUIRecord})
    mac_prefix = clean_macaddr(mac_address) # normalize and get first 6 characters in lowercase
    @assert length(mac_prefix) == 6

    return get(ouidb, mac_prefix, nothing)
end



"""
    ouilookup(mac_address::AbstractString; db=nothing) -> Union{OUIRecord, Nothing}

Query MAC address vendor information using either a preloaded database dictionary or the OUI database file.

When `db` is `nothing` (default), this function reads directly from the OUI database file for each query.
This is memory efficient but slower for multiple queries. When `db` is provided as a Dict{String,OUIRecord},
it performs fast lookups from the in-memory dictionary.

# Arguments
- `mac_address::AbstractString`: MAC address to look up in any common format (e.g. "AA:BB:CC", "AA-BB-CC")
- `db=nothing`: Optional preloaded OUI database dictionary. If nothing, reads from file for each query

# Returns
- `OUIRecord` with vendor info if found
- `nothing` if MAC prefix not found in database

# Performance Considerations
- Without `db`: Each query reads the full OUI database file (memory efficient, slower for multiple queries)
- With `db`: Fast dictionary lookups but requires loading entire database into memory

# Example
```julia
# Single file-based lookup
result = ouilookup("00:50:C2:00:00:00")

# Multiple lookups using preloaded database
db = load_oui_database()  # Load database once
result1 = ouilookup("00:50:C2:00:00:00", db=db)  # Fast dictionary lookup
result2 = ouilookup("00:1A:2B:00:00:00", db=db)  # Fast dictionary lookup
```
"""
function ouilookup(mac_address::AbstractString; db=nothing)
    if isnothing(db)
        return query_from_dbfile(mac_address)
    else
        return query_from_dict(mac_address, db)
    end
end



function Base.show(io::IO, record::OUIRecord)
    print(io, "OUIRecord(\"$(record.mac_prefix)\", \"$(record.manufacturer)\", \"$(record.address)\")")
end

manufacturer(record::OUIRecord) = record.manufacturer
mac_prefix(record::OUIRecord) = record.mac_prefix
address(record::OUIRecord) = record.address
