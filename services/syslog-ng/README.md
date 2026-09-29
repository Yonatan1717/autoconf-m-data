# Syslog-ng

Syslog-ng tar imot Cisco-logg og lagrer dem per hostname og dato under `logs/`.

## Start

```bash
cd services
docker compose up -d syslog-ng
docker compose logs -f syslog-ng
```

Eksempel på lagring:

```text
services/syslog-ng/logs/RS1/2026-09-29.log
services/syslog-ng/logs/SW1-SITE-1/2026-09-29.log
```

## Cisco-mal

```cisco
service timestamps log datetime msec show-timezone
logging host 10.1.10.10 transport udp port 514
logging trap informational
logging buffered 16384 informational
logging source-interface Vlan10
```

På router i MGMT-VRF kan syntaks for `logging host ... vrf MGMT` og Loopback10 som source-interface være aktuell, avhengig av IOS.

## Test

Generer en enkel hendelse på Cisco-enheten, for eksempel interface shutdown/no shutdown i lab, og kontroller filen:

```bash
tail -f logs/<HOSTNAME>/*.log
```

## TLS

Standardoppsettet eksponerer UDP/514 og TCP/601. TCP/6514 er med vilje ikke slått på uten sertifikater. Hvis TLS skal brukes, legg inn nøkkel/sertifikat og en eksplisitt TLS-source før port 6514 åpnes i `docker-compose.yml`.

Offisielt prosjekt/container: https://github.com/syslog-ng/syslog-ng
