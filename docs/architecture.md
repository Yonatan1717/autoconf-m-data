# Arkitektur

## Mål

Løsningen skiller tjenester i egne VLAN/VRF-er og bruker DMVPN som overlay mellom lokasjoner over et eksisterende rutet transportnett. Sentrale drifts- og sikkerhetstjenester plasseres ved Site 1 / BNHQ.

## Segmentering

| VLAN | VRF | Typisk adresseplan | Kommentar |
|---:|---|---|---|
| 10 | MGMT | `10.<site>.10.0/24` | Administrasjon og infrastrukturtjenester |
| 20 | INET | `10.<site>.20.0/24` | Internett-/velferdstrafikk |
| 30 | UNET | `10.<site>.30.0/24` | Ugradert tjenestenett |
| 40 | PA | `10.<site>.40.0/24` | PA-/spesialtjeneste |
| 50 | MONITORING | `10.<site>.50.0/24` | Sensor-/overvåkningstrafikk |
| 999 | Native/blackhole | Ingen L3-adresse | Ubrukt native VLAN |

VRF-Lite skiller rutetabellene lokalt. ACL-er håndhever tjenestematrisen på aktuelle ingress-grensesnitt.

## Mellom lokasjoner

- DMVPN brukes som overlay.
- Site 1 / BNHQ er hub/NHS.
- Øvrige lokasjoner er spokes.
- Phase 3 kan brukes for direkte spoke-to-spoke dataflyt etter NHRP redirect/shortcut.
- EIGRP kjøres separat per VRF over tilhørende tunnel.
- IPsec beskytter utvalgte tunneler.

## Lokal sikkerhet

Klientporter kan bruke:

- DHCP Snooping
- Dynamic ARP Inspection
- IP Source Guard
- Port Security
- BPDU Guard + PortFast
- 802.1X/RADIUS på valgte VLAN

Infrastrukturporter/trunker som ikke bruker DHCP må vurderes som trusted der DHCP Snooping/DAI ellers ville blokkert legitim statisk trafikk.

## Sentrale tjenester

| Tjeneste | Rolle |
|---|---|
| TACACS+ | Administrativ autentisering/accounting |
| FreeRADIUS | 802.1X-klientautentisering |
| Syslog | Sentral mottak av Cisco-logger |
| NTP | Tidssynkronisering, valgfritt på Ubuntu |
| SNMPv3/NMS | Overvåkning av nettverksenheter |
| Security Onion | IDS/NSM via SPAN/RSPAN/ERSPAN-destinasjon |

## Overvåkning

Security Onion skal motta kopiert trafikk på en dedikert sniff-interface uten IP-adresse. I endelig design kan kildetrafikk transporteres med SPAN/RSPAN/ERSPAN avhengig av plattformstøtte. Selve Security Onion-installasjonen holdes separat fra den delte Docker-tjenestestacken.
