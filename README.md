# NO_MPLS_SAD

Automatisert oppsett av et segmentert Cisco-nett med VRF-Lite, VLAN, DMVPN, IPsec, EIGRP, AAA, 802.1X, logging, overvåkning og Ansible-basert utrulling.

Repoet er strukturert slik at **generator-kode**, **Ansible**, **sentrale tjenester**, **dokumentasjon**, **eksempler** og **generert output** er tydelig skilt fra hverandre. Målet er at repoet skal være lett å forstå både som prosjektleveranse og som faktisk driftsverktøy.

> **Viktig:** Ikke legg ekte passord, PSK-er, SNMP-nøkler eller RADIUS/TACACS-hemmeligheter i Git. Eksempelfilene i repoet bruker `CHANGE_ME_*`-verdier, og generert output er ignorert av Git som standard.

## Arkitektur i korte trekk

```text
                         +-------------------------+
                         |      Site 1 / BNHQ      |
                         |                         |
                         |  TACACS / RADIUS        |
                         |  Syslog / NMS           |
                         |  Security Onion*        |
                         +------------+------------+
                                      |
                              DMVPN / L3 transport
                         _____________|_____________
                        /                           \
                       /                             \
              +-------+-------+             +-------+-------+
              |    Site 2     |             |    Site 3     |
              | MGMT / INET   |             | MGMT / INET   |
              | UNET / PA     |             | UNET / PA     |
              +---------------+             +---------------+

* Security Onion kjøres separat som egen VM/server, ikke som container i den
  delte Ubuntu-tjenestestacken.
```

Standard tjenestesegmentering i regnearkmalen:

| VLAN | VRF / tjeneste | Formål |
|---:|---|---|
| 10 | MGMT | Administrasjon, AAA, management |
| 20 | INET | Internett-/velferdsklienter |
| 30 | UNET | Ugradert tjenestenett |
| 40 | PA | PA-/spesialtjeneste |
| 50 | MONITORING | Sensor-/overvåkningstrafikk |
| 999 | Native / blackhole | Ubrukt native VLAN |

## Repo-struktur

```text
.
├── README.md
├── SECURITY.md
├── Makefile
├── requirements.txt
├── automation/
│   ├── README.md
│   ├── generator/
│   │   ├── generate.py
│   │   └── networkDevScripts/
│   └── ansible/
│       ├── README.md
│       ├── deploy_generated.yml
│       ├── daily_back_up.yml
│       ├── safe_change.sh
│       └── changes/
├── services/
│   ├── README.md
│   ├── docker-compose.yml
│   ├── freeradius/
│   ├── tacacs-ng/
│   ├── syslog-ng/
│   ├── ntp/
│   ├── snmp/
│   └── security-onion/
├── docs/
│   ├── architecture.md
│   ├── deployment.md
│   ├── testing.md
│   └── lab-limitations.md
├── examples/
│   ├── demo_no_mpls.xlsx
│   └── generated/
├── templates/
│   ├── cisco/
│   └── ubuntu/
├── tools/
│   └── summarize_site_config.py
└── generated/
    └── README.md
```

## Kom raskt i gang

### 1. Python-miljø

```bash
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
```

### 2. Lag en lokal inputfil

Bruk den saniterte malen:

```bash
cp examples/demo_no_mpls.xlsx my_network.xlsx
```

Bytt ut alle `CHANGE_ME_*`-verdier før du bruker konfigurasjonen i et faktisk miljø.

### 3. Generer Cisco- og Ansible-konfigurasjon

```bash
python automation/generator/generate.py my_network.xlsx
```

Generatoren skriver:

- router-/switch-JSON og lesbare tekstfiler til `generated/`
- Ansible-klare device-configs til `automation/ansible/ansibleConfigs/`
- bootstrap-konfigurasjon til `automation/ansible/ansibleBootstrapConfigs/`
- staging-/INIT-switchfiler til `automation/ansible/init_config_switch/`
- `inventory.ini` til `automation/ansible/`

Passord skrives **ikke** til Ansible inventory. Bruk `--ask-pass` eller Ansible Vault.

### 4. Vis en lesbar oppsummering

```bash
python tools/summarize_site_config.py
python tools/summarize_site_config.py --site 1
```

### 5. Start sentrale tjenester på Ubuntu

```bash
cd services
./bootstrap-configs.sh
```

Rediger deretter `.env` hvis tjenesteserveren ikke bruker demo-adressen `10.1.10.10`, og rediger:

```text
freeradius/config/clients.conf
freeradius/config/authorize
tacacs-ng/config/tac_plus-ng.cfg
```

og start tjenestene:

```bash
docker compose up -d --build
```

Tjenester i Docker-stacken:

| Tjeneste | Port | Bruk |
|---|---|---|
| TACACS+ | TCP/49 | Administrativ AAA |
| RADIUS | UDP/1812, 1813 | 802.1X autentisering/accounting |
| Syslog | UDP/514, TCP/601 | Sentral logging |

Security Onion er dokumentert separat under `services/security-onion/` fordi den bør installeres som egen VM/server med dedikert sniff-interface.

### 6. Ansible

```bash
cd automation/ansible
ansible-galaxy collection install -r requirements.yml
ansible-playbook deploy_generated.yml --ask-pass
```

For produksjonsbruk anbefales Ansible Vault fremfor interaktivt passord.

## Dokumentasjon

- [`docs/architecture.md`](docs/architecture.md) – logisk design og hovedkomponenter
- [`docs/deployment.md`](docs/deployment.md) – anbefalt installasjons- og utrullingsrekkefølge
- [`docs/testing.md`](docs/testing.md) – verifikasjonskommandoer og testpunkter
- [`docs/lab-limitations.md`](docs/lab-limitations.md) – kjente lab-/CML-begrensninger
- [`automation/ansible/README.md`](automation/ansible/README.md) – backup, deploy og rollback
- [`services/README.md`](services/README.md) – sentrale Ubuntu-tjenester
- [`templates/README.md`](templates/README.md) – korte manuelle Cisco-/Ubuntu-maler

## Sikkerhet og Git

Repoet er lagt opp slik at sensitive og genererte filer ikke skal havne i Git ved et uhell. `.gitignore` ekskluderer blant annet:

- aktive TACACS-/RADIUS-konfigurasjoner med secrets
- Ansible inventory generert fra miljøet
- genererte Cisco-konfigurasjoner
- backupfiler
- lokale `.env`-/vault-filer

Les [`SECURITY.md`](SECURITY.md) før repoet gjøres offentlig.

## Labstatus / kjente begrensninger

I CML/IOSvL2 ble `ip verify source` observert å blokkere trafikk selv når DHCP Snooping-bindingen var korrekt. Når IPSG ble deaktivert på porten, fungerte ARP/gateway-trafikk igjen. Dette behandles som en lab-/imagebegrensning og bør verifiseres på fysisk målplattform før konklusjon om funksjonen.

ERSPAN må også verifiseres mot faktisk målplattform dersom labutstyret ikke støtter hele dataflyten. Se [`docs/lab-limitations.md`](docs/lab-limitations.md).

## Kilder for tjenesteoppsett

Dokumentasjonen i `services/` peker til de offisielle prosjektene for FreeRADIUS, syslog-ng og Security Onion, samt container-prosjektet som brukes for tac_plus-ng. Versjoner og installasjonskrav bør alltid kontrolleres før produksjonssetting.
