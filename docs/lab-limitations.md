# Kjente labbegrensninger

## IOSvL2 / CML og IP Source Guard

I prosjektets CML-test ble følgende observert på en klientport:

- DHCP Snooping-binding var korrekt.
- `show ip verify source` viste riktig klient-IP og `active` filter.
- Port Security hadde ingen violations.
- DAI viste forwarding og 0 drops.
- Klienten sendte ARP request etter gateway, men requesten kom ikke frem til router-uplinken.
- `no ip verify source` på klientporten gjorde at ARP og ping til gateway fungerte umiddelbart.

Dette peker mot en lab-/IOSvL2-begrensning eller implementasjonsforskjell for IPSG i den aktuelle imaget. Funksjonen bør derfor verifiseres på fysisk målplattform før produksjonskonklusjon.

## ERSPAN / speiling

Ikke alle lab-/målplattformer støtter samme SPAN/RSPAN/ERSPAN-funksjonalitet. Generatoren kan støtte flere speilmetoder, men faktisk kommando- og dataplanstøtte må kontrolleres på den konkrete switchmodellen/IOS-versjonen.

## Eldre Cisco SSH

Enkelte eldre IOS-versjoner krever legacy KEX/cipher/hostkey. `automation/ansible/legacy_ssh.cfg` genereres ved behov og begrenser legacy-algoritmene til management-IP-ene i inventory i stedet for å gjøre dem globale på Ubuntu-serveren.
