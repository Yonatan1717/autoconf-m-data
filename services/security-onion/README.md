# Security Onion

Security Onion skal **ikke** kjøres som enda en container i den delte Ubuntu-stacken i dette prosjektet. Det er en komplett NSM/SOC-plattform med egne installasjons-, lagrings- og nettverkskrav.

## Anbefalt labmodell

For et lite CML-/testmiljø er `EVAL` et naturlig utgangspunkt. I Security Onion 3-dokumentasjonen er minimum for Eval:

- 4 CPU-kjerner
- 8 GB RAM
- 200 GB lokal disk
- 2 NIC-er

`EVAL` er laget for midlertidig evaluering/homelab og er ikke ment som produksjonsoppsett. For `STANDALONE` er dokumentert minimum 4 CPU-kjerner, 24 GB RAM, 200 GB lokal disk og 2 NIC-er. Reelle behov øker med trafikkmengde, retention og aktiverte tjenester.

Security Onion støtter x86-64. For produksjon bør ressursbehov dimensjoneres etter faktisk trafikk og lagringskrav.

## Nettverkskort

Bruk to NIC-er i denne prosjektmodellen:

```text
NIC 1 - Management
  statisk IP
  default gateway
  tilgang til SOC/web/oppdateringer

NIC 2 - Sniffing
  ingen IP-adresse
  koblet til TAP/SPAN eller lokal speildestinasjon
```

Security Onion anbefaler ett interface med IP-adresse til management. Sniff-interface bør være dedikert til trafikkfangst og ikke ha IP-adresse.

## Installasjon

1. Last ned og verifiser den offisielle Security Onion ISO-en.
2. Opprett VM/server som møter kravene, med management-NIC og sniff-NIC.
3. Boot ISO-en og fullfør OS-installasjonen.
4. Sett korrekt hostname før Security Onion Setup. Sertifikater genereres på bakgrunn av hostname, og Security Onion støtter ikke at hostname endres etter Setup.
5. Etter reboot/logginn starter Setup normalt automatisk. Hvis nødvendig kan Setup startes manuelt etter den offisielle installasjonsveiledningen.
6. Konfigurer management-interface med korrekt IP/gateway.
7. Velg `EVAL` for en liten testinstallasjon, eller en annen rolle som passer miljøet.
8. Legg til sniff-interface og koble dette mot speiltrafikken.
9. Fullfør Setup og logg inn i Security Onion Console (SOC).

Kontroller status fra CLI:

```bash
sudo so-status
```

Firewall/analyst-tilgang håndteres primært i SOC under:

```text
Administration -> Configuration -> firewall -> hostgroups
```

Hvis SOC ikke er tilgjengelig, dokumenterer Security Onion denne recovery-kommandoen:

```bash
sudo so-firewall includehost analyst <ANALYST_IP>
```

## Integrasjon med dette nettet

I designet bør speiltrafikk ende på Security Onion sin sniff-NIC. Metoden velges etter hva målplattformen faktisk støtter:

```text
Kildeporter/VLAN
      |
      +-- lokal SPAN --------------------> sniff-NIC
      |
      +-- RSPAN ---> destinasjonsswitch -> lokal SPAN -> sniff-NIC
      |
      +-- ERSPAN --> støttet terminering -> lokal speiling -> sniff-NIC
```

Ikke anta at CML-/IOSvL2-støtte for SPAN/RSPAN/ERSPAN er identisk med fysisk målplattform. Verifiser dataplanen med packet capture før løsningen godkjennes.

Se også [`CISCO_MIRRORING.md`](CISCO_MIRRORING.md).

## Etter installasjon

Minimumsverifikasjon:

```text
[ ] Management-IP kan nås fra autorisert admin-nett
[ ] SOC kan åpnes
[ ] so-status viser forventede tjenester
[ ] Sniff-NIC har ikke vanlig klient-IP
[ ] Speilet testtrafikk kan observeres
[ ] Suricata/Zeek mottar relevant trafikk
[ ] Tid/NTP er korrekt
[ ] Retention/diskbruk er kontrollert
```

## Offisiell dokumentasjon

- Hardware: https://docs.securityonion.net/en/3/main/hardware/
- Installation: https://docs.securityonion.net/en/3/main/installation/
- Getting Started: https://docs.securityonion.net/en/3/main/getting-started/
- Best Practices: https://docs.securityonion.net/en/3/main/best-practices/
- Post Installation: https://docs.securityonion.net/en/3/main/post-installation/
