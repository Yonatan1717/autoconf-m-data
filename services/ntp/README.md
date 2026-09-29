# NTP / Chrony (valgfritt)

Dagens generator kan bruke site-router/hub som NTP-kilde. Denne mappen er et alternativ dersom NTP skal flyttes til Ubuntu-serveren.

Native installasjon er enklere og mer naturlig enn Docker fordi tidsservice er tett knyttet til vertssystemet.

```bash
sudo apt update
sudo apt install -y chrony
sudo cp chrony.conf.example /etc/chrony/chrony.conf
sudo systemctl restart chrony
chronyc sources -v
```

Bytt upstream-kilder og `allow`-nett etter faktisk policy.

Cisco:

```cisco
ntp server 10.1.10.10
```

Hvis eksisterende design med router som `ntp master` beholdes, trenger du ikke aktivere denne tjenesten.
