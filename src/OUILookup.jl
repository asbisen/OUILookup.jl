module OUILookup

# location of the out data
const datadir = abspath(joinpath(@__DIR__, "../data"))
const OUI_URL = "https://standards-oui.ieee.org/oui.txt"
const OUI_FILE = joinpath(datadir, "oui.txt")


include("utils.jl")
export download_oui_database, # download the oui db from the internet (refresh the db)
    load_oui_db # load the oui db into memory

include("query.jl")
export OUIRecord,
    # query_from_dbfile, # query without loading the db into memory (memory efficient)
    # query_from_dict, # query from loaded db memory (fast but memory intensive)
    query_mac,    # query from either db or dict depending on memory constraints
    manufacturer, # get the manufacturer from OUIRecord
    address,      # get the address from OUIRecord
    mac_prefix    # get the mac prefix from OUIRecord
end
