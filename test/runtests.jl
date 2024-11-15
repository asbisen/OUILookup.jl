using OUILookup: clean_macaddr, ouilookup, load_oui_db
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

    @testset "ouilookup" begin
        @test_throws AssertionError ouilookup("")
        @test ouilookup("88-7E-25-00-00-00").manufacturer == "Extreme Networks Headquarters"
        @test ouilookup("78:46:5F:00:00:00").manufacturer == "Fiberhome Telecommunication Technologies Co.,LTD"
        @test isnothing(ouilookup("90-00-00-00-00-00"))
        test_mac = ouilookup("88-7E-25-00-00-00")
        @test test_mac.manufacturer == "Extreme Networks Headquarters"
        @test test_mac.address == "2121 RDU Center Drive, Morrisville  NC  27560, US"
        test_mac = ouilookup("78465F")
        @test test_mac.manufacturer == "Fiberhome Telecommunication Technologies Co.,LTD"
        @test test_mac.address == "No.5 DongXin Road, Wuhan  Hubei  430074, CN"
    end

    @testset "ouilookup" begin
        db = load_oui_db()
        @test_throws AssertionError ouilookup("", db=db)
        @test ouilookup("88-7E-25-00-00-00", db=db).manufacturer == "Extreme Networks Headquarters"
        @test ouilookup("78:46:5F:00:00:00", db=db).manufacturer == "Fiberhome Telecommunication Technologies Co.,LTD"
        @test isnothing(ouilookup("90-00-00-00-00-00", db=db))
        test_mac = ouilookup("88-7E-25-00-00-00", db=db)
        @test test_mac.manufacturer == "Extreme Networks Headquarters"
        @test test_mac.address == "2121 RDU Center Drive, Morrisville  NC  27560, US"
        test_mac = ouilookup("78465F", db=db)
        @test test_mac.manufacturer == "Fiberhome Telecommunication Technologies Co.,LTD"
        @test test_mac.address == "No.5 DongXin Road, Wuhan  Hubei  430074, CN"
    end


end
