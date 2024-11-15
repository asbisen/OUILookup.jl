# OUILookup

[![Build Status](https://github.com/asbisen/OUILookup.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/asbisen/OUILookup.jl/actions/workflows/CI.yml?query=branch%3Amain)

A simple library to identify manufacturer and address for a given MAC address prefix.

## Installation

```julia
using Pkg
Pkg.add("OUILookup")
```

## Usage

There are two ways to query manufacturer information for a MAC address:

1. Direct file lookup (memory efficient):
```julia
using OUILookup

# Lookup directly from file
result = lookup_mac_info("5C-FF-35-00-00-00")
if !isnothing(result)
    println("Manufacturer: $(result.manufacturer)")
    println("Address: $(result.address)")
end

# Works with different MAC formats
lookup_mac_info("5CFF35")  # just prefix
lookup_mac_info("5C:FF:35")  # with colons
lookup_mac_info("5C.FF.35")  # with dots
```

2. Load database into memory first (faster for multiple queries):
```julia
using OUILookup

# Load the OUI database into memory
db = load_oui_db()

# Multiple quick lookups from memory
result1 = lookup_mac_info("5C-FF-35-00-00-00", db)
result2 = lookup_mac_info("10-E9-92-00-00-00", db)
```

### Performance Considerations

- `lookup_mac_info(mac)` - Reads file line by line until match is found. Memory efficient but slower for multiple lookups.
- `lookup_mac_info(mac, db)` - Quick dictionary lookup, but requires loading entire database into memory first.

Choose the appropriate method based on your use case:
- Single/few lookups → Use direct file lookup
- Many lookups → Load database first, then perform lookups
