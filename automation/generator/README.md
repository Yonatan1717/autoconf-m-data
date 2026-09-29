# Konfigurasjonsgenerator

`generate.py` er inngangspunktet for nettverksgeneratoren. Den leser Excel-arbeidsboken og bruker modulene i `networkDevScripts/` til å bygge Cisco-konfigurasjon.

## Kjøring

Fra repo-roten:

```bash
python automation/generator/generate.py my_network.xlsx
```

Output skrives til:

```text
generated/
automation/ansible/ansibleConfigs/
automation/ansible/ansibleBootstrapConfigs/
automation/ansible/init_config_switch/
```

Bruk `examples/demo_no_mpls.xlsx` som sanert eksempel på forventet input. Ikke commit en arbeidsbok som inneholder reelle secrets.
