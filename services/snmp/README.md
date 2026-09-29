# SNMPv3

Nettverksgeneratoren støtter SNMPv3 med `authPriv`. Denne mappen inneholder først og fremst verifikasjonsnotater; valg av full NMS-plattform er holdt utenfor den sentrale Docker-stacken.

Installer testverktøy på Ubuntu:

```bash
sudo apt update
sudo apt install -y snmp
```

Test:

```bash
snmpwalk -v3 -l authPriv \
  -u nmsuser \
  -a SHA -A '<AUTH_PASSWORD>' \
  -x AES -X '<PRIV_PASSWORD>' \
  10.1.10.1 1.3.6.1.2.1.1
```

Cisco-konfigurasjonen bør begrense SNMP-kilden med ACL og unngå SNMPv2c community strings.
