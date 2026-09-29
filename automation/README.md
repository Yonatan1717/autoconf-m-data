# Automatisering

Her ligger kildekoden som bygger nettverkskonfigurasjon og Ansible-oppsettet som kan distribuere den.

- `generator/` – leser Excel-input og bygger router-/switch-konfigurasjon.
- `ansible/` – bootstrap, full deploy, backup, safe change og restore.

Normal flyt:

```bash
python automation/generator/generate.py my_network.xlsx
cd automation/ansible
ansible-playbook deploy_generated.yml --ask-pass
```

Generert output og miljøspesifikk inventory er Git-ignorert.
