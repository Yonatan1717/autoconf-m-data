# Ansible

Denne mappen inneholder playbooks for utrulling, backup, kontrollert endring og rollback av generert Cisco-konfigurasjon.

## Installer avhengigheter

```bash
python3 -m pip install ansible-core ansible-pylibssh
ansible-galaxy collection install -r requirements.yml
```

## Genererte filer

Etter:

```bash
python automation/generator/generate.py my_network.xlsx
```

opprettes blant annet:

```text
inventory.ini
ansibleConfigs/
ansibleBootstrapConfigs/
init_config_switch/
README_GENERATED_CONFIGS.txt
legacy_ssh.cfg        # dersom LEGACY_SSH=True
```

Disse filene kan inneholde miljøspesifikk informasjon og er derfor ignorert av Git.

## Legitimasjon

Generatoren skriver ikke Ansible-passord til inventory. For enkel labbruk:

```bash
ansible-playbook deploy_generated.yml --ask-pass
```

For et varig oppsett bør Ansible Vault eller SSH-nøkler brukes.

## Full deploy

```bash
ansible-playbook deploy_generated.yml --ask-pass
```

`serial: 1` brukes for å redusere blast radius. Husk at `cisco.ios.ios_config` gjør merge. Dersom en task feiler etter at noen kommandoer er akseptert, kan enheten stå delvis endret.

## Backup

Kopier først eksempelvariablene:

```bash
cp vars.yml.example vars.yml
```

Rediger `backup_root`, og kjør:

```bash
ansible-playbook daily_back_up.yml --ask-pass
```

## Safe change / rollback

Struktur:

```text
changes/<change_name>/
├── deploy.yml
├── verify.yml
└── apply.yml      # valgfri
```

Eksempel:

```bash
ANSIBLE_EXTRA_ARGS="--ask-pass" ./safe_change.sh RS1 loop99
```

Flyt:

1. pre-change backup
2. deploy/stage
3. valgfri apply
4. verify
5. ved feil: finn siste pre-change backup
6. `configure replace`-basert restore

Test `configure replace` på faktisk IOS/plattform før produksjonsbruk.

## Bootstrap

`ansibleBootstrapConfigs/` er ment for console-paste slik at management + SSH/SCP kommer opp før full deploy. `init_config_switch/` inneholder midlertidig L2-stagingoppsett og forslag til control-node-adresser.
