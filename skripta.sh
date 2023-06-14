#!/bin/bash

admin_opcije() {
    local brojac="$1"

    if [[ "$brojac" -gt 0 ]]; then
        echo -e "\t\t\e[32mOpcije\e[0m"
        ispis_linija "40" "crvena"
    fi
    echo -e "\t\b\b\b1. Dodavanje novog taxi vozila"
    echo -e "\t\b\b\b2. Uredivanje informacija"
    echo -e "\t\b\b\b3. Pregled informacija o vožnjama"
    echo -e "\t\b\b\b4. Prikaz stanja vozila"
    echo -e "\t\b\b\b5. Brisanje taxi vozila"
    echo -e "\t\b\b\b6. Exit"
    echo
}

korisnik_opcije() {
    local brojac="$1"

    if [[ "$brojac" -gt 0 ]]; then
        echo -e "\t\t\e[32mOpcije\e[0m"
        ispis_linija "40" "crvena"
    fi
    echo -e "\t\b\b\b1. Rezervacija taxi vozila"
    echo -e "\t\b\b\b2. Pregled informacija o voznjama"
    echo -e "\t\b\b\b3. Exit"
    echo
}

provjera_admin() {
    local username="$1"
    local password="$2"
    
    local query="SELECT username, lozinka FROM admin WHERE username='$username' AND lozinka='$password'"
    local result=$(mysql -u root -D taxi_sistem -N -e "$query" | wc -l)
    
    if [[ $result -eq 1 ]]; then
        return 0  
    else
        return 1  
    fi
}

provjera_korisnik() {
    local username="$1"
    local password="$2"
    
    local query="SELECT ime, lozinka FROM korisnik WHERE ime LIKE '$username' AND lozinka LIKE'$password'"
    local result=$(mysql -u root -D taxi_sistem -N -e "$query" | wc -l)
    
    if [[ $result -eq 1 ]]; then
        return 0  
    else
        return 1  
    fi
}

informacije_voznje() {

    local korisnik="$1"
    local uslov="$2"

    local query="SELECT korisnik_id FROM korisnik WHERE ime='$korisnik'"
    local korisnikID=$(mysql -u root -D taxi_sistem -N -e "$query")


    if [[ "$uslov" -eq 1 ]]; then 
        local vrijednost_uslova="WHERE putnik_id = $korisnikID"
        local provjera=1
    else
        local vrijednost_uslova=""
    fi
    
    query="SELECT polaziste, odrediste, broj_putnika, vozilo_id FROM voznja $vrijednost_uslova"
    local result=$(mysql -u root -D taxi_sistem -N -e "$query")

    echo
    if [[ $provjera -eq 1 ]]; then
        echo -e "\t\t\t\b\b \e[97mVase voznje \e[0m"
    else 
        echo -e "\t\t \e[97mInformacije o voznjama \e[0m"
    fi


    echo -e "\e[31m----------------------------------------------------------------\e[0m"
    echo -e "\e[33m   Polaziste \t   Odrediste \t   Broj putnika\t    Vozilo ID\e[0m"
    echo -e "\e[31m----------------------------------------------------------------\e[0m"
    while IFS= read -r line; do
        printf "    %-15s %-19s %-11s     %-4s\n" $line
    done <<< "$result"

    echo
    if [[ "$uslov" -ne 1 ]]; then
        read -p "Želite li prikazati informacije o vozilu? (da/ne): " odabir
        echo

        if [[ "$odabir" != "da" && "$odabir" != "DA" && "$odabir" != "Da" && "$odabir" != "dA" ]]; then
            clear
            return
        else 
            echo
            read -p "Unesite ID vozila koje zelite prikazati: " voziloID
            clear
            echo -e "\t\e[97mVozilo sa unesenim ID\e[0m"
            informacije_vozilo "$voziloID"
            ispis_linija "48" "plava" 
            echo
            read -p "Želite li prikazati informacije o vozacu tog vozila? (da/ne): " odabir
            echo

            if [[ "$odabir" != "da" && "$odabir" != "DA" && "$odabir" != "Da" && "$odabir" != "dA" ]]; then
                clear
                return
            else 
                echo
                echo -e "\t\e[97mVozac odabranog vozila\e[0m"
                prikaz_vozaca "$voziloID" "0"
                ispis_linija "40" "plava"
                read -p "Pritisnite enter za nastavak!" nastavak
                clear
                echo
            fi
        fi
    fi
}

informacije_vozilo() {
    
    local voziloID="$1"
    local query="SELECT marka, model, registracija  FROM vozila WHERE vozilo_id=$voziloID"
    local result=$(mysql -u root -D taxi_sistem -s -N -e "$query")

    echo
    echo -e "\e[31m------------------------------------------------\e[0m"
    echo -e "\e[33m     Marka \t     Model \t   Registracija\e[0m"
    echo -e "\e[31m------------------------------------------------\e[0m"
    while IFS= read -r line; do
        printf "    %-15s %-15s %-8s\n" $line
    done <<< "$result"

}

dodavanje_vozila() {
    echo
    read -p "Unesite marku vozila: " marka
    read -p "Unesite model vozila: " model
    read -p "Unesite registraciju vozila: " registracija
    read -p "Unesite stanje vozila: " stanje
    read -p "Unesite ID vozaca vozila: " vozacID

    local query="INSERT INTO vozila (\`marka\`, \`model\`, \`registracija\`, \`stanje\`, \`vozac_id\`) VALUES ('$marka','$model','$registracija','$stanje', '$vozacID')"
    mysql -u root -D taxi_sistem -N -e "$query"

    query="SELECT vozilo_id FROM vozila WHERE registracija='$registracija'"
    local voziloID=$(mysql -u root -D taxi_sistem -N -e "$query")

    if [[ $voziloID -ne 0 ]]; then
        echo
        query="UPDATE vozac SET vozilo_id=$voziloID WHERE vozac_id=$vozacID"
        mysql -u root -D taxi_sistem -s -N -e "$query"
        echo -e "\t\e[97mUspješno ste dodali novo vozilo\e[0m"
    else
        echo "Doslo je do greske prilikom unosa!"
    fi

}

prikaz_svih_vozila() {

    local query="SELECT vozilo_id, marka, model, registracija  FROM vozila ORDER BY vozilo_id"
    local result=$(mysql -u root -D taxi_sistem -N -e "$query")

    echo -e "\e[31m------------------------------------------------\e[0m"
    echo -e "\e[33m ID     Marka \t       Model \t   Registracija\e[0m"
    echo -e "\e[31m------------------------------------------------\e[0m"
    while IFS= read -r line; do
        printf " %-4s %-15s %-15s %-8s\n" $line
    done <<< "$result"
}

prikaz_vozila_uslov() {

    local uslov="$1"
    local vrijednost="$2"

    local query="SELECT vozilo_id, marka, model, registracija  FROM vozila WHERE $uslov='$vrijednost' ORDER BY vozilo_id"
    local result=$(mysql -u root -D taxi_sistem -N -e "$query")

    if [[ -z "$result" ]]; then 
        clear
        echo -e "\t\t\b\b\e[97mNema vozila za prikaz\e[0m"
        return 1
    else
        ispis_linija "48" "crvena"
        echo -e "\e[33m ID     Marka \t       Model \t   Registracija\e[0m"
        echo -e "\e[31m------------------------------------------------\e[0m"
        while IFS= read -r line; do
            printf " %-4s %-15s %-15s %-8s\n" $line
        done <<< "$result"
    fi
}

prikaz_vozaca() {

    local voziloID="$1"
    local uslov="$2"

    case "$uslov" in
        0)
            local where_uslov="WHERE vozilo_id = $voziloID"
            local dio_query="broj_telefona"
            local ispis_query="Broj telefona"
            local broj_linija=40
            local novi_red="\n"
            local novi_red2="-n"
        ;;
        1)
            local where_uslov=""
            local dio_query="vozac_id"
            local ispis_query="ID"
            local broj_linija=35
            local novi_red="\n"
            local novi_red2="-n"
        ;;
        5)
            local where_uslov="WHERE vozilo_id IS $voziloID"
            local dio_query="vozac_id"
            local ispis_query="ID"
            local broj_linija=35
            local novi_red="\n"
            local novi_red2="-n"
        ;;
        10)
            local where_uslov="WHERE vozac_id = $voziloID"
            local dio_query="vozac_id"
            local ispis_query="ID"
            local broj_linija=35
            local novi_red="\n"
            local novi_red2="-n"
        ;;
        11)
            local where_uslov=""
            local dio_query="vozac_id"
            local ispis_query="ID"
            local broj_linija=35
            local novi_red="\n"
            local novi_red2="-n"
        ;;
        12)
            local where_uslov="WHERE vozac_id = $voziloID"
            local dio_query="broj_telefona"
            local ispis_query="Broj telefona"
            local broj_linija=40
            local novi_red="\n"
            local novi_red2="-n"
        ;;
        13)
            local where_uslov="WHERE vozac_id = $voziloID"
            local dio_query="adresa"
            local ispis_query="   Adresa"
            local novi_red=""
            local novi_red2="\n"
            local broj_linija=47
        ;;
        *)
            local where_uslov=""
            local dio_query="broj_telefona"
            local ispis_query="Broj telefona"
            local novi_red="\n"
            local novi_red2="-n"
        ;;
    esac

    local query="SELECT ime, prezime, $dio_query  FROM vozac  $where_uslov"
    local result=$(mysql -u root -D taxi_sistem -N -e "$query")

    ispis_linija "$broj_linija" "crvena"
    echo -e "\e[33m Ime         Prezime \t    $ispis_query \e[0m"
    ispis_linija "$broj_linija" "crvena"
    while IFS= read -r line; do
        printf " %-10s %-15s %-3s$novi_red" $line
    done <<< "$result"
    echo -n -e "$novi_red2"
}

ispis_linija()
{
    local n="$1"
    local boja="$2"

    bijela_boja="\e[0m"

    if [[ "$boja" == "crvena" ]]; then
        boja="\e[31m"
    else
        boja="\e[34m"
    fi

    brojac=0

    while ((brojac < n)); do
        echo -n -e $boja"-"$bijela_boja
        ((brojac++))
    done
    echo
}

brisanje_vozila() {

    prikaz_svih_vozila
    ispis_linija "48" "plava"
    echo
    read -p "Unesite ID vozila koje zelite obrisati: " voziloID

    local query="DELETE FROM vozila WHERE vozilo_id=$voziloID"
    local result=$(mysql -u root -D taxi_sistem -s -N -e "$query")

    query="UPDATE vozac SET vozilo_id=NULL WHERE vozilo_id=$voziloID"
    local result1=$(mysql -u root -D taxi_sistem -s -N -e "$query")

    if [[ -z "$result" ]]; then
        clear
        prikaz_svih_vozila
        ispis_linija "48" "plava"
        echo -e "\t\e[97mUspješno ste obrisali vozilo\e[0m"
    else
        echo
        echo "Niste uspjeli obrisati vozilo"
    fi

}


sql_uredjivanje_vozila() {

    local celija="$1"
    local vrijednost="$2"
    local voziloID="$3"

    local query="UPDATE vozila SET $celija='$vrijednost'  WHERE vozilo_id=$voziloID"
    mysql -u root -D taxi_sistem -N -e "$query"

}

sql_uredjivanje_vozaca() {
    
    echo
    local celija="$1"
    local poruka="$2"
    local vozacID="$3"

    if [[ "$poruka" -eq 1 ]]; then 
        read -p "Unesite novi broj telefona: " vrijednost
        local query="UPDATE vozac SET $celija='$vrijednost' WHERE vozac_id='$vozacID'"
    elif [[ "$poruka" -eq 2 ]]; then
        read -p "Unesite novu adresu: " vrijednost
        local query="UPDATE vozac SET $celija='$vrijednost' WHERE vozac_id='$vozacID'"
    else 
        read -p "Unesite ID novog vozila: " vrijednost
        local query="UPDATE vozac SET $celija=$vrijednost WHERE vozac_id='$vozacID'"
    fi
    
    mysql -u root -D taxi_sistem -e "$query"

}



uredjivanje_vozaca() {

    echo -e "\t\e[97mUredjivanje vozaca\e[0m"
    echo -e "\e[34m----------------------------------\e[0m"
    echo "  1. Dodaj vozaca"
    echo "  2. Uredi informacije o vozacu"
    echo

    read -p "Odaberite opciju: " opcija

    case "$opcija" in

            1) 
                clear
                echo -e "\t\e[97mDodavanje novog vozaca\e[0m"
                echo -e "\e[34m--------------------------------------\e[0m"
                read -p "Unesite ime vozaca: " ime
                read -p "Unesite prezime vozaca: " prezime
                read -p "Unesite broj telefona: " broj_telefona
                read -p "Unesite adresu: " adresa

                voziloID="NULL"

                local query="INSERT INTO vozac (\`ime\`, \`prezime\`, \`broj_telefona\`, \`adresa\`, \`vozilo_id\`) VALUES ('$ime','$prezime','$broj_telefona','$adresa', $voziloID)"
                local result=$(mysql -u root -D taxi_sistem -N -e "$query")

                query="SELECT * FROM vozac WHERE ime='$ime'"
                result=$(mysql -u root -D taxi_sistem -N -e "$query")

                if [[ -z "$result" ]]; then
                    echo
                    echo "Doslo je do greske!"
                    echo "Niste uspjeli dodati novog vozaca!"
                else
                    clear
                    echo -e "\t\e[97mUspjesno ste dodali novog vozaca\e[0m"
                    prikaz_vozaca "1" "1"
                    ispis_linija "35" "plava"
                fi
            ;;

            2)
                clear
                echo -e "\t\e[97mRegistrovani vozaci\e[0m"
                prikaz_vozaca "1" "11"
                ispis_linija "35" "plava"
                read -p  "Unesite ID vozaca za uredjivanje: " vozacID
                clear
                echo -e "\t\e[97mOdabrali ste vozaca\e[0m"
                prikaz_vozaca "$vozacID" "10" 
                ispis_linija "35" "plava"
                echo "  1. Broj telefona"
                echo "  2. Adresa"
                echo "  3. Vozilo"
                echo
                read -p "Odaberite opciju koju zelite urediti: " opcija
                clear

                case "$opcija" in
                    1)
                        echo -e "\t\e[97mOdabrali ste vozaca\e[0m"
                        prikaz_vozaca "$vozacID" "12"
                        ispis_linija "40" "plava"
                        sql_uredjivanje_vozaca "broj_telefona" "1" "$vozacID"
                        clear
                        echo -e "  \e[97mBroj telefona je uspjesno izmjenjen!\e[0m"
                        prikaz_vozaca "$vozacID" "12"
                        ispis_linija "40" "plava" 

                    ;;
                    2)  
                        echo -e "\t\e[97mOdabrali ste vozaca\e[0m"
                        prikaz_vozaca "$vozacID" "13"
                        ispis_linija "47" "plava"
                        sql_uredjivanje_vozaca "adresa" "2" "$vozacID"
                        clear
                        echo -e "  \e[97mAdresa je uspjesno izmjenjena!\e[0m"
                        prikaz_vozaca "$vozacID" "13"
                        ispis_linija "47" "plava" 
                    ;;
                    3)
                        sql_uredjivanje_vozaca "vozilo_id" "3" "$vozacID"
                    ;;
                    *)
                        echo "Pogresan unos!";
                    ;;
                esac
            ;;

            *)
                echo "Pogresan unos!"
            ;;
        esac
        read -p "Pritisnite enter za nastavak!" nastavak
        clear
        echo

}

provjera_postojanja_vozila() {

    local voziloID="$1"

    local query="SELECT * FROM vozila  WHERE vozilo_id=$voziloID"
    local result=$(mysql -u root -D taxi_sistem -N -e "$query" | wc -l)
    
    if [[ $result -eq 1 ]]; then
        return 0  
    else
        return 1  
    fi

}

dodavanje_zarade() 
{
    local cijena_voznje="$1"
    local voznjaID="$2"
    local vozacID="$3"

    query="INSERT INTO zarada (\`cijena_voznje\`, \`vozac_id\`, \`voznja_id\`) VALUES ($cijena_voznje, $vozacID, $voznjaID)"
    mysql -u root -D taxi_sistem -N -e "$query"

}

rezervacija_vozila() {

    local korisnik="$1"

    local query="SELECT korisnik_id FROM korisnik WHERE ime='$korisnik'"
    local korisnik_id=$(mysql -u root -D taxi_sistem -N -e "$query")

    echo
    read -p "Unesite ID vozila koje zelite rezervisati: " voziloID
    echo
    read -p "Unesite polaziste: " polaziste
    read -p "Unesite odrediste: " odrediste
    read -p "Unesite broj putnika: " br_putnika

    cijena=$((1 + RANDOM % 4))
    cijena2=$((br_putnika + RANDOM % 10))
    ukupno=$((cijena+cijena2))
    
    query="SELECT vozac_id FROM vozila WHERE vozilo_id=$voziloID"
    local vozacID=$(mysql -u root -D taxi_sistem -N -e "$query")

    query="INSERT INTO voznja (\`polaziste\`, \`odrediste\`, \`broj_putnika\`, \`cijena_voznje\`, \`vozilo_id\`, \`putnik_id\`) VALUES ('$polaziste','$odrediste',$br_putnika,$ukupno, $voziloID, $korisnik_id)"
    local result=$(mysql -u root -D taxi_sistem -N -e "$query")

    echo

    if [[ -z "$korisnik_id" ]]; then
        echo -e "\t\b\b\e[97mNiste uspjeli rezervisati voznju\e[0m"
    else
        query="SELECT voznja_id FROM voznja WHERE vozilo_id=$voziloID AND broj_putnika=$br_putnika AND cijena_voznje=$ukupno"
        local voznjaID=$(mysql -u root -D taxi_sistem -N -e "$query")
        echo -e "\t\b\b\e[97mUspjesno ste rezervisali voznju na relaciji $polaziste - $odrediste!\e[0m"
        sql_uredjivanje_vozila "stanje" "Voznja" "$voziloID"
        dodavanje_zarade "$ukupno" "$voznjaID" "$vozacID"
    fi


}

ispis_zarade () {


    local vozacID="$1"

    local query="SELECT ime, prezime FROM vozac WHERE vozac_id=$vozacID"
    local result=$(mysql -u root -D taxi_sistem -N -e "$query")

    query="SELECT SUM(cijena_voznje) FROM zarada WHERE vozac_id=$vozacID"
    local suma_zarade=$(mysql -u root -D taxi_sistem -N -e "$query")

    if [[  "$suma_zarade"=='NULL' ]]; then
        suma_zarade=0
    fi

    clear
    echo  -e "   \e[97m       Prikaz zarade vozaca\e[0m"
    ispis_linija "40" "crvena"
    echo -e "\e[33m ID     Ime \t Prezime \tZarada\e[0m"
    ispis_linija "40" "crvena"
    echo -e "  $vozacID\t$result \t\e[97m$suma_zarade KM\e[0m"

}

uredjivanje_informacija() {

    echo -e " 1. Uredi vozila"
    echo -e " 2. Uredi vozace"
    echo -e " 3. Ispisi zaradu vozaca"
    echo
    read -p "Unesite broj opcije koju zelite odabrati: " opcija

    case "$opcija" in
            1)
                clear
                prikaz_svih_vozila
                ispis_linija "48" "plava"
                echo
                uredivanje_vozila
                ;;

            2)
                clear
                uredjivanje_vozaca
            ;;

            3)
                clear
                prikaz_vozaca "1" "1"
                ispis_linija "35" "plava"
                echo
                read -p "Unesite ID vozaca za prikaz zarade: " vozacID
                ispis_zarade "$vozacID"
                ispis_linija "40" "plava"
                read -p "Pritisnite enter za nastavak!" nastavak
                clear
                echo
            ;;
            *)
                echo "Pogresan unos"
            ;;
    esac

    

}

prikaz_vozila_stanje ()
{
    local uslov="$1"

    local query="SELECT  marka, model, registracija, stanje  FROM vozila WHERE vozilo_id='$uslov'"
    local result=$(mysql -u root -D taxi_sistem -N -e "$query")

    ispis_linija "45" "crvena"
    echo -e "\e[33m  Marka \tModel \t   Registracija   Stanje\e[0m"
    ispis_linija "45" "crvena"
    while IFS= read -r line; do
        printf " %-15s%-10s %-9s     %-10s\n" $line
    done <<< "$result"

}

sql_promjena_vozaca()
{
    local prvi_vozac="$1"
    local drugi_vozac="$2"
    local voziloID="$3"

    local query="UPDATE vozac SET vozilo_id=$voziloID WHERE vozac_id=$drugi_vozac"
    mysql -u root -D taxi_sistem -N -e "$query"

    query="UPDATE vozac SET vozilo_id=NULL WHERE vozac_id=$prvi_vozac"
    mysql -u root -D taxi_sistem -N -e "$query"

}

sql_odabir_vozaca()
{
    local voziloID="$1"

    local query="SELECT vozac_id  FROM vozac WHERE vozilo_id=$voziloID"
    local result=$(mysql -u root -D taxi_sistem -N -e "$query")

    echo $result
}

uredivanje_vozila() 
{

    read -p "Unesite ID vozila koje zelite urediti: " voziloID

    if provjera_postojanja_vozila "$voziloID"; then
        clear
        echo
        echo "  1. Registracija"
        echo "  2. Stanje"
        echo "  3. ID vozaca"
        echo
        read -p "Unesite koji podatak zelite urediti: " podatak

        case "$podatak" in
                1)
                    clear
                    echo -e "\t\t\b\b\b\e[97mOdabrali ste vozilo\e[0m"
                    prikaz_vozila_uslov "vozilo_id" "$voziloID"
                    echo
                    read -p "Unesite novu registraciju vozila: " nova_registracija
                    celija="registracija"
                    sql_uredjivanje_vozila "$celija" "$nova_registracija" "$voziloID"
                    clear
                    echo -e "\t\e[97mUspjesno ste azurirali podatke\e[0m"
                    prikaz_vozila_uslov "vozilo_id" "$voziloID" 
                    echo -e "\e[34m------------------------------------------------\e[0m"
                    read -p "Pritisnite enter za nastavak!" nastavak
                    clear
                    echo
                    ;;
                2)
                    clear
                    echo -e "\t\t\b\b\b\e[97mOdabrali ste vozilo\e[0m"
                    prikaz_vozila_stanje "$voziloID"
                    echo -e "\e[34m-----------------------------------------------\e[0m"
                    echo -e "Moguca stanja: \e[97mSlobodno Voznja Pauza Servis \e[0m"
                    echo
                    read -p "Unesite novo stanje vozila: " stanje

                    if [[ "$stanje" != "Slobodno" && "$stanje" != "Pauza" && "$stanje" != "Voznja" && "$stanje" != "Servis" ]]; then
                        echo "Doslo je do greske. Unos '$stanje' stanja nije moguc!"
                    else
                        sql_uredjivanje_vozila "stanje" "$stanje" "$voziloID"
                        clear
                        echo
                        echo -e "\t\e[97mUspjesno ste azurirali podatke\e[0m"
                        prikaz_vozila_stanje "$voziloID"
                    fi

                    echo -e "\e[34m------------------------------------------------\e[0m"
                    read -p "Pritisnite enter za nastavak!" nastavak
                    clear
                    echo
                    ;;
                3)
                    clear
                    echo -e "\t\b\b\b\e[97mTrenutni vozac odabranog vozila\e[0m"
                    prikaz_vozaca "$voziloID" "0"
                    echo -e "\e[34m-----------------------------------------------\e[0m"
                    echo
                    echo -e "\t\b\b\b\e[97mTrenutni vozaci bez vozila\e[0m"
                    prikaz_vozaca "NULL" "5" 
                    local prvi_vozac=$(sql_odabir_vozaca "$voziloID")
                    echo -e "\e[34m-----------------------------------------------\e[0m"
                    echo
                    read -p "Unesite ID novog vozaca vozila: " IDvozaca
                    sql_uredjivanje_vozila "vozac_id" "$IDvozaca" "$voziloID"
                    sql_promjena_vozaca "$prvi_vozac" "$IDvozaca" "$voziloID"
                    clear
                    echo -e "\t\e[97mUspjesno ste azurirali podatke\e[0m"
                    echo -e "\e[34m-----------------------------------------------\e[0m"
                    read -p "Pritisnite enter za nastavak!" nastavak
                    clear
                    echo
                    ;;
                *)
                    clear
                    echo -e "\t\t\e[97mNeispravan izbor!\e[0m"
                    echo -e "\e[34m-----------------------------------------------\e[0m"
                    read -p "Pritisnite enter za nastavak!" nastavak
                    clear
                    ;;
            esac
    else 
        echo
        echo -e "\t\b\b\b\e[97mVozilo sa unesenim ID ne postoji!\e[0m"
        echo -e "\e[34m-----------------------------------------------\e[0m"
        read -p "Pritisnite enter za nastavak!" nastavak
        clear

    fi
}

prikaz_stanja_opcije()
{
    echo -e "\t\b\b\b1. Slobodno"
    echo -e "\t\b\b\b2. Voznja"
    echo -e "\t\b\b\b3. Pauza"
    echo -e "\t\b\b\b4. Servis"
    echo
    
}

odabir_opcije_admin() 
{
    local brojac=0
    while true; do
        admin_opcije "$brojac"
        read -p "Odaberite opciju: " opcija
        echo

        case "$opcija" in
            1)
                clear
                echo
                echo -e "\t\e[97mDodavanje novog taxi vozila\e[0m"
                echo -e "\e[34m-----------------------------------------------\e[0m"
                dodavanje_vozila
                echo
                ;;
            2)
                clear
                echo
                echo -e "\t\e[97mUredivanje informacija\e[0m"
                echo -e "\e[34m---------------------------------------\e[0m"
                uredjivanje_informacija
                ;;
            3)
                clear
                informacije_voznje "0" "0"
                ;;

            4)
                clear
                prikaz_stanja_opcije 
                read -p " Odaberite stanje za prikaz: " opcija
                case "$opcija" in
                    1)  
                        local uslov="Slobodno"
                    ;;
                    2)
                        local uslov="Voznja"
                    ;;
                    3)
                        local uslov="Pauza"
                    ;;
                    4)
                        local uslov="Servis"
                    ;;
                    *)
                    echo -e "\t Pogresan unos"
                    ;;
                esac
                    clear
                    echo -e "\t  \e[97mOdabrano stanje '$uslov'" 
                    prikaz_vozila_uslov "stanje" "$uslov"
                    ispis_linija "48" "plava"
                    echo
                    read -p "Pritisnite enter za nastavak!" nastavak
                    clear
                ;;
            5)
                clear
                echo -e "\t\t\b\b\b\e[97mBrisanje taxi vozila\e[0m"
                brisanje_vozila
                echo
                read -p "Pritisnite enter za nastavak!" nastavak
                clear
                ;;
            6)
                clear
                source end.sh
                ;;
            *)
                clear
                echo "Neispravan izbor. Pokusajte ponovno."
                ;;
        esac
        ((brojac++))
    done
}

odabir_opcije_korisnik() {
    
    local brojac=0
    local korisnik="$1"
    while true; do
        korisnik_opcije "$brojac"
        read -p "Odaberite opciju: " opcija
        echo
        case "$opcija" in
            1)
                clear
                echo
                echo -e "\t\t\b\b\b\b\b\e[97mRezervacija taxi vozila\e[0m"
                if prikaz_vozila_uslov "stanje" "Slobodno"; then
                    rezervacija_vozila "$korisnik"
                    ispis_linija "60" "plava"
                else 
                    clear
                    echo -e "\t\e[97mNema slobodnih vozila za rezervaciju\e[0m"
                    ispis_linija "50" "plava"
                fi
                echo
                read -p "Pritisnite enter za nastavak!" nastavak
                clear
                ;;
            2)
                clear
                informacije_voznje "$korisnik" "1"
                ispis_linija "64" "plava"
                echo
                read -p "Pritisnite enter za nastavak!" nastavak
                clear
                ;;
            3)
                clear
                source end.sh
                ;;

            *)
                clear
                echo "Neispravan izbor. Pokusajte ponovno."
                ;;
        esac
        ((brojac++))
    done
}

main() {
    #source loading.sh
    clear
    while true; do
    echo
        echo -n "  Unesite vaš username: "
        read username
        echo
        echo -n "  Unesite vašu lozinku: "
        read password
        echo
        
        if provjera_admin "$username" "$password"; then
            clear
            echo  -e "   \e[32mUspjesno ste prijavljeni kao admin\e[0m"
            ispis_linija "40" "crvena"
            odabir_opcije_admin
            break  
        elif provjera_korisnik "$username" "$password"; then
            clear
            echo -e "   \e[32mUspjesno ste prijavljeni kao korisnik\e[0m"
            ispis_linija "40" "crvena"
            odabir_opcije_korisnik "$username"
            break
        else
            echo -e "\tPogresno korisničko ime ili lozinka. Pokusajte ponovno."
            echo
        fi
    done
}

main