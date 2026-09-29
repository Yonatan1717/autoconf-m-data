# FreeRADIUS / 802.1X

FreeRADIUS brukes som backend for 802.1X på klientporter. Docker-imaget i denne mappen er det offisielle `freeradius/freeradius-server`-imaget.

## Klargjøring

Fra `services/`:

```bash
./bootstrap-configs.sh
```

Rediger:

```text
freeradius/config/clients.conf
freeradius/config/authorize
```

`clients.conf` må inneholde management-IP-en som switchen faktisk bruker som RADIUS source-address. Dette må samsvare med `ip radius source-interface` på Cisco.

Hvis generatoren allerede er kjørt, kan klientlisten synkroniseres direkte:

```bash
./freeradius/sync-generated-clients.sh
```

Skriptet kopierer bare klientlisten; kontroller fortsatt shared secret før oppstart.

## Start og debug

```bash
docker compose up -d --build freeradius
docker compose logs -f freeradius
```

Interaktiv debug:

```bash
docker compose run --rm freeradius -X
```

## Cisco-mal

```cisco
radius server CLIENT-RADIUS
 address ipv4 10.1.10.10 auth-port 1812 acct-port 1813
 key <RADIUS_SHARED_SECRET>
!
aaa group server radius DOT1X-RADIUS
 server name CLIENT-RADIUS
!
ip radius source-interface Vlan10
aaa authentication dot1x default group DOT1X-RADIUS
aaa authorization network default group DOT1X-RADIUS
aaa accounting dot1x default start-stop group DOT1X-RADIUS
dot1x system-auth-control
```

På en klientport avhenger nøyaktig syntaks av IOS-generasjonen, men typisk brukes authenticator/port-control auto.

## Sertifikater

Det offisielle Docker-imaget leveres med selvsignerte sertifikater for enkel testing. De skal ikke behandles som produksjonssertifikater. Ved PEAP/EAP-TLS bør klientene validere serveridentitet mot en CA du kontrollerer.

Offisiell containerdokumentasjon: https://hub.docker.com/r/freeradius/freeradius-server/
