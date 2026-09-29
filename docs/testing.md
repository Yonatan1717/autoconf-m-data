# Verifikasjon og test

## L2-sikkerhet

### DHCP Snooping

```cisco
show ip dhcp snooping
show ip dhcp snooping binding
```

For en legitim DHCP-klient skal bindingen vise korrekt MAC, IP, VLAN og interface.

### Dynamic ARP Inspection

```cisco
show ip arp inspection
show ip arp inspection statistics vlan <VLAN>
```

Ved test skal legitime ARP-pakker forwardes. Ugyldige bindingsforsøk bør gi økende drop-teller.

### IP Source Guard

```cisco
show ip verify source
show ip verify source interface <INTERFACE>
```

Verifiser først at DHCP Snooping-bindingen finnes. Test deretter med en kilde-IP som ikke matcher bindingen. Se også `lab-limitations.md` for IOSvL2/CML-observasjon.

### Port Security

```cisco
show port-security interface <INTERFACE>
show port-security address
```

Kontroller `Secure-up`, antall lærte MAC-adresser og `Security Violation Count`.

## L3 / VRF

```cisco
show ip route vrf MGMT
show ip route vrf INET
show ip route vrf UNET
show ip route vrf PA
show ip route vrf MONITORING
```

Gateway-test:

```cisco
ping vrf MGMT <CLIENT-IP> source <GATEWAY-IP>
```

## DMVPN / EIGRP / IPsec

```cisco
show dmvpn
show ip nhrp
show ip eigrp vrf MGMT neighbors
show ip eigrp vrf MGMT topology
show crypto ikev2 sa
show crypto ipsec sa
```

Test både hub↔spoke og, ved Phase 3, spoke↔spoke.

## TACACS+

På Cisco:

```cisco
show aaa servers
show running-config | include aaa accounting
```

På Ubuntu:

```bash
docker compose -f services/docker-compose.yml logs -f tacacs-ng
```

Test:

1. ny SSH-innlogging
2. privilege 15-kommando
3. logout
4. lokal fallback når TACACS-tjenesten er utilgjengelig

## RADIUS / 802.1X

```cisco
show authentication sessions
show authentication sessions interface <INTERFACE> details
show radius statistics
```

Serverdebug:

```bash
cd services
docker compose run --rm freeradius -X
```

Test både gyldig og ugyldig bruker.

## Syslog

På Cisco:

```cisco
show logging
```

På Ubuntu:

```bash
find services/syslog-ng/logs -type f -maxdepth 3 -print
tail -f services/syslog-ng/logs/<HOSTNAME>/*.log
```

## SNMPv3

Fra NMS/Ubuntu:

```bash
snmpwalk -v3 -l authPriv \
  -u <USER> \
  -a SHA -A '<AUTH_PASSWORD>' \
  -x AES -X '<PRIV_PASSWORD>' \
  <DEVICE_IP> 1.3.6.1.2.1.1
```

## Security Onion

Bekreft at sniff-interfacet mottar speiltrafikk og at Suricata/Zeek genererer hendelser/metadata. På Security Onion kan `sudo so-status` brukes til å kontrollere tjenestestatus.
