using OUILookup: clean_macaddr, query_mac, load_oui_db
using Test

@testset "OUILookup.jl" begin
    @testset "clean_macaddr" begin
        @test clean_macaddr("00:11:22:33:44:55") == "001122"
        @test clean_macaddr("00-11-22-33-44-55") == "001122"
        @test clean_macaddr("001122334455") == "001122"
        @test clean_macaddr("00.11.22.33.44.55") == "001122"
        @test clean_macaddr("00:11:22") == "001122"
        @test clean_macaddr("00-11-22") == "001122"
        @test clean_macaddr("001122") == "001122"
        @test clean_macaddr("aA:bB:cC:dD:eE:fF") == "aabbcc"
        @test_throws AssertionError clean_macaddr("")
        @test clean_macaddr("  00:11:22:33:44:55  ") == "001122"
    end

    @testset "query_mac" begin
        @test_throws AssertionError query_mac("")
        @test query_mac("88-7E-25-00-00-00").manufacturer == "Extreme Networks Headquarters"
        @test query_mac("78:46:5F:00:00:00").manufacturer == "Fiberhome Telecommunication Technologies Co.,LTD"
        @test isnothing(query_mac("90-00-00-00-00-00"))
        test_mac = query_mac("88-7E-25-00-00-00")
        @test test_mac.manufacturer == "Extreme Networks Headquarters"
        @test test_mac.address == "2121 RDU Center Drive, Morrisville  NC  27560, US"
        test_mac = query_mac("78465F")
        @test test_mac.manufacturer == "Fiberhome Telecommunication Technologies Co.,LTD"
        @test test_mac.address == "No.5 DongXin Road, Wuhan  Hubei  430074, CN"
    end

    @testset "query_mac" begin
        db = load_oui_db()
        @test_throws AssertionError query_mac("", db=db)
        @test query_mac("88-7E-25-00-00-00", db=db).manufacturer == "Extreme Networks Headquarters"
        @test query_mac("78:46:5F:00:00:00", db=db).manufacturer == "Fiberhome Telecommunication Technologies Co.,LTD"
        @test isnothing(query_mac("90-00-00-00-00-00", db=db))
        test_mac = query_mac("88-7E-25-00-00-00", db=db)
        @test test_mac.manufacturer == "Extreme Networks Headquarters"
        @test test_mac.address == "2121 RDU Center Drive, Morrisville  NC  27560, US"
        test_mac = query_mac("78465F", db=db)
        @test test_mac.manufacturer == "Fiberhome Telecommunication Technologies Co.,LTD"
        @test test_mac.address == "No.5 DongXin Road, Wuhan  Hubei  430074, CN"
    end


end
