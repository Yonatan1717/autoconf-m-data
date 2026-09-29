# Deployment workflow

Dette er anbefalt rekkefølge for førstegangsoppsett.

## 1. Klargjør Ubuntu control/service server

Installer minst:

```bash
sudo apt update
sudo apt install -y python3 python3-venv git docker.io docker-compose-plugin
```

Gi serveren en statisk management-adresse som er routbar fra nettverksenhetene. I eksempeldataene brukes `10.1.10.10` som sentral tjenesteadresse.

## 2. Klargjør repo og generator

```bash
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
cp examples/demo_no_mpls.xlsx my_network.xlsx
```

Rediger `my_network.xlsx` med faktisk topologi og hemmeligheter. Ikke commit denne filen.

Generer:

```bash
python automation/generator/generate.py my_network.xlsx
```

## 3. Førstegangs bootstrap

Generatoren oppretter `automation/ansible/init_config_switch/` og bootstrap-filer for hver Cisco-enhet.

Arbeidsflyt:

1. Konfigurer midlertidig INIT/config-switch.
2. Koble control node til port 1.
3. Legg midlertidige MGMT-adresser på control-node NIC ved behov.
4. Koble routere til trunkporter og switcher til accessporter som beskrevet i portkartet.
5. Lim inn riktig `*_SSH_SCP.cfg` via console.
6. Test SSH fra Ubuntu-serveren.
7. Kjør full Ansible-deploy.
8. Verifiser før `write memory`/endelig innplassering.

## 4. Start sentrale tjenester

```bash
cd services
./bootstrap-configs.sh
```

Rediger de aktive configfilene og bytt alle `CHANGE_ME_*`-verdier.

```bash
docker compose up -d --build
```

Verifiser:

```bash
docker compose ps
docker compose logs --tail=100 freeradius
docker compose logs --tail=100 tacacs-ng
docker compose logs --tail=100 syslog-ng
```

## 5. Ansible-deploy

```bash
cd automation/ansible
ansible-galaxy collection install -r requirements.yml
ansible-playbook deploy_generated.yml --ask-pass
```

Bruk `serial: 1` for å redusere blast radius ved feil. Husk at `ios_config` normalt gjør merge, ikke automatisk rollback av allerede aksepterte kommandoer dersom tasken feiler halvveis.

## 6. Verifikasjon

Følg `docs/testing.md`. Bekreft spesielt:

- management reachability
- DHCP Snooping / DAI / IPSG
- TACACS fallback til lokal bruker
- RADIUS/802.1X
- Syslog og NTP
- EIGRP/DMVPN
- IPsec
- SNMPv3
- speiltrafikk til Security Onion

## 7. Security Onion

Installer Security Onion separat etter `services/security-onion/README.md`. Bruk en dedikert management-NIC og en separat sniff-NIC uten IP-adresse.
