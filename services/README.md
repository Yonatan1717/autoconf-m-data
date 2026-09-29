# Sentrale tjenester på Ubuntu

Denne mappen samler tjenestene som nettverksenhetene bruker sentralt. I eksempelmiljøet brukes `10.1.10.10` som sentral tjenesteadresse.

| Tjeneste | Modell | Formål |
|---|---|---|
| FreeRADIUS | Docker | 802.1X authentication/accounting |
| tac_plus-ng | Docker | Administrativ AAA for nettverksutstyr |
| syslog-ng | Docker | Sentral mottak/lager av Cisco-syslog |
| Chrony | Native Ubuntu, valgfritt | NTP hvis router ikke skal være tidskilde |
| SNMP-verktøy | Native Ubuntu | SNMPv3-verifikasjon / grunnlag for NMS |
| Security Onion | Egen VM/server | NSM/SOC, Suricata/Zeek og speiltrafikk |

Security Onion ligger derfor i samme dokumentasjonsstruktur, men er **ikke** del av `docker-compose.yml`.

## Forutsetninger

Installer Docker på Ubuntu:

```bash
sudo apt update
sudo apt install -y docker.io docker-compose-plugin
sudo systemctl enable --now docker
```

## Første oppstart

Fra `services/`:

```bash
./bootstrap-configs.sh
```

Dette oppretter lokale, Git-ignorerte arbeidsfiler fra malene:

```text
.env
freeradius/config/clients.conf
freeradius/config/authorize
tacacs-ng/config/tac_plus-ng.cfg
```

Rediger `.env` dersom Ubuntu-serveren ikke bruker `10.1.10.10`, og bytt deretter alle `CHANGE_ME_*`-verdier i de aktive konfigurasjonsfilene.

Start:

```bash
docker compose up -d --build
```

Status/logg:

```bash
docker compose ps
docker compose logs -f freeradius
docker compose logs -f tacacs-ng
docker compose logs -f syslog-ng
```

## Porter

| Tjeneste | Port | Transport |
|---|---:|---|
| TACACS+ | 49 | TCP |
| RADIUS authentication | 1812 | UDP |
| RADIUS accounting | 1813 | UDP |
| Syslog klassisk | 514 | UDP |
| Syslog TCP | 601 | TCP |

Compose-filen binder som standard disse portene til `SERVICE_BIND_IP` fra `.env`. Åpne bare nødvendige porter fra aktuelle management-/infrastruktur-nett. Syslog over TLS/6514 er ikke aktivert i standardmalen; legg til sertifikatbasert TLS-konfigurasjon før porten eksponeres.

## Anbefalt rekkefølge

1. Gi Ubuntu-serveren statisk management-IP.
2. Verifiser routing og NTP.
3. Kjør `bootstrap-configs.sh`.
4. Endre alle secrets og TACACS/RADIUS-klientadresser.
5. Start containerne.
6. Test RADIUS og TACACS lokalt før Cisco-enheter peker mot tjenestene.
7. Aktiver AAA på én nettverksenhet om gangen og behold lokal fallback.
8. Verifiser syslog og SNMPv3.
9. Installer Security Onion separat og koble inn speiltrafikk.

## Hvorfor ikke Security Onion i samme compose-stack?

Security Onion er en komplett NSM/SOC-plattform med betydelig høyere ressurs- og lagringskrav og et dedikert sniff-interface. Se [`security-onion/README.md`](security-onion/README.md).
