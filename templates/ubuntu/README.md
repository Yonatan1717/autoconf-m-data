# Ubuntu management-interface

Eksemplet bruker prosjektets demo-adresse `10.1.10.10/24`. Finn korrekt NIC-navn først:

```bash
ip -br link
```

Kopier og rediger malen:

```bash
sudo cp 01-management.yaml.example /etc/netplan/01-management.yaml
sudoedit /etc/netplan/01-management.yaml
sudo netplan try
sudo netplan apply
```

Bruk `netplan try` fra lokal/console-tilgang når mulig, slik at feil ikke låser deg ute over SSH.
