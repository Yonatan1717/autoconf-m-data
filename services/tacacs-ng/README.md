# TACACS+ / tac_plus-ng

Denne tjenesten bruker containeren `christianbecker/tac_plus-ng` og TCP/49.

## Klargjøring

```bash
cd services
./bootstrap-configs.sh
```

Rediger:

```text
tacacs-ng/config/tac_plus-ng.cfg
```

Bytt minst:

- `CHANGE_ME_TACACS_KEY`
- `CHANGE_ME_TACACS_USER_PASSWORD`

Malen er laget for lab og privilege 15. For produksjon bør brukere/roller kobles mot valgt identitetskilde og command authorization-policy vurderes eksplisitt.

## Start

```bash
docker compose up -d tacacs-ng
docker compose logs -f tacacs-ng
```

## Cisco router-mal

```cisco
aaa new-model
!
tacacs server TACACS-SERVER
 address ipv4 10.1.10.10
 key <TACACS_SHARED_SECRET>
!
aaa group server tacacs+ TACACS-GROUP
 server name TACACS-SERVER
 ip vrf forwarding MGMT
 ip tacacs source-interface Loopback10
!
aaa authentication login default group TACACS-GROUP local
aaa authorization exec default group TACACS-GROUP local
aaa accounting exec default start-stop group TACACS-GROUP
aaa accounting commands 15 default start-stop group TACACS-GROUP
```

For switch brukes typisk management-SVI som source-interface.

## Verifikasjon

Opprett en ny SSH-sesjon til enheten, kjør en privilege 15-kommando og logg ut. Kontroller deretter TACACS-loggene.

Prosjektet/containeren som brukes: https://github.com/christian-becker/tac_plus-ng
