# Security policy

Dette repoet inneholder konfigurasjonsgeneratorer for nettverksenheter og maler for autentiseringstjenester. Derfor må hemmeligheter behandles som produksjonsdata selv om miljøet opprinnelig er et labmiljø.

## Ikke commit

Ikke legg følgende i Git:

- ekte lokale Cisco-passord eller enable secrets
- TACACS shared secrets
- RADIUS shared secrets
- SNMPv3 auth-/privacy-passord
- DMVPN/IPsec PSK-er
- private nøkler eller sertifikat-private keys
- Ansible Vault-passord
- ferdige inventory-filer som inneholder legitimasjon
- backup av running-config med ekte hemmeligheter

Bruk `.example`-filer og `CHANGE_ME_*`-verdier i repoet.

## Før repoet gjøres offentlig

Kjør minst:

```bash
git grep -nEi 'password|secret|pre-shared-key|snmp-server user|key[ =]'
```

og vurder et secret-scanning-verktøy som `gitleaks`.

Dersom en hemmelighet allerede har vært commitet, er det ikke nok å bare slette den i siste commit. Roter hemmeligheten og fjern den fra Git-historikken før offentlig publisering.
